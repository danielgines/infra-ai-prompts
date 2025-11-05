# Biblioteca de Prompts Técnicos para IA

Repositório com modelos de prompts, guias e checklists voltados para uso com IAs na geração e revisão de conteúdo técnico de infraestrutura: mensagens de commit, scripts just e scripts de shell.

O objetivo é padronizar o comportamento da IA para produzir saídas consistentes, seguras e alinhadas com boas práticas de DevOps/SRE.

---

## Estrutura do repositório

```text
.
├─ commits/
│  └─ Commit_Instructions.md
│
├─ just/
│  ├─ Makefile_to_Just_Migration_Guideline.markdown
│  ├─ Just_Script_Best_Practices_Guide.markdown
│  ├─ Just_Script_Checklist.markdown
│  └─ Template_Prompt_IA_Just_Script_Generation.markdown
│
├─ shell/
│  ├─ Shell_Script_Best_Practices_Guide.md
│  ├─ Shell_Script_Checklist.md
│  └─ Template_Prompt_IA_Shell_Script_Generation.md
│
└─ README.md
```

### `commits/`

- **Commit_Instructions.md**  
  Template de prompt para revisão e padronização de mensagens de commit, com foco em Conventional Commits e fluxo de primeiro commit do projeto.

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

2. **Selecione o tipo de documento**  
   - `Template_Prompt_...` → texto a ser colado diretamente na IA como prompt principal.  
   - `...Best_Practices_Guide...` → referência técnica de como a saída deve ser estruturada.  
   - `...Checklist...` → uso na revisão final do que foi gerado.

3. **Adapte ao contexto do projeto**  
   - Ajuste nomes de serviços, paths, comandos específicos, ambientes (dev/stage/prod) e políticas internas.

4. **Envie o prompt para a IA**  
   - Use o template correspondente, incluindo contexto adicional do seu projeto quando necessário.

5. **Revise antes de aplicar**  
   - Valide a saída gerada usando a checklist da pasta correspondente.  
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
