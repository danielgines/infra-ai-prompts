# Checklist para Criação de Scripts Just

- [ ] Incluir comentários claros com `#` para documentar receitas e variáveis.
- [ ] Definir shell padrão com `set shell := ["bash", "-c"]`.
- [ ] Usar `set -e` em scripts shell dentro de receitas para abortar em erros.
- [ ] Declarar variáveis com nomes claros, minúsculas, e usar `{{var}}`.
- [ ] Criar receitas pequenas, com uma única responsabilidade.
- [ ] Documentar cada receita com comentário explicativo.
- [ ] Implementar receita para verificar pré-requisitos (ex.: usuários, comandos).
- [ ] Verificar existência de arquivos/diretórios antes de operações.
- [ ] Evitar operações redundantes com verificações condicionais (ex.: `cmp -s`).
- [ ] Definir permissões explicitamente com `chmod` e `chown`.
- [ ] Verificar status de serviços com `systemctl is-active`/`is-enabled` antes de agir.
- [ ] Usar `systemctl daemon-reload` após alterações em arquivos de unidade.
- [ ] Implementar logging com timestamps, redirecionando saídas para arquivo.
- [ ] Suportar modo verboso com variável `VERBOSE`.
- [ ] Validar argumentos de linha de comando e entradas externas.
- [ ] Evitar comandos perigosos sem validação prévia (ex.: `rm -rf`).
- [ ] Usar dependências entre receitas para orquestrar fluxos.
- [ ] Testar `justfile` com `just --check` para validar sintaxe.
- [ ] Garantir consistência nas mensagens e idioma.
- [ ] Evitar hardcoded paths, usando variáveis globais.

## Finalize com:
- [ ] Testar receitas em ambiente controlado.
- [ ] Revisar logs e saídas para garantir clareza.