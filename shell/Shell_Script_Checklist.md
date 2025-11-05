# Checklist para Criação de Scripts Shell

- [ ] Inserir shebang correto (`#!/bin/bash`)
- [ ] Adicionar `set -e` para abortar em erros
- [ ] Declarar variáveis de forma clara e usar quotes em expansões
- [ ] Usar `local` para variáveis em funções
- [ ] Evitar subshells desnecessários
- [ ] Criar funções pequenas e documentadas
- [ ] Implementar função para checagem de erros e saída adequada
- [ ] Verificar privilégios de execução no início (ex.: root)
- [ ] Checar existência e permissões de usuários, grupos, arquivos e diretórios
- [ ] Evitar múltiplas checagens sequenciais repetidas
- [ ] Usar `cmp -s` para prevenir cópias ou modificações desnecessárias
- [ ] Definir permissões e donos explicitamente usando `chmod` e `chown`
- [ ] Evitar `sudo` interno se script rodar com root
- [ ] Verificar status de serviços com `systemctl is-active` e `is-enabled` antes de iniciar/habilitar
- [ ] Atualizar systemd com `systemctl daemon-reload` após alterações em arquivos de unidades
- [ ] Validar arquivos críticos com as ferramentas adequadas (e.g., `visudo -c`)
- [ ] Emitir mensagens claras e timestampadas para o usuário e logs
- [ ] Implementar flag/variável para ativar modo debug/verbose
- [ ] Documentar todas as funções e etapas críticas com comentários
- [ ] Evitar hardcoded paths usando variáveis globais
- [ ] Garantir consistência nas mensagens e idioma usado
- [ ] Validar entradas e manipular erros para segurança

## Finalize com:
- [ ] Testar o script em ambiente controlado
- [ ] Revisar logs e mensagens para garantir clareza