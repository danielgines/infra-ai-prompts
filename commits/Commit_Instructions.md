# Guia de Mensagens de Commit — Foco em **Primeiro Commit**, **Commit de Progresso** e **Reescrita de Histórico**

> Uso: este guia serve como **prompt de instruções** para outra IA gerar mensagens de commit profissionais.  
> Priorize o **MODO A (Primeiro Commit)**. Use o **MODO C (Commit de Progresso)** para analisar mudanças e sugerir mensagens sem aplicar. Use o **MODO B (Reescrita do histórico)** apenas quando explicitamente solicitado.

---

## 🎯 Objetivo

Gerar mensagens de commit padronizadas em **Conventional Commits**, claras e reprodutíveis, com comandos de aplicação via CLI.

---

## MODO A — **Primeiro Commit do Projeto** (padrão)

### 1) Confirmações rápidas (obrigatórias)

- Este é realmente o **primeiro commit** do repositório?
- Não há colaboradores impactados?
- O conteúdo a ser commitado está staged e revisado? (`git status`)

### 2) Regras de escrita (resumo)

- **Formato**: `<tipo>[escopo opcional]: <descrição>`
- **Header** ≤ 50 chars, modo imperativo, sem ponto final, idioma do projeto.
- **Body** (opcional): explique **por quê** e **o que** foi incluído; quebre linhas em ≤ 72 chars.
- **Rodapé** (quando aplicável): `BREAKING CHANGE: ...`, `Closes #123`.

### 3) Tipos e escopos recomendados para primeiro commit

**Tipos**: `feat`, `chore`, `build`, `docs`, `ci`, `refactor`, `test`.  
**Escopos comuns**: `core`, `setup`, `config`, `deps`, `db`, `api`, `cli`, `ci`, `docs`.

### 4) Classificação pelo conteúdo do commit

- Código + estrutura inicial → `feat(core): ...`
- Somente setup/estrutura de pastas/linters → `chore(setup): ...`
- Somente dependências/requirements/lock → `build(deps): ...`
- Somente documentação inicial → `docs: ...`
- Somente pipelines/CI → `ci: ...`

### 5) Modelos prontos (use e adapte)

**A) Estrutura completa inicial**

```
feat(core): implementa estrutura inicial do projeto

Adiciona arquitetura base e organização de diretórios.
Inclui configuração mínima de ferramentas e documentação inicial.
```

**B) Setup e configuração**

```
chore(setup): inicializa configuração do repositório

Define estrutura de pastas, linters, formatação e arquivos de suporte.
```

**C) Dependências**

```
build(deps): define dependências iniciais do projeto

Adiciona arquivo de requirements/lock e orientações de instalação.
```

**D) Documentação**

```
docs: adiciona documentação inicial do projeto

Inclui README com visão geral, instalação e uso básico.
```

### 6) Comandos de aplicação (CLI)

- **Ainda não existe commit** (primeiro commit será criado agora):
  ```bash
  git add -A
  git commit -m "tipo(escopo): descrição"
  git log -1 --oneline
  ```
- **Já existe um único commit** (amendar a mensagem do primeiro commit):
  ```bash
  git commit --amend -m "tipo(escopo): descrição"
  git log -1 --oneline
  git show --stat HEAD
  ```

### 7) Checklist final

- [ ] Tipo e escopo corretos
- [ ] Header conciso em modo imperativo
- [ ] Body somente se agrega contexto (por quê / o que)
- [ ] Sem termos genéricos ("first commit", "initial", "update")
- [ ] Mensagem coerente com os arquivos alterados

### 8) Formato de resposta esperado (saída da IA)

```
**Análise**
- Arquivos: [lista]
- Tipo: [feat/chore/build/docs/ci/...]
- Escopo: [core/setup/deps/...]
- Racional: [curto]

**Commit Sugerido**
tipo(escopo): descrição curta

[corpo opcional explicando por quê e o que foi incluído]

**Comando**
git commit -m "tipo(escopo): descrição"
# ou, se já houver 1 commit
git commit --amend -m "tipo(escopo): descrição"

**Status**: ✅ pronto para aplicar
```

---

## MODO B — **Reescrita do Histórico** (opcional; não usar em primeiro commit salvo exigência)

### 1) Alertas

- **Nunca** em repositório compartilhado sem consenso.
- Exige push forçado; pode quebrar forks/branches.

### 2) Backups mínimos

```bash
git log --oneline > commits_backup_$(date +%Y%m%d_%H%M%S).txt
git branch backup-before-rewrite-$(date +%Y%m%d_%H%M%S)
```

### 3) Fluxo seguro (resumo)

- Reescrever último commit: `git commit --amend -m "..."`
- Reescrever histórico desde a raiz (quando necessário):
  ```bash
  git rebase -i --root
  # marque commits como 'reword' para editar mensagens
  ```
- Validação:
  ```bash
  git log --oneline
  git fsck --full
  ```

### 4) Rollback

```bash
git reset --hard backup-before-rewrite-YYYYMMDD_HHMMSS
```

---

## MODO C — **Commit de Progresso** (análise de mudanças para próximo commit)

### 1) Contexto de uso

Use este modo quando o desenvolvedor:
- Já tem um repositório com histórico de commits
- Fez **diversas mudanças** no projeto (staged ou não)
- Precisa **apenas de uma sugestão** de mensagem de commit
- **NÃO quer** aplicar o commit ainda, apenas analisar e receber a mensagem pronta

### 2) Confirmações rápidas (obrigatórias)

- As mudanças estão prontas para análise? (verifique `git status` e `git diff`)
- Trata-se de um commit de progresso/evolução (não é o primeiro commit)?
- Você quer **apenas a sugestão** da mensagem, sem aplicar?

### 3) Processo de análise

A IA deve:
1. Analisar **todos os arquivos** modificados/adicionados/removidos
2. Identificar o **escopo** das mudanças (múltiplos arquivos/diretórios)
3. Determinar se as mudanças formam **um único commit coeso** ou devem ser **divididas**
4. Agrupar mudanças por **tipo** e **escopo** lógico
5. Sugerir mensagem(ns) de commit apropriada(s)

### 4) Regras de classificação (múltiplas mudanças)

**Quando criar UM único commit:**
- Mudanças relacionadas ao mesmo escopo/funcionalidade
- Refatoração uniforme em múltiplos arquivos
- Atualização de dependências + ajustes necessários
- Documentação + código da mesma feature

**Quando sugerir MÚLTIPLOS commits:**
- Features independentes adicionadas
- Fix de bug + nova feature não relacionada
- Mudanças em escopos completamente diferentes (`api` + `docs` + `ci`)
- Refactor + adição de testes + docs extensivos

### 5) Tipos e escopos para commits de progresso

**Tipos comuns**: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `build`, `ci`, `chore`.  
**Escopos dinâmicos**: identifique pelo contexto (`auth`, `user`, `payment`, `api`, `ui`, `config`, etc.).

### 6) Análise de impacto

Avalie e informe:
- **Breaking changes**: mudanças que quebram compatibilidade
- **Dependências**: novas libs, remoção de packages
- **Performance**: otimizações significativas
- **Segurança**: fixes de vulnerabilidades
- **Testes**: cobertura afetada

### 7) Formato de resposta esperado (saída da IA)

```
**Análise das Mudanças**
- Total de arquivos: [número]
- Arquivos modificados: [lista resumida]
- Arquivos adicionados: [lista resumida]
- Arquivos removidos: [lista resumida]
- Escopos identificados: [lista]
- Tipos de mudança: [lista]

**Recomendação**
[Um único commit] | [Dividir em X commits]

**Mensagem(ns) de Commit Sugerida(s)**

### Commit 1 (se aplicável)
```
tipo(escopo): descrição curta

[corpo explicando por quê e o que mudou]

[rodapé se necessário: BREAKING CHANGE, Closes #123]
```

### Commit 2 (se aplicável)
```
tipo(escopo): descrição curta

[corpo explicando por quê e o que mudou]
```

**Justificativa**
[Breve explicação da escolha de tipo, escopo e agrupamento]

**Próximos Passos (NÃO EXECUTAR)**
# Para aplicar o(s) commit(s) sugerido(s):
git add [arquivos específicos]
git commit -m "mensagem sugerida"

**Status**: 📝 sugestão pronta (não aplicada)
```

### 8) Checklist final (análise de progresso)

- [ ] Todas as mudanças foram analisadas
- [ ] Agrupamento lógico está correto
- [ ] Tipo e escopo refletem o impacto real
- [ ] Body explica o contexto (não apenas o "o quê")
- [ ] Breaking changes estão documentados
- [ ] Mensagem segue Conventional Commits
- [ ] Linguagem consistente com o projeto
- [ ] Sugestão clara de dividir commits quando necessário

### 9) Exemplos práticos

**Cenário A: Feature completa com testes e docs**
```
feat(auth): implementa autenticação JWT

Adiciona middleware de autenticação usando tokens JWT.
Inclui validação de refresh tokens e mecanismo de logout.
Atualiza documentação da API com novos endpoints.

Testes unitários e de integração incluídos.
```

**Cenário B: Múltiplos fixes independentes (DIVIDIR)**
```
Commit 1:
fix(api): corrige validação de email no cadastro

Adiciona regex mais robusto e mensagens de erro específicas.

Commit 2:
fix(ui): resolve problema de scroll no mobile

Ajusta viewport e comportamento do overflow em telas pequenas.
```

**Cenário C: Refatoração ampla**
```
refactor(core): reorganiza estrutura de módulos

Move utilitários para diretório dedicado e padroniza imports.
Melhora separação de responsabilidades entre camadas.

Sem mudanças de comportamento funcional.
```

---

## Anexo — **Conventional Commits (referência rápida)**

**Tipos**:

- `feat`: nova funcionalidade
- `fix`: correção de bug
- `docs`: documentação
- `style`: formatação (sem impacto lógico)
- `refactor`: refatoração (sem bugfix/feature)
- `perf`: performance
- `test`: testes
- `build`: build/dependências externas
- `ci`: integração contínua
- `chore`: tarefas que não alteram `src`/`tests`
- `revert`: reverte commit anterior

**Header**: imperativo, conciso, sem ponto final.  
**Body**: foco no **porquê** e **o que** (opcional).  
**Rodapé**: `BREAKING CHANGE: ...`, `Closes #123`.

---

## Seleção de Modo (orientação para IA)

**Identificar automaticamente:**
- "primeiro commit", "inicial", "setup inicial" → **MODO A**
- "reescrever", "alterar histórico", "amend anterior" → **MODO B**
- "analisar mudanças", "sugerir commit", "gerar mensagem", "próximo commit" → **MODO C**

**Padrão quando ambíguo**: **MODO A** se repositório vazio, **MODO C** se já existe histórico.

---

**Objetivo operacional**: padronizar a mensagem do **primeiro commit**, oferecer **análise inteligente para commits de progresso** sem aplicação automática, e quando necessário, fornecer um caminho seguro para **reescrita de histórico**, sempre via CLI.