# Biblioteca de Prompts Técnicos para IA

**[English](README_EN.md)** | **Português**

Repositório com modelos de prompts, guias e checklists voltados para uso com IAs na geração e revisão de conteúdo técnico de infraestrutura: mensagens de commit, scripts just, scripts de shell e documentação Python.

O objetivo é padronizar o comportamento da IA para produzir saídas consistentes, seguras e alinhadas com boas práticas de DevOps/SRE e desenvolvimento Python.

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
├── python/
│   ├── Python_Docstring_Standards_Reference.md
│   ├── Code_Documentation_Instructions.md
│   ├── Comment_Cleanup_Instructions.md
│   ├── preferences/
│   │   ├── README.md
│   │   ├── preferences_template.md
│   │   └── examples/
│   │       └── daniel_gines_preferences.md
│   └── examples/
│       └── before_after_docstrings.md
├── readme/
│   ├── README_Standards_Reference.md
│   ├── New_README_Instructions.md
│   ├── Update_README_Instructions.md
│   └── examples/
│       └── before_after_readme.md
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

### `python/`

- **Python_Docstring_Standards_Reference.md**
  Referência completa de padrões de documentação Python: PEP 257, Google Style, NumPy Style e Sphinx. Base para todos os prompts de documentação Python.

- **Code_Documentation_Instructions.md**
  Template de prompt para padronizar docstrings em código Python. Suporta análise de projeto completo, módulos ou funções específicas.

- **Comment_Cleanup_Instructions.md**
  Template de prompt para limpar e melhorar comentários inline em código Python. Remove comentários óbvios, código comentado e melhora comentários essenciais.

- **preferences/**
  Sistema de preferências personalizáveis para convenções específicas de frameworks (Scrapy, Django, SQLAlchemy, FastAPI, etc.). Permite combinar prompts base com preferências pessoais ou de equipe.

  - **README.md**: Guia completo do sistema de preferências
  - **preferences_template.md**: Template vazio para copiar e customizar
  - **examples/daniel_gines_preferences.md**: Exemplo de preferências para Scrapy, SQLAlchemy e Alembic

- **examples/before_after_docstrings.md**
  Exemplos práticos de transformação de código mal documentado para código com documentação profissional.

### `readme/`

- **README_Standards_Reference.md**
  Base compartilhada com padrões modernos de documentação técnica. Estrutura de 24 seções essenciais, badges, formatação, inclusão condicional e boas práticas para README profissional.

- **New_README_Instructions.md**
  Template de prompt para gerar README completo do zero. Analisa repositório (dependências, entry points, configuração) e cria documentação baseada em evidências.

- **Update_README_Instructions.md**
  Template de prompt para atualizar README existente preservando conteúdo válido (licença, autores, contexto). Audita estado atual, corrige desatualizações e adiciona seções faltantes.

- **examples/before_after_readme.md**
  Exemplos práticos de transformação de READMEs para diferentes tipos de projeto (sem README → Scrapy completo, mínimo → FastAPI aprimorado, desatualizado → CLI corrigido).

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
   - Documentação Python → pasta `python/`
   - Documentação README → pasta `readme/`
   - Scripts `just` → pasta `just/`
   - Scripts Bash → pasta `shell/`

2. **Para commits, escolha o cenário específico:**
   - **Primeiro commit do repositório** → `First_Commit_Instructions.md`
   - **Commit durante desenvolvimento** (mais comum) → `Progress_Commit_Instructions.md`
   - **Reescrita de histórico** (avançado) → `History_Rewrite_Instructions.md`
   - **Referência de padrões** → `Conventional_Commits_Reference.md`

3. **Para Python, escolha a tarefa:**
   - **Padronizar docstrings** → `Code_Documentation_Instructions.md`
   - **Limpar comentários** → `Comment_Cleanup_Instructions.md`
   - **Adicionar preferências pessoais** → Copie `preferences/preferences_template.md` e customize
   - **Ver exemplos** → `examples/before_after_docstrings.md`
   - **Referência de padrões** → `Python_Docstring_Standards_Reference.md`

4. **Para README, escolha o cenário:**
   - **Criar README do zero** → `New_README_Instructions.md`
   - **Atualizar README existente** → `Update_README_Instructions.md`
   - **Ver exemplos de transformação** → `examples/before_after_readme.md`
   - **Referência de padrões** → `README_Standards_Reference.md`

5. **Para scripts (just/shell), selecione o tipo de documento:**
   - `Template_Prompt_...` → texto a ser colado diretamente na IA como prompt principal.
   - `...Best_Practices_Guide...` → referência técnica de como a saída deve ser estruturada.
   - `...Checklist...` → uso na revisão final do que foi gerado.

6. **Adapte ao contexto do projeto**
   - Ajuste nomes de serviços, paths, comandos específicos, ambientes (dev/stage/prod) e políticas internas.
   - Para Python: combine prompt base com arquivo de preferências se necessário (`cat base.md preferences.md`).

7. **Envie o prompt para a IA**
   - Use o template correspondente, incluindo contexto adicional do seu projeto quando necessário.

8. **Revise antes de aplicar**
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
