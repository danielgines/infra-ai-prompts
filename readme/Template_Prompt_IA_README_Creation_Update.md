# Prompt para Atualização/Criação de README com Fluxos, Serviços e Timers

## Objetivo
Atualizar **ou** criar um `README.md` aderente ao estado atual do projeto, preservando a integridade do conteúdo existente, documentando **fluxos de dependências entre scripts** e **serviços/timers agendados**, com foco em uso via **CLI**. Não inventar informações.

---

## Instruções de atuação (resumo)
1. Detecte se já existe `README.md`.
2. **MODO A (sem README):** crie do zero seguindo a estrutura indicada.
3. **MODO B (com README):** audite, compare com o projeto e atualize **conservadoramente**.
4. Em ambos os modos:
   - Documente **fluxo de dependências** entre scripts.
   - Documente **serviços/timers agendados** em **tabela**.
   - Não altere licença, créditos ou avisos legais.
   - Mantenha o idioma principal do repositório (ou PT-BR se ausente).

---

## Regras de integridade e conservadorismo
- **Não inventar** comandos, flags, endpoints, variáveis de ambiente, roadmaps ou integrações.
- **Preservar**: licença, créditos/autoria, avisos legais, histórico relevante.
- **Minimizar mudanças** quando houver README: reescrever apenas o necessário para corrigir desatualizações, lacunas e incoerências.
- **Marcar TODO** quando houver dúvida factual que não possa ser confirmada nos arquivos do repositório.
- **Não expor segredos** (tokens, senhas, chaves). Se encontrados em texto, instruir a removê-los e referenciar variáveis de ambiente.

---

## Coleta de contexto do projeto (obrigatória antes de escrever)
Mapeie, a partir do repositório:
- Linguagem e ferramentas: `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Cargo.toml`, etc.
- Orquestração/execução: `justfile`, `Makefile`, `docker-compose*.yml`, `Procfile`, `scripts/`, `bin/`.
- Pontos de entrada CLI (ex.: `cli.py`, `main.py`, shebangs em `*.sh`).
- Agendamentos/serviços:
  - **cron**: `crontab`, arquivos em `/etc/cron*` (se presentes no repo), manifestos infra-as-code.
  - **systemd**: `*.service`, `*.timer` (em `ops/`, `deploy/`, etc.).
  - **Kubernetes**: `CronJob` (`spec.schedule`) e `Job`.
  - **CI/CD**: `.github/workflows/*.yml`, GitLab CI, etc.
  - **Schedulers de app**: Celery Beat, APScheduler, Airflow, Dagster (DAGs/crons).
- Dependências entre scripts (chamadas internas): varra fontes por execuções de `bash/sh/python/node`, `just`, `make`, `invoke`, etc.

**Dicas técnicas de varredura (ilustrativas, só se aplicáveis ao repo):**
- Buscar dependências: `grep -RInE "(bash|sh|python|node|just|make)[[:space:]]" .`
- Alvos Make: analisar alvos e pré-requisitos.
- Justfile: mapear receitas e dependências implícitas.
- Python: procurar `if __name__ == '__main__'` e `argparse`/`typer`/`click` para comandos.

---

## Estrutura mínima do README (ajuste ao tipo de projeto)
1. **Título**
2. **Descrição breve** (2–4 linhas, objetiva)
3. **Índice/Sumário** (se o documento for longo)
4. **Requisitos/Dependências**
5. **Instalação/Setup**
6. **Uso (CLI)** – comandos reais com exemplos mínimos executáveis
7. **Configuração** – variáveis de ambiente, arquivos de config
8. **Fluxo de Dependências entre Scripts**
   - Lista ordenada das etapas e dependências.
   - Opcional: diagrama Mermaid `flowchart` coerente com o código (não inventar).
9. **Serviços e Timers Agendados**
   - **Tabela obrigatória** com colunas:
     - `Nome` | `Tipo` (cron/systemd/cronjob/ci/etc.) | `Arquivo/Local` | `Comando/EntryPoint`
     - `Agenda` (cron/ISO) | `Timezone` | `Dependências` | `Retries/Backoff` | `Timeout`
     - `Recursos` (CPU/Mem, se aplicável) | `Logs` (arquivo/comando) | `Alertas/Healthcheck` | `Owner`
10. **Testes**
11. **Logs e Observabilidade** (paths/consultas básicas, se houver)
12. **Estrutura do Projeto** (resumo por diretórios relevantes)
13. **Notas de Operação/Manutenção** (se houver)
14. **Licença**

> Se algum item não existir no projeto, omitir a seção ou inserir **TODO** claro e justificável (sem suposições).

---

## MODO A — Sem README (criação)
- Construir o documento seguindo a estrutura mínima.
- Preencher apenas com dados verificáveis nos arquivos do repo.
- Nos trechos de fluxo e serviços/timers:
  - Descrever somente o que estiver confirmado em código/manifestos.
  - Se parcial/incompleto, listar **TODOs** específicos.

## MODO B — Com README (atualização)
1. **Auditar** o README atual:
   - Idioma, público-alvo, seções existentes, coerência com o código.
   - Pontos sensíveis: licença, créditos, avisos legais, histórico.
2. **Verificar aderência**:
   - Comandos de execução/build/test/deploy vigentes (ex.: migração de Make→Just).
   - Estrutura de diretórios e nomes de serviços.
   - Fluxos entre scripts e agendamentos presentes no repo.
3. **Ajustar conservadoramente**:
   - Atualizar comandos e caminhos quebrados.
   - Inserir as seções de **Fluxo** e **Serviços/Timers** se ausentes.
   - Melhorar formatação e clareza **sem** alterar o significado.
4. **Não remover** seções úteis; se obsoletas, marcar como **Obsoleto** com nota curta.

---

## Formato de saída esperado (obrigatório)
Entregue **nesta ordem**:
1. **Modo detectado**: `MODO A` ou `MODO B`.
2. **Resumo da auditoria** (itens objetivos encontrados e lacunas).
3. **README proposto (conteúdo completo)** em um único bloco Markdown pronto para salvar como `README.md`.
4. **Resumo das mudanças** (somente se `MODO B`): listar o que foi atualizado/adicionado/removido e o motivo.
5. **Anexos opcionais** em linha:
   - Bloco Mermaid `flowchart` do fluxo (se aplicável).
   - Tabela Markdown de serviços/timers.

---

## Checklist final (validar antes de entregar)
- [ ] Idioma consistente; estilo técnico, sem marketing.
- [ ] Nenhum segredo exposto; variáveis de ambiente documentadas quando necessário.
- [ ] Comandos e exemplos **executáveis** e coerentes com o repo.
- [ ] Fluxo de dependências **reflete o código**; sem suposições.
- [ ] Tabela de serviços/timers completa com colunas exigidas, quando aplicável.
- [ ] Licença/créditos/avisos **inalterados**.
- [ ] Links, âncoras, formatação Markdown corretos.
- [ ] Alterações mínimas quando já havia README.

---

## Observações
- Priorize CLI e automações; não descreva GUIs salvo evidência no repo.
- Se o projeto for multilíngue, mantenha o idioma do README original; se inexistente, use PT-BR.
- Em caso de conflito entre README antigo e código atual, **o código vence**; documente a correção no resumo das mudanças.
