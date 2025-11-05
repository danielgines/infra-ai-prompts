# Guia de Mensagens de Commit — Foco no **Primeiro Commit**

> Uso: este guia serve como **prompt de instruções** para outra IA gerar mensagens de commit profissionais.  
> Priorize o **MODO A (Primeiro Commit)**. Use o **MODO B (Reescrita do histórico)** apenas quando explicitamente
> solicitado.

---

## 🎯 Objetivo

Gerar mensagens de commit padronizadas em **Conventional Commits**, claras e reprodutíveis, com comandos de aplicação
via CLI.

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
- [ ] Sem termos genéricos (“first commit”, “initial”, “update”)
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

**Objetivo operacional**: padronizar a mensagem do **primeiro commit** e, quando necessário, oferecer um caminho seguro
para reescrita posterior, sempre via CLI.
