
# Tjänster att övervaka
SERVICES=("zabbix-server" "zabbix-agent" "rsyslog")

for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$SERVICE"; then
        logger "$SERVICE is running."
    else
        logger "$SERVICE is NOT running!"
    fi
done
