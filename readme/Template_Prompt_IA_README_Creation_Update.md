# Template_Prompt_IA_README_Creation_Update — Commit‑Ready

> Instruções para uma IA **gerar um README completo e pronto para commit**, sem TODOs, mantendo a integridade do README existente quando houver, e documentando **fluxos** e **serviços/timers** somente quando comprovados no repositório.

---

## 1) Objetivo
Produzir um `README.md` **final**, coerente com o código **sem suposições**, sem notas internas, sem “TODO”, sem comentários fora do texto do README. O resultado deve poder ser commitado imediatamente.

---

## 2) Fonte de verdade (usar somente o repositório)
- Arquivos de configuração e dependências (`pyproject.toml`, `requirements*.txt`, `package.json`, `go.mod`, etc.).
- Orquestração/execução (`justfile`, `Makefile`, `docker-compose*.yml`, `Procfile`, `scripts/`, `bin/`).
- Pontos de entrada (`cli.py`, `main.py`, `*.sh` com shebang).
- Schedulers/serviços **existentes no repo**:  
  - **systemd** (`*.service`, `*.timer`), **cron** (arquivos cron versionados), **Kubernetes** (`CronJob`, `Job`), **CI/CD** (`.github/workflows/*.yml`, etc.).
- Código-fonte (para nomes reais de comandos/targets e parâmetros).
- Arquivos `.env.example` ou variáveis em `settings/config` para listar variáveis de ambiente.

**Proibido** usar informações externas ou inventadas.

---

## 3) Modo de execução
1. **Detectar** se há `README.md`:
   - **MODO A (criação)**: se não existir.
   - **MODO B (atualização conservadora)**: se existir.
2. **Idioma**: manter o idioma do README existente; caso não exista, usar **PT‑BR**.
3. **Integridade**:
   - Preservar licença, créditos, avisos legais, histórico específico.
   - Atualizar somente o necessário para refletir o estado atual.
   - Não duplicar seções válidas; reorganizar apenas quando melhora a leitura sem perda.

---

## 4) Descoberta (mínima e verificável)
Execute buscas **apenas** para confirmar evidências no repo:
- Dependências/CLIs: `grep -RInE "(bash|sh|python|node|just|make)[[:space:]]" .`
- Makefile/justfile: mapear alvos/receitas e dependências.
- Python CLI: procurar `argparse|click|typer` e `if __name__ == '__main__'`.
- Schedulers/serviços: localizar `*.service`, `*.timer`, `CronJob`, Workflows CI.

Se **não** houver evidência versionada de algo, **omita** a seção correspondente (não escrever TODO).

---

## 5) Estrutura do README (seções e regras)
Inclua **apenas** seções suportadas por evidência:

1. **Título do projeto**
2. **Descrição breve** (2–4 linhas, objetiva, técnica)
3. **Sumário** (incluir quando o README for longo)
4. **Requisitos/Dependências**
5. **Instalação/Setup** (comandos reais e executáveis)
6. **Uso (CLI)** — comandos existentes no código/scripts
7. **Configuração** — variáveis de ambiente reais; mascarar segredos
8. **Fluxo de Dependências entre Scripts** *(condicional)*  
   - Liste a ordem de execução **somente** quando inferível por código/targets.  
   - Opcional: diagrama Mermaid `flowchart` **apenas se totalmente derivado do repo**.
9. **Serviços e Timers Agendados** *(condicional)*  
   - Incluir **somente** quando houver manifests versionados (systemd/cron/K8s/CI).  
   - Tabela com colunas: `Nome | Tipo | Arquivo/Local | Comando/EntryPoint | Agenda | Timezone | Dependências | Retries/Backoff | Timeout | Logs | Alertas/Healthcheck | Owner`.  
   - Preencha **apenas** campos confirmáveis nos arquivos.
10. **Testes** *(condicional)* — se houver estrutura de testes/targets
11. **Logs e Observabilidade** *(condicional)* — paths/comandos configurados no repo
12. **Estrutura do Projeto** — resumo de diretórios relevantes (existentes)
13. **Notas de Operação/Manutenção** *(condicional)* — apenas quando houver instruções versionadas
14. **Licença** — se arquivo de licença existir

**Nunca** incluir placeholders enganosos; quando inevitáveis e padrão (ex.: `<repository-url>`), use-os **com parcimônia**.

---

## 6) Regras de redação
- Sem “TODO”, “NOTE”, “ATENÇÃO” internas para o autor.  
- Sem comentários metadiscursivos (“modo detectado”, “resumo da auditoria”).  
- Markdown válido (títulos hierárquicos, listas, blocos de código, links relativos funcionais).  
- Comandos devem ser **executáveis** conforme arquivos do repo.  
- Variáveis sensíveis: referencie por nome; **não** expor valores.

---

## 7) Critérios para **Fluxo** e **Serviços**
- **Fluxo**: só gerar se a cadeia entre scripts/alvos for clara no código/receitas. Caso parcial, **omitir a seção**.  
- **Serviços/Timers**: só gerar tabela se houver manifests versionados. Se não houver manifests, **omitir a seção**.

---

## 8) Validações obrigatórias antes de finalizar
- [ ] Cada comando existe no repo (script/target/entrypoint).
- [ ] Cada arquivo/pasta referenciado existe.
- [ ] Links e âncoras funcionam.
- [ ] Sem segredos expostos.
- [ ] Sem TODOs/observações internas.
- [ ] Texto em PT‑BR (ou idioma original), técnico e objetivo.
- [ ] Licença/créditos/avisos preservados quando presentes.

---

## 9) **Formato de saída (exigido)**
**Entregue apenas o conteúdo final do `README.md`**, em um único bloco Markdown, **sem qualquer texto adicional** (sem análise, sem modo detectado, sem resumo).

---

## 10) Heurísticas de inclusão/omissão (decisão rápida)
- Se **manifesto de serviço/timer** está versionado → **incluir** seção “Serviços e Timers”. Caso contrário → **omitir**.
- Se **cadeia de execução** entre scripts/alvos é rastreável em código/receitas → **incluir** “Fluxo de Dependências” (com Mermaid opcional). Caso contrário → **omitir**.
- Se não há testes/CI no repo → **omitir** seção de testes/CI.
- Se não há `.env.example` nem variáveis mapeadas → **limitar** a “Configuração” ao que for evidente nos arquivos.

---

## 11) Exigências de consistência
- Usar nomes de spiders/targets/serviços **exatamente** como definidos nos arquivos.  
- Manter a **nomenclatura** de filas, envs e paths conforme encontrados.  
- Não criar comandos genéricos que não existam.

---

## 12) Segurança
- Nunca copiar valores de chaves/senhas encontrados em histórico.  
- Se encontrar segredo em texto claro no repo, **não** mencione o valor; apenas descreva a variável de ambiente correspondente.

---

## 13) Saída esperada
Um `README.md` **commit‑ready**, coerente, sem pendências ou comentários, refletindo **exatamente** o estado do repositório.
