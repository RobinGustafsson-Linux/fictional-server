
# Sökväg till Git-projekt
REPO_DIR=~/Desktop/fictional-server

# Skapa backupmapp med datum
BACKUP_DIR="$REPO_DIR/backups/$(date +%F)"
mkdir -p "$BACKUP_DIR"

# Lista filer att spara
CONFIG_FILES=(
    /etc/zabbix/zabbix_server.conf
    /etc/zabbix/zabbix_agentd.conf
    /etc/rsyslog.conf
    /etc/rsyslog.d/10-windows.conf
)

# Kopiera varje fil
for FILE in "${CONFIG_FILES[@]}"; do
    cp "$FILE" "$BACKUP_DIR/"
done

# Lägg till, committa och pusha till Git
cd "$REPO_DIR"
git add backups/
git commit -m "Automatisk backup $(date +%F)"
git push origin main
