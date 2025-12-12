#!/usr/bin/env python3
"""
Intermediate API Client Example

Demonstrates:
- Environment variable configuration
- Retry logic with exponential backoff
- Comprehensive error handling
- Custom exceptions
- Logging best practices
- Type hints
- Proper HTTP session management

Usage:
    export API_KEY="your_api_key_here"
    export API_BASE_URL="https://api.example.com"
    python intermediate_api_client.py
"""

import os
import sys
import time
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('api_client.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


# Custom exceptions
class APIClientError(Exception):
    """Base exception for API client errors."""
    pass


class AuthenticationError(APIClientError):
    """Raised when authentication fails."""
    pass


class NetworkError(APIClientError):
    """Raised when network request fails."""
    pass


class RateLimitError(APIClientError):
    """Raised when rate limit is exceeded."""
    pass


@dataclass
class APIResponse:
    """Structured API response."""
    status_code: int
    data: Dict[str, Any]
    headers: Dict[str, str]
    success: bool


class APIClient:
    """
    HTTP API client with retry logic and error handling.

    Attributes:
        base_url: Base URL for API requests
        api_key: API authentication key
        timeout: Request timeout in seconds
        max_retries: Maximum number of retry attempts
    """

    def __init__(
        self,
        base_url: str,
        api_key: str,
        timeout: int = 30,
        max_retries: int = 3
    ):
        """
        Initialize API client.

        Args:
            base_url: Base URL for API
            api_key: API authentication key
            timeout: Request timeout in seconds
            max_retries: Maximum retry attempts

        Raises:
            ValueError: If base_url or api_key is empty
        """
        if not base_url:
            raise ValueError("base_url cannot be empty")
        if not api_key:
            raise ValueError("api_key cannot be empty")

        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.timeout = timeout
        self.max_retries = max_retries
        self.session = self._create_session()

        logger.info(f"API client initialized for {self.base_url}")

    def _create_session(self) -> requests.Session:
        """
        Create requests session with retry configuration.

        Returns:
            Configured requests session
        """
        session = requests.Session()

        # Configure retry strategy
        retry_strategy = Retry(
            total=self.max_retries,
            backoff_factor=2,  # 2, 4, 8 seconds
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "POST", "PUT", "DELETE", "PATCH"],
            raise_on_status=False
        )

        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)

        # Set default headers
        session.headers.update({
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "User-Agent": "PythonAPIClient/1.0"
        })

        return session

    def _handle_response(self, response: requests.Response) -> APIResponse:
        """
        Handle API response and raise appropriate exceptions.

        Args:
            response: requests Response object

        Returns:
            APIResponse object

        Raises:
            AuthenticationError: If authentication fails (401, 403)
            RateLimitError: If rate limit exceeded (429)
            NetworkError: For other HTTP errors
        """
        # Handle specific status codes
        if response.status_code == 401:
            raise AuthenticationError("Authentication failed - invalid API key")

        if response.status_code == 403:
            raise AuthenticationError("Access forbidden - insufficient permissions")

        if response.status_code == 429:
            retry_after = response.headers.get('Retry-After', '60')
            raise RateLimitError(f"Rate limit exceeded. Retry after {retry_after} seconds")

        if response.status_code >= 400:
            raise NetworkError(
                f"HTTP {response.status_code}: {response.text[:200]}"
            )

        # Parse JSON response
        try:
            data = response.json()
        except ValueError:
            data = {"raw_response": response.text}

        return APIResponse(
            status_code=response.status_code,
            data=data,
            headers=dict(response.headers),
            success=200 <= response.status_code < 300
        )

    def get(
        self,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None
    ) -> APIResponse:
        """
        Perform GET request.

        Args:
            endpoint: API endpoint path
            params: Query parameters

        Returns:
            APIResponse object

        Raises:
            NetworkError: If request fails after retries
        """
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        logger.info(f"GET {url}")

        try:
            response = self.session.get(
                url,
                params=params,
                timeout=self.timeout
            )
            return self._handle_response(response)

        except requests.exceptions.Timeout:
            logger.error(f"Request timeout after {self.timeout}s: {url}")
            raise NetworkError(f"Request timeout: {url}")

        except requests.exceptions.RequestException as e:
            logger.error(f"Request failed: {e}")
            raise NetworkError(f"Network error: {str(e)}")

    def post(
        self,
        endpoint: str,
        data: Dict[str, Any],
        params: Optional[Dict[str, Any]] = None
    ) -> APIResponse:
        """
        Perform POST request.

        Args:
            endpoint: API endpoint path
            data: Request body data
            params: Query parameters

        Returns:
            APIResponse object

        Raises:
            NetworkError: If request fails after retries
        """
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        logger.info(f"POST {url}")

        try:
            response = self.session.post(
                url,
                json=data,
                params=params,
                timeout=self.timeout
            )
            return self._handle_response(response)

        except requests.exceptions.Timeout:
            logger.error(f"Request timeout after {self.timeout}s: {url}")
            raise NetworkError(f"Request timeout: {url}")

        except requests.exceptions.RequestException as e:
            logger.error(f"Request failed: {e}")
            raise NetworkError(f"Network error: {str(e)}")

    def close(self):
        """Close the session and cleanup resources."""
        self.session.close()
        logger.info("API client session closed")


def main():
    """
    Main function demonstrating API client usage.

    Returns:
        Exit code (0 for success, 1 for failure)
    """
    # Load configuration from environment variables
    api_key = os.getenv("API_KEY")
    base_url = os.getenv("API_BASE_URL", "https://api.example.com")

    if not api_key:
        logger.error("API_KEY environment variable not set")
        logger.error("Usage: export API_KEY='your_key' && python intermediate_api_client.py")
        return 1

    try:
        # Initialize client
        client = APIClient(
            base_url=base_url,
            api_key=api_key,
            timeout=30,
            max_retries=3
        )

        # Example: GET request
        logger.info("Fetching user data...")
        response = client.get("users/123")

        if response.success:
            logger.info(f"Success! User data: {response.data}")
        else:
            logger.error(f"Failed with status {response.status_code}")

        # Example: POST request
        logger.info("Creating new resource...")
        new_data = {
            "name": "Test Resource",
            "description": "Created via API client",
            "active": True
        }

        response = client.post("resources", data=new_data)

        if response.success:
            logger.info(f"Resource created: {response.data}")
        else:
            logger.error(f"Creation failed: {response.status_code}")

        # Cleanup
        client.close()
        return 0

    except AuthenticationError as e:
        logger.error(f"Authentication error: {e}")
        return 1

    except RateLimitError as e:
        logger.error(f"Rate limit error: {e}")
        return 1

    except NetworkError as e:
        logger.error(f"Network error: {e}")
        return 1

    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
