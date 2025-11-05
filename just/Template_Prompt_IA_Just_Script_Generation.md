# Template de Prompt para IA Gerar Scripts Just Seguindo Boas Práticas

Crie um script `justfile` que:

1. Use sintaxe idiomática do `just`, inspirada no `make`, com comentários claros usando `#`.
2. Defina o shell padrão como `set shell := ["bash", "-c"]` e inclua `set -e` em scripts shell para abortar em erros.
3. Declare variáveis globais com nomes claros (minúsculas, com `_`) e use `{{var}}` para expansões.
4. Crie receitas pequenas, cada uma com uma única responsabilidade, documentadas com comentários.
5. Implemente receitas para:
   - Verificar pré-requisitos (ex.: existência de usuários, comandos, arquivos).
   - Ajustar permissões de arquivos/diretórios com `chmod` e `chown`.
   - Copiar/atualizar arquivos apenas se necessário, usando comparações (ex.: `cmp -s`).
   - Gerenciar serviços via systemd, verificando status com `systemctl is-active`/`is-enabled` antes de iniciar/habilitar.
   - Validar arquivos críticos (ex.: usar `visudo -c` para arquivos sudoers).
6. Inclua uma receita padrão (`default`) que execute `just --list`.
7. Implemente uma função genérica para tratamento de erros em receitas shell, com mensagens claras e saída com status não-zero.
8. Suporte logging detalhado, redirecionando saídas para um arquivo com timestamps.
9. Forneça mensagens claras e consistentes para o usuário durante a execução.
10. Inclua suporte a modo verboso com uma variável `export VERBOSE := "false"`.
11. Evite operações redundantes e valide pré-condições antes de ações.
12. Use dependências entre receitas para orquestrar fluxos complexos.
13. Valide argumentos de linha de comando e entradas externas para segurança.
14. Teste a sintaxe do `justfile` com `just --check` antes de usar.