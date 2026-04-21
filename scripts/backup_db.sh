#!/bin/bash
# Gündəlik backup + 30 gündən köhnələri silmək

DB_NAME="ttis_db"
BACKUP_DIR="$(dirname "$0")/../database/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="ttis_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

echo "🔄 Backup başladı: $FILENAME"
pg_dump -Fc "$DB_NAME" > "$BACKUP_DIR/$FILENAME"

if [ $? -eq 0 ]; then
    echo "✅ Backup uğurlu: $(du -h "$BACKUP_DIR/$FILENAME" | cut -f1)"
else
    echo "❌ Backup xətası!"
    exit 1
fi

# 30 gündən köhnə backup-ları sil
find "$BACKUP_DIR" -name "ttis_*.dump" -mtime +30 -delete
echo "🧹 Köhnə backup-lar təmizləndi"
