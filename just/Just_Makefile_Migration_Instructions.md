# Guia Genérico para Migração de Makefiles para Justfiles

Este guia revisado orienta a migração de um `Makefile` para um `justfile`, incorporando lições aprendidas com problemas comuns, como comandos compostos e formatação de saída, mantendo boas práticas do `just` (https://just.systems/man/en/introduction.html) e shell script. É projetado para ser genérico e aplicável a diversos projetos.

## 1. Planejamento da Migração
- **Analise o Makefile**: Identifique variáveis, alvos (targets), dependências, funções e comandos compostos (ex.: `make service action`).
- **Mapeie funcionalidades**: Converta alvos em receitas (`recipes`) e comandos compostos em receitas parametrizadas.
- **Preserve semântica**: Mantenha a lógica e comportamento do `Makefile`, adaptando à sintaxe do `just`.
- **Priorize comandos principais**: Foque em alvos como `help`, `default`, e fluxos críticos (ex.: `start`, `stop`).

## 2. Estrutura e Sintaxe
- **Inicie com comentários**: Use `#` para descrever o propósito do `justfile` e suas receitas.
- **Defina o shell padrão**: Use `set shell := ["bash", "-c"]` para consistência.
- **Use `set -e` em scripts shell**: Garanta que receitas shell abortem em erros.
- **Crie receita padrão**: Implemente `default: just --list` para listar comandos.

## 3. Conversão de Variáveis
- **Migre variáveis**: Converta variáveis do `Makefile` (ex.: `VAR = value`) para `just` com `:=` (estáticas) ou `=` (dinâmicas).
- **Use nomes claros**: Prefira letras minúsculas com `_` (ex.: `project_dir`).
- **Expansão de variáveis**: Use `{{var}}` para todas as expansões.
- **Evite hardcoded paths**: Use variáveis globais para caminhos e parâmetros.
- **Exemplo**:
  ```just
  project_dir := `pwd`
  config_dir := "kubernetes/config"
  ```

## 4. Conversão de Alvos (Targets) para Receitas
- **Mapeie alvos para receitas**: Converta alvos `.PHONY` em receitas, preservando dependências.
- **Suporte comandos compostos**: Para alvos como `make service action`, crie receitas parametrizadas (ex.: `service action:`) que usem `case` ou `if` para direcionar ações.
- **Use `@` para saídas limpas**: Suprima eco de comandos com `@` quando apropriado.
- **Divida comandos longos**: Use `\` para quebrar linhas longas.
- **Exemplo**:
  ```just
  service action:
    #!/bin/bash
    set -e
    case "{{action}}" in
      start) just service-start ;;
      stop) just service-stop ;;
      *) echo "[$(date)] ❌ Invalid action: {{action}}"; exit 1 ;;
    esac
  ```

## 5. Tratamento de Funções e Lógica Condicional
- **Converta funções do Makefile**: Substitua funções como `$(if ...)` ou `$(call ...)` por scripts shell com `if`/`else` ou `case`.
- **Centralize validações**: Crie receitas como `validate-service` para verificações reutilizáveis.
- **Exemplo**:
  ```just
  validate-service service:
    #!/bin/bash
    set -e
    if [[ "{{service}}" != "valid1" && "{{service}}" != "valid2" ]]; then
      echo "[$(date)] ❌ Invalid service: {{service}}"
      exit 1
    fi
  ```

## 6. Controle de Erros
- **Valide pré-condições**: Verifique comandos (ex.: `command -v kubectl`), arquivos (ex.: `test -f`) e permissões antes de ações.
- **Centralize erros**: Crie uma receita `check-error` para verificar códigos de saída.
- **Use mensagens claras**: Inclua timestamps em mensagens de erro e sucesso.
- **Exemplo**:
  ```just
  check-error status message:
    #!/bin/bash
    set -e
    if [ "{{status}}" -ne 0 ]; then
      echo "[$(date)] ❌ Error: {{message}}"
      exit 1
    fi
  ```

## 7. Gerenciamento de Permissões
- **Verifique privilégios**: Use `if [ "$EUID" -ne 0 ]; ...` para verificar execução como root, se necessário.
- **Ajuste permissões**: Use `chmod` e `chown` explicitamente em receitas.
- **Evite `sudo` interno**: Documente a necessidade de privilégios, mas evite chamadas automáticas.

## 8. Manipulação de Arquivos
- **Verifique existência**: Use `test -f` ou `test -d` antes de operações.
- **Evite redundâncias**: Use `cmp -s` para comparar arquivos antes de copiar/atualizar.
- **Exemplo**:
  ```just
  copy-config src dest:
    #!/bin/bash
    set -e
    if [ -f "{{dest}}" ] && cmp -s "{{src}}" "{{dest}}"; then
      echo "[$(date)] Arquivo {{dest}} já atualizado."
      exit 0
    fi
    cp "{{src}}" "{{dest}}"
    chmod 644 "{{dest}}"
  ```

## 9. Interação com Systemd e Kubernetes
- **Systemd**: Verifique status com `systemctl is-active`/`is-enabled` antes de ações.
- **Kubernetes**: Converta comandos `kubectl`/`helm` para receitas, validando estados.
- **Exemplo**:
  ```just
  start-service service:
    #!/bin/bash
    set -e
    if systemctl is-active "{{service}}" >/dev/null 2>&1; then
      echo "[$(date)] Serviço {{service}} já ativo."
    else
      systemctl start "{{service}}"
    fi
  ```

## 10. Logging e Saídas
- **Redirecione saídas**: Use `tee -a` para logs com timestamps no modo verboso e `>>` no modo silencioso.
- **Suporte modo verboso**: Use `export VERBOSE := "false"` e condicione saídas.
- **Evite códigos ANSI brutos**: Use `tput` para cores (ex.: `$(tput setaf 3)`) ou formatação simples.
- **Exemplo**:
  ```just
  export VERBOSE := "false"
  build:
    #!/bin/bash
    set -e
    log_file="logs/build.log"
    if [ "{{VERBOSE}}" = "true" ]; then
      echo "[$(date)] Iniciando build" | tee -a "{{log_file}}"
      make build | tee -a "{{log_file}}"
    else
      echo "[$(date)] Iniciando build" >> "{{log_file}}"
      make build >> "{{log_file}}" 2>&1
    fi
  ```

## 11. Suporte a Argumentos
- **Use receitas parametrizadas**: Defina parâmetros (ex.: `scale replicas:`) e valide argumentos.
- **Exemplo**:
  ```just
  scale replicas:
    #!/bin/bash
    set -e
    if ! [[ "{{replicas}}" =~ ^[0-9]+$ ]]; then
      echo "[$(date)] ❌ Número de réplicas inválido: {{replicas}}"
      exit 1
    fi
    kubectl scale deployment app --replicas={{replicas}}
  ```

## 12. Testes e Validação
- **Valide sintaxe**: Use `just --check` para verificar erros.
- **Teste em ambiente controlado**: Execute receitas em ambiente de teste.
- **Revise logs**: Garanta que mensagens e logs sejam claros.

## 13. Boas Práticas Gerais
- **Evite complexidade**: Mantenha receitas simples e focadas.
- **Use dependências**: Orquestre fluxos com dependências entre receitas.
- **Documente tudo**: Inclua comentários para receitas e variáveis.
- **Evite hardcoded values**: Use variáveis para manutenção.

## 14. Exemplo de Migração
### Makefile (original):
```make
VARIABLE = value
target: dep
	@echo "Running target..."
	command1
	command2
```

### Justfile (migrado):
```just
# Justfile para projeto
set shell := ["bash", "-c"]

variable := "value"

# Receita padrão
default:
  just --list

# Dependência
dep:
  #!/bin/bash
  set -e
  echo "[$(date)] Executando dependência..."

# Receita principal
target: dep
  #!/bin/bash
  set -e
  echo "[$(date)] Running target..."
  command1
  command2
```

## 15. Checklist para Validação
- [ ] Converter variáveis do `Makefile` para `just` com `:=` ou `=`.
- [ ] Mapear alvos `.PHONY` para receitas, preservando dependências.
- [ ] Suportar comandos compostos com receitas parametrizadas (ex.: `service action:`).
- [ ] Substituir funções do `Makefile` por scripts shell com `set -e`.
- [ ] Adicionar verificações de pré-condições (arquivos, comandos, permissões).
- [ ] Implementar logging com timestamps e modo verboso.
- [ ] Evitar códigos ANSI brutos; usar `tput` ou formatação simples.
- [ ] Validar argumentos e entradas externas.
- [ ] Testar `justfile` com `just --check`.
- [ ] Garantir mensagens claras e consistentes.
- [ ] Documentar todas as receitas e variáveis.

## 16. Prompt para IA
Crie um `justfile` que:
1. Converta todas as variáveis do `Makefile` para variáveis `just` com nomes claros e expansões via `{{var}}`.
2. Mapeie alvos `.PHONY` para receitas, preservando dependências.
3. Suporte comandos compostos (ex.: `make service action`) com receitas parametrizadas (ex.: `service action:`) usando `case` ou `if` para direcionar ações.
4. Substitua funções do `Makefile` por scripts shell com `set -e` e verificações de erro.
5. Inclua uma receita `default` que execute `just --list`.
6. Adicione verificações de pré-condições (ex.: arquivos, comandos, permissões).
7. Suporte logging com timestamps, redirecionando saídas para um arquivo com `tee -a` (modo verboso) ou `>>` (modo silencioso).
8. Inclua modo verboso com variável `export VERBOSE := "false"`.
9. Evite códigos de escape ANSI brutos; use `tput` para cores ou formatação simples.
10. Valide argumentos de linha de comando e entradas externas.
11. Use `set shell := ["bash", "-c"]` para consistência.
12. Documente todas as receitas e variáveis com comentários claros.
13. Teste a sintaxe com `just --check` antes de finalizar.