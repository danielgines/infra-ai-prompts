# Biblioteca de Prompts Técnicos para IA

Repositório com modelos de prompts, guias e checklists voltados para uso com IAs na geração e revisão de conteúdo técnico de infraestrutura: mensagens de commit, scripts just e scripts de shell.

O objetivo é padronizar o comportamento da IA para produzir saídas consistentes, seguras e alinhadas com boas práticas de DevOps/SRE.

---

## Estrutura do repositório

```text
.
├── commits/
│   ├── Conventional_Commits_Reference.md
│   ├── First_Commit_Instructions.md
│   ├── Progress_Commit_Instructions.md
│   └── History_Rewrite_Instructions.md
├── just/
│   ├── Just_Script_Best_Practices_Guide.md
│   ├── Just_Script_Checklist.md
│   ├── Makefile_to_Just_Migration_Guideline.md
│   └── Template_Prompt_IA_Just_Script_Generation.md
├── readme/
│   └── Template_Prompt_IA_README_Creation_Update.md
├── README.md
└── shell/
    ├── Shell_Script_Best_Practices_Guide.md
    ├── Shell_Script_Checklist.md
    └── Template_Prompt_IA_Shell_Script_Generation.md
```

### `commits/`

- **Conventional_Commits_Reference.md**
  Base compartilhada com padrões de Conventional Commits. Referência para todos os templates de commit.

- **First_Commit_Instructions.md**
  Template de prompt para geração de mensagem do primeiro commit do repositório.

- **Progress_Commit_Instructions.md**
  Template de prompt para análise de mudanças e geração de mensagens de commit durante desenvolvimento ativo (uso mais frequente).

- **History_Rewrite_Instructions.md**
  Template de prompt para reescrita segura de histórico Git com mensagens padronizadas (uso avançado e raro).

### `just/`

- **Makefile_to_Just_Migration_Guideline.markdown**  
  Guia técnico para migrar de `Makefile` para `just`, com recomendações de sintaxe, estrutura e comportamento.

- **Just_Script_Best_Practices_Guide.markdown**  
  Boas práticas para escrever receitas `just` (uso de `set shell`, `set -e`, dependências, validações, logging, etc.).

- **Just_Script_Checklist.markdown**  
  Checklist para revisão rápida de scripts `just` antes de uso em produção.

- **Template_Prompt_IA_Just_Script_Generation.markdown**  
  Template de prompt para orientar a IA na geração de `justfile` seguindo as boas práticas definidas no guia.

### `shell/`

- **Shell_Script_Best_Practices_Guide.md**  
  Boas práticas para scripts Bash (shebang, `set -e`, funções, tratamento de erro, permissões, systemd, logging, etc.).

- **Shell_Script_Checklist.md**  
  Checklist de validação para scripts de shell antes de uso em ambientes críticos.

- **Template_Prompt_IA_Shell_Script_Generation.md**  
  Template de prompt para orientar a IA na geração de scripts Bash alinhados ao guia de boas práticas.

---

## Como usar estes arquivos

1. **Escolha a área**
   - Mensagens de commit → pasta `commits/`
   - Scripts `just` → pasta `just/`
   - Scripts Bash → pasta `shell/`

2. **Para commits, escolha o cenário específico:**
   - **Primeiro commit do repositório** → `First_Commit_Instructions.md`
   - **Commit durante desenvolvimento** (mais comum) → `Progress_Commit_Instructions.md`
   - **Reescrita de histórico** (avançado) → `History_Rewrite_Instructions.md`
   - **Referência de padrões** → `Conventional_Commits_Reference.md`

3. **Para scripts (just/shell), selecione o tipo de documento:**
   - `Template_Prompt_...` → texto a ser colado diretamente na IA como prompt principal.
   - `...Best_Practices_Guide...` → referência técnica de como a saída deve ser estruturada.
   - `...Checklist...` → uso na revisão final do que foi gerado.

4. **Adapte ao contexto do projeto**
   - Ajuste nomes de serviços, paths, comandos específicos, ambientes (dev/stage/prod) e políticas internas.

5. **Envie o prompt para a IA**
   - Use o template correspondente, incluindo contexto adicional do seu projeto quando necessário.

6. **Revise antes de aplicar**
   - Valide a saída gerada usando a checklist da pasta correspondente (quando aplicável).
   - Só depois aplique o script/mudança em repositórios ou ambientes reais.

---

## Escopo e foco técnico

Os prompts e guias deste repositório seguem os seguintes princípios:

- Geração de saídas reprodutíveis e idempotentes sempre que possível.  
- Foco em segurança operacional (permissões, uso de `sudo`, systemd, validações).  
- Padronização de nomenclaturas, mensagens de log e estrutura de scripts.  
- Evitar decisões “criativas” e manter comportamento previsível.

---

## Contribuições

Ajustes técnicos e melhorias são bem-vindos, desde que:

- Mantenham o foco em uso profissional (infra/DevOps/SRE).  
- Não quebrem a compatibilidade com os prompts já utilizados.  
- Respeitem a estrutura de diretórios e a separação entre templates, guias e checklists.

---

## Autor

- **Daniel Ginês**
