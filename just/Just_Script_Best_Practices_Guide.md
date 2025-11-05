# Guia Completo de Boas Práticas para Criação de Scripts Just

## 1. Estrutura e Sintaxe
- Use sintaxe clara e idiomática do `just`, inspirada no `make`.
- Inicie com comentários explicativos usando `#` para documentar o propósito do `justfile`.
- Defina receitas (recipes) com nomes descritivos, evitando abreviações ambíguas.
- Use `@` antes de comandos para suprimir eco quando desejado, mantendo saída limpa.

## 2. Variáveis e Atribuições
- Declare variáveis com nomes claros, em letras minúsculas e com `_` para separação.
- Use `:=` para atribuições estáticas e `=` para dinâmicas (avaliadas em runtime).
- Sempre use variáveis entre chaves (`{{var}}`) para evitar ambiguidades.
- Defina variáveis globais no início do `justfile` para facilitar manutenção.

## 3. Receitas e Modularidade
- Crie receitas pequenas, cada uma com uma única responsabilidade.
- Documente cada receita com um comentário explicativo acima dela.
- Use dependências entre receitas para orquestrar fluxos complexos.
- Evite comandos longos; divida em múltiplas linhas com `\` para legibilidade.

## 4. Controle de Erros
- Use `set -e` em receitas shell para abortar em erros.
- Valide pré-condições (ex.: existência de arquivos) antes de executar ações.
- Forneça mensagens de erro claras via `echo` ou `exit` com status não-zero.
- Considere receitas específicas para verificações (ex.: `check-prereqs`).

## 5. Execução e Permissões
- Verifique permissões e dependências no início de receitas críticas.
- Evite executar comandos como `sudo` diretamente; documente se privilégios são necessários.
- Use `just --check` para validar a sintaxe do `justfile` antes de executar.

## 6. Manipulação de Arquivos
- Use comandos como `test -f` para verificar existência de arquivos antes de operações.
- Evite operações redundantes com verificações condicionais.
- Defina permissões explicitamente com `chmod` e `chown` quando necessário.

## 7. Interação com Ferramentas Externas
- Para systemd, verifique status com `systemctl is-active` antes de iniciar/habilitar serviços.
- Use `just` para orquestrar chamadas a ferramentas externas (ex.: `docker`, `kubectl`).
- Evite chamadas redundantes; verifique estado antes de agir.

## 8. Boas Práticas Gerais
- Mantenha receitas independentes e reutilizáveis.
- Use `just --list` para verificar receitas disponíveis durante desenvolvimento.
- Suporte modo silencioso (`@`) para saídas limpas e modo verboso com variável `export VERBOSE := "true"`.
- Carregue variáveis de ambiente de `.env` automaticamente com `just`.

## 9. Segurança e Confiabilidade
- Valide argumentos de linha de comando com verificações explícitas.
- Proteja arquivos sensíveis com permissões restritas.
- Teste receitas em ambiente controlado antes de usar em produção.
- Evite comandos perigosos (ex.: `rm -rf`) sem validação prévia.

## 10. Integração com Shell
- Use `bash` como shell padrão para receitas complexas, definindo `set shell := ["bash", "-c"]`.
- Combine com boas práticas de shell (ex.: `set -e`, variáveis com quotes).
- Evite subshells desnecessários para melhorar desempenho.

---

# Exemplos e Recomendações Rápidas

| Aspecto                | Prática Recomendada                                      |
|------------------------|---------------------------------------------------------|
| Comentários            | Use `#` para documentar receitas e variáveis            |
| Variáveis              | Nomes claros, minúsculos, com `{{var}}`                 |
| Receitas               | Pequenas, com uma única responsabilidade                |
| Dependências           | Declare dependências explicitamente                     |
| Erros                  | Use `set -e` e valide pré-condições                     |
| Permissões             | Verifique e ajuste com `chmod`/`chown`                  |
| Systemd                | Use `systemctl is-active`/`is-enabled` antes de agir    |
| Logging                | Redirecione saídas para logs com timestamps             |
| Debug                  | Suporte modo verboso com variável `VERBOSE`             |

---

# Referências Rápidas em Just

## Exemplo de Estrutura Básica
```just
# Justfile para gerenciamento de projeto
set shell := ["bash", "-c"]

# Variáveis globais
project_dir := `pwd`
log_dir := "/path/to/logs"
user := "app-user"

# Receita padrão
default:
  just --list

# Verificar pré-requisitos
check-prereqs:
  #!/bin/bash
  set -e
  if ! id {{user}} >/dev/null 2>&1; then
    echo "Erro: Usuário {{user}} não existe."
    exit 1
  fi
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "Erro: systemctl não encontrado."
    exit 1
  fi
```

## Exemplo de Receita com Dependências
```just
# Instalar e configurar serviço
deploy: check-prereqs copy-config start-service

copy-config:
  #!/bin/bash
  set -e
  src="config/app.conf"
  dest="/etc/app/app.conf"
  if [ -f "{{dest}}" ] && cmp -s "{{src}}" "{{dest}}"; then
    echo "Configuração já atualizada."
    exit 0
  fi
  cp "{{src}}" "{{dest}}"
  chmod 644 "{{dest}}"
  chown {{user}}:{{user}} "{{dest}}"

start-service:
  #!/bin/bash
  set -e
  service="app.service"
  if systemctl is-active "{{service}}" >/dev/null 2>&1; then
    echo "Serviço {{service}} já está ativo."
  else
    systemctl start "{{service}}"
  fi
```

## Exemplo de Logging e Modo Verboso
```just
# Variável para modo verboso
export VERBOSE := "false"

# Receita com logging
build:
  #!/bin/bash
  set -e
  log_file="{{log_dir}}/build.log"
  if [ "{{VERBOSE}}" = "true" ]; then
    echo "[$(date)] Iniciando build" | tee -a "{{log_file}}"
    make build | tee -a "{{log_file}}"
  else
    echo "[$(date)] Iniciando build" >> "{{log_file}}"
    make build >> "{{log_file}}" 2>&1
  fi
```