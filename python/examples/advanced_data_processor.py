#!/usr/bin/env python3
"""
Advanced Data Processor Example

Demonstrates:
- Database connections with SQLAlchemy
- Batch processing with generators
- Parallel processing with ThreadPoolExecutor
- Progress tracking with tqdm
- Comprehensive error handling
- Resource cleanup with context managers
- Type hints and dataclasses

Usage:
    export DATABASE_URL="postgresql://user:password@localhost/dbname"
    python advanced_data_processor.py input.csv
"""

import os
import sys
import logging
from pathlib import Path
from typing import Generator, List, Dict, Any
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor, as_completed
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.pool import NullPool
from tqdm import tqdm

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_processor.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


# Custom exceptions
class ProcessingError(Exception):
    """Base exception for processing errors."""
    pass


class FileProcessingError(ProcessingError):
    """Raised when file processing fails."""
    pass


class DatabaseError(ProcessingError):
    """Raised when database operation fails."""
    pass


@dataclass
class ProcessingResult:
    """Result of data processing operation."""
    success: bool
    records_processed: int
    records_failed: int
    errors: List[str]


class DataProcessor:
    """
    Advanced data processor with parallel processing and database integration.

    Attributes:
        db_url: Database connection URL
        batch_size: Number of records per batch
        max_workers: Maximum parallel workers
    """

    def __init__(
        self,
        db_url: str,
        batch_size: int = 1000,
        max_workers: int = 4
    ):
        """
        Initialize data processor.

        Args:
            db_url: Database connection URL
            batch_size: Records per batch
            max_workers: Maximum parallel workers

        Raises:
            ValueError: If db_url is empty or batch_size invalid
        """
        if not db_url:
            raise ValueError("db_url cannot be empty")
        if batch_size <= 0:
            raise ValueError("batch_size must be positive")
        if max_workers <= 0:
            raise ValueError("max_workers must be positive")

        self.db_url = db_url
        self.batch_size = batch_size
        self.max_workers = max_workers

        # Create engine with NullPool for parallel processing
        self.engine = create_engine(
            db_url,
            poolclass=NullPool,  # No connection pooling for parallel workers
            echo=False
        )

        logger.info(f"DataProcessor initialized (batch_size={batch_size}, workers={max_workers})")

    def read_csv_batches(self, file_path: Path) -> Generator[pd.DataFrame, None, None]:
        """
        Read CSV file in batches using generator for memory efficiency.

        Args:
            file_path: Path to CSV file

        Yields:
            DataFrame batches

        Raises:
            FileProcessingError: If file cannot be read
        """
        if not file_path.exists():
            raise FileProcessingError(f"File not found: {file_path}")

        logger.info(f"Reading CSV file: {file_path}")

        try:
            # Use pandas chunksize for memory-efficient reading
            for chunk in pd.read_csv(file_path, chunksize=self.batch_size):
                yield chunk

        except Exception as e:
            raise FileProcessingError(f"Failed to read CSV: {e}")

    def validate_record(self, record: Dict[str, Any]) -> bool:
        """
        Validate single record.

        Args:
            record: Record dictionary

        Returns:
            True if valid, False otherwise
        """
        # Example validation rules
        required_fields = ['id', 'name', 'value']

        # Check required fields exist
        if not all(field in record for field in required_fields):
            return False

        # Check value is numeric
        try:
            float(record['value'])
        except (ValueError, TypeError):
            return False

        return True

    def process_record(self, record: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process single record (transform data).

        Args:
            record: Input record

        Returns:
            Processed record
        """
        # Example transformations
        processed = record.copy()

        # Normalize string fields
        if 'name' in processed:
            processed['name'] = str(processed['name']).strip().title()

        # Convert value to float
        if 'value' in processed:
            processed['value'] = float(processed['value'])

        # Add metadata
        processed['processed'] = True

        return processed

    def store_batch(self, batch: List[Dict[str, Any]]) -> int:
        """
        Store batch of records in database.

        Args:
            batch: List of records to store

        Returns:
            Number of records stored

        Raises:
            DatabaseError: If database operation fails
        """
        if not batch:
            return 0

        try:
            with self.engine.connect() as conn:
                # Example: Insert into table
                # In production, use proper SQLAlchemy models
                insert_query = text("""
                    INSERT INTO processed_data (id, name, value, processed)
                    VALUES (:id, :name, :value, :processed)
                    ON CONFLICT (id) DO UPDATE
                    SET name = EXCLUDED.name,
                        value = EXCLUDED.value,
                        processed = EXCLUDED.processed
                """)

                # Execute batch insert
                conn.execute(insert_query, batch)
                conn.commit()

            return len(batch)

        except Exception as e:
            logger.error(f"Database error: {e}")
            raise DatabaseError(f"Failed to store batch: {e}")

    def process_batch(self, df: pd.DataFrame) -> ProcessingResult:
        """
        Process single batch of data.

        Args:
            df: DataFrame batch

        Returns:
            ProcessingResult with statistics
        """
        records_processed = 0
        records_failed = 0
        errors = []
        valid_records = []

        # Process each record
        for idx, row in df.iterrows():
            try:
                record = row.to_dict()

                # Validate
                if not self.validate_record(record):
                    records_failed += 1
                    errors.append(f"Validation failed for record {idx}")
                    continue

                # Process
                processed_record = self.process_record(record)
                valid_records.append(processed_record)
                records_processed += 1

            except Exception as e:
                records_failed += 1
                errors.append(f"Error processing record {idx}: {e}")
                logger.error(f"Record processing error: {e}")

        # Store valid records
        if valid_records:
            try:
                self.store_batch(valid_records)
            except DatabaseError as e:
                errors.append(f"Database storage failed: {e}")
                records_failed += len(valid_records)
                records_processed -= len(valid_records)

        return ProcessingResult(
            success=records_failed == 0,
            records_processed=records_processed,
            records_failed=records_failed,
            errors=errors
        )

    def process_file_sequential(self, file_path: Path) -> ProcessingResult:
        """
        Process file sequentially (single-threaded).

        Args:
            file_path: Path to input file

        Returns:
            ProcessingResult with statistics
        """
        logger.info(f"Processing file sequentially: {file_path}")

        total_processed = 0
        total_failed = 0
        all_errors = []

        # Process batches with progress bar
        batches = list(self.read_csv_batches(file_path))
        for batch in tqdm(batches, desc="Processing batches"):
            result = self.process_batch(batch)

            total_processed += result.records_processed
            total_failed += result.records_failed
            all_errors.extend(result.errors)

        logger.info(
            f"Sequential processing complete: "
            f"{total_processed} processed, {total_failed} failed"
        )

        return ProcessingResult(
            success=total_failed == 0,
            records_processed=total_processed,
            records_failed=total_failed,
            errors=all_errors
        )

    def process_file_parallel(self, file_path: Path) -> ProcessingResult:
        """
        Process file in parallel using ThreadPoolExecutor.

        Args:
            file_path: Path to input file

        Returns:
            ProcessingResult with statistics
        """
        logger.info(f"Processing file in parallel (workers={self.max_workers}): {file_path}")

        total_processed = 0
        total_failed = 0
        all_errors = []

        # Read all batches first (for progress bar)
        batches = list(self.read_csv_batches(file_path))

        # Process batches in parallel
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all tasks
            future_to_batch = {
                executor.submit(self.process_batch, batch): i
                for i, batch in enumerate(batches)
            }

            # Collect results with progress bar
            with tqdm(total=len(batches), desc="Processing batches") as pbar:
                for future in as_completed(future_to_batch):
                    batch_num = future_to_batch[future]

                    try:
                        result = future.result()
                        total_processed += result.records_processed
                        total_failed += result.records_failed
                        all_errors.extend(result.errors)

                    except Exception as e:
                        logger.error(f"Batch {batch_num} processing failed: {e}")
                        all_errors.append(f"Batch {batch_num} error: {e}")

                    pbar.update(1)

        logger.info(
            f"Parallel processing complete: "
            f"{total_processed} processed, {total_failed} failed"
        )

        return ProcessingResult(
            success=total_failed == 0,
            records_processed=total_processed,
            records_failed=total_failed,
            errors=all_errors
        )

    def close(self):
        """Cleanup resources."""
        self.engine.dispose()
        logger.info("DataProcessor resources cleaned up")


def main():
    """
    Main function demonstrating data processor usage.

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    # Check command line arguments
    if len(sys.argv) < 2:
        logger.error("Usage: python advanced_data_processor.py <input_file.csv>")
        return 1

    input_file = Path(sys.argv[1])

    if not input_file.exists():
        logger.error(f"Input file not found: {input_file}")
        return 1

    # Load database URL from environment
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        logger.error("DATABASE_URL environment variable not set")
        logger.error("Example: export DATABASE_URL='postgresql://user:pass@localhost/db'")
        return 1

    try:
        # Initialize processor
        processor = DataProcessor(
            db_url=db_url,
            batch_size=1000,
            max_workers=4
        )

        # Process file (parallel mode)
        result = processor.process_file_parallel(input_file)

        # Log results
        if result.success:
            logger.info(f"✓ Processing completed successfully!")
            logger.info(f"  Records processed: {result.records_processed}")
        else:
            logger.warning(f"⚠ Processing completed with errors")
            logger.warning(f"  Records processed: {result.records_processed}")
            logger.warning(f"  Records failed: {result.records_failed}")

            if result.errors:
                logger.error("Errors encountered:")
                for error in result.errors[:10]:  # Show first 10 errors
                    logger.error(f"  - {error}")

        # Cleanup
        processor.close()

        return 0 if result.success else 1

    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
