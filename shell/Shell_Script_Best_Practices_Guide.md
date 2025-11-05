# Guia Completo de Boas Práticas para Criação de Scripts Shell (Bash)

## 1. Estrutura e Sintaxe
- Use `#!/bin/bash` e `set -e` no início para definir o interpretador e abortar em erros.
- Sempre faça double quotes em variáveis (`"$var"`).
- Use `local` para variáveis dentro de funções.
- Evite subshells desnecessárias para melhor desempenho e legibilidade.

## 2. Variáveis e Atribuições
- Utilize nomes claros e consistentes para variáveis.
- Simplifique atribuições booleanas.
- Agregue múltiplas checagens quando fizer sentido para maior clareza.

## 3. Funções e Modularidade
- Separe funcionalidades em funções pequenas e documentadas.
- Use nomes descritivos para funções.
- Utilize `return` e status para indicar sucesso/falha.

## 4. Controle de Erros
- Centralize verificação de erros numa função.
- Aborte o script com mensagem clara em caso de erro.

## 5. Execução e Permissões
- Verifique privilégios no início.
- Evite usar `sudo` dentro do script se já tem root.
- Verifique existência e permissões de usuários, grupos, e arquivos.
- Use `chmod` e `chown` explicitamente para definir permissões.

## 6. Manipulação de Arquivos
- Verifique existência antes de operações.
- Use `cmp -s` para evitar operações desnecessárias.
- Valide arquivos importantes com ferramentas específicas (`visudo -c`).

## 7. Interação com systemd
- Use `systemctl daemon-reload` após alterações.
- Verifique status com `systemctl is-active` e `is-enabled`.
- Evite chamadas redundantes ao habilitar/iniciar serviços.
- Forneça feedback claro do status.

## 8. Boas Práticas Gerais
- Evite repetições desnecessárias.
- Mantenha script idiomático para Bash.
- Use mensagens claras, consistentes e timestampadas.
- Permita modo debug para verbosidade extra.

## 9. Segurança e Confiabilidade
- Valide entradas e arquivos externos.
- Proteja arquivos sensíveis com permissões restritas.
- Teste e valide sintaxe em arquivos críticos.

---

# Exemplos e recomendações rápidas

| Aspecto                | Prática recomendada                                      |
|------------------------|---------------------------------------------------------|
| Shebang                | `#!/bin/bash`                                           |
| Fail Fast              | `set -e` para abortar ao erro                            |
| Variáveis              | Sempre double quote nas expansões: `"$VAR"`             |
| Variáveis locais       | Use `local` dentro de funções                            |
| Evitar subshell        | Só usar quando necessário                                |
| Erros                  | Função separada para checar códigos de saída e abortar  |
| Permissões             | Ajustar `chmod` e `chown` explicitamente                |
| Arquivos críticos      | Validar com ferramentas (e.g. `visudo -c`)              |
| Serviços systemd       | Usar `systemctl is-active` para validar antes de agir   |
| Mensagens              | Informativas, prefixadas e com timestamp                 |
| Debug                  | Variável/flag para ativar modo verboso                   |

---

# Referências rápidas em Bash

## Exemplos de Shebang e Configuração Inicial
```bash
#!/bin/bash

# Abortar em caso de erro
set -e

# Configurar locale para consistência
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
```

## Exemplos de Declaração de Variáveis
```bash
# Variáveis globais com nomes descritivos
SYSTEMD_DIR="/etc/systemd/system"
LOG_DIR="/path/to/logs"
USER="app-user"
GROUP="app-group"

# Derivar caminhos de forma dinâmica
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
PARENT_LOG_DIR=$(dirname "$LOG_DIR")

# Arrays para listas
SERVICES=(
    "service1.service"
    "service2.service"
    "timer1.timer"
)
```

## Exemplos de Funções para Verificação de Erros
```bash
# Função para verificar se o comando foi executado com sucesso
check_error() {
    local status=$1
    local message="$2"
    if [ "$status" -ne 0 ]; then
        echo "Erro: $message"
        exit 1
    fi
}

# Uso da função
mkdir -p "$LOG_DIR"
check_error $? "Falha ao criar diretório de logs"
```

## Exemplos de Verificação de Pré-requisitos
```bash
# Verificar se o script está rodando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Erro: Este script deve ser executado como root ou com sudo."
        exit 1
    fi
}

# Verificar se um comando existe
if ! command -v systemctl >/dev/null 2>&1; then
    echo "Erro: Comando systemctl não encontrado."
    exit 1
fi

# Verificar se um usuário existe
if ! id "$USER" >/dev/null 2>&1; then
    echo "Erro: Usuário \"$USER\" não existe no sistema."
    exit 1
fi
```

## Exemplos de Manipulação de Arquivos
```bash
# Verificar se um arquivo existe antes de usá-lo
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erro: Arquivo \"$CONFIG_FILE\" não encontrado."
    exit 1
fi

# Comparar arquivos antes de copiar (evitar operações desnecessárias)
if [ -f "$DEST_FILE" ]; then
    if cmp -s "$SRC_FILE" "$DEST_FILE"; then
        echo "Arquivo já está atualizado. Pulando."
        return 0
    fi
fi

# Copiar e definir permissões
cp "$SRC_FILE" "$DEST_FILE"
chmod 644 "$DEST_FILE"
chown root:root "$DEST_FILE"
```

## Exemplos de Interação com systemd
```bash
# Verificar se um serviço está habilitado antes de habilitá-lo
if systemctl is-enabled "$SERVICE" >/dev/null 2>&1; then
    echo "Serviço \"$SERVICE\" já está habilitado."
else
    systemctl enable "$SERVICE"
fi

# Verificar se um serviço está ativo antes de iniciá-lo
if systemctl is-active "$SERVICE" >/dev/null 2>&1; then
    echo "Serviço \"$SERVICE\" já está ativo."
else
    systemctl start "$SERVICE"
fi

# Recarregar systemd após alterações
systemctl daemon-reload
```

## Exemplos de Loops e Condicionais
```bash
# Loop através de um array com verificação de tipo
for service in "${SERVICES[@]}"; do
    if [[ "$service" =~ \.timer$ ]]; then
        type_name="timer"
    else
        type_name="serviço"
    fi
    echo "Processando $type_name: $service"
done

# Verificação condicional com mensagem apropriada
if [ -f "$LOG_FILE" ]; then
    echo "Para monitorar logs em tempo real: tail -f \"$LOG_FILE\""
else
    echo "Aviso: Arquivo de log ainda não existe."
fi
```

## Exemplos de Redirecionamento e Logging
```bash
# Redirecionar stdout e stderr para um arquivo de log
exec > >(tee -a "$LOG_FILE") 2>&1

# Adicionar timestamp às mensagens
echo "[$(date)] Iniciando operação"

# Limitar saída de comandos longos
systemctl status "$SERVICE" --no-pager | head -n 10
```
