# Template de Prompt para IA Gerar Scripts Shell Seguindo Boas Práticas

Crie um script Bash que:

1. Use shebang `#!/bin/bash` e inclua `set -e` para abortar em caso de erro.
2. Utilize variáveis com nomes claros e expansões sempre entre double quotes.
3. Declare variáveis internas com `local` dentro de funções para evitar poluição global.
4. Evite uso desnecessário de subshells para melhor legibilidade e eficiência.
5. Separe a lógica em funções pequenas e documentadas, com funções para:
   - Checagem de privilégios (ex: root).
   - Verificação da existência de arquivos, usuários, grupos e comandos necessários.
   - Ajuste de permissões de arquivos e diretórios.
   - Cópia e atualização de arquivos somente quando necessário (usando comparação antes).
   - Gerenciamento de serviços via systemd com verificação de status antes de habilitar/iniciar.
   - Validação de arquivos críticos como sudoers, garantindo sintaxe correta.
6. Implemente uma função genérica para tratamento de erros que exiba mensagens descritivas e encerre o script.
7. Faça logging detalhado da execução, redirecionando stdout/stderr para um arquivo com timestamps.
8. Forneça mensagens claras, consistentes e informativas para o usuário ao longo da execução.
9. Evite múltiplas checagens repetitivas para o mesmo item; faça validações agrupadas quando possível.
10. Inclua opção para executar em modo debug que imprime informações adicionais.
11. Use variáveis para paths base, nomes de arquivos e parâmetros configuráveis.
12. Utilize padrões idiomáticos do Bash para estruturação das condições e loops.