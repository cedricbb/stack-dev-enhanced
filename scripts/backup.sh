#!/bin/bash

# COnfiguration
BACKUP_DIR="./dumps"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
KEEP_DAYS=7

# Création du répertoire de sauvegarde
mkdir -p "$BACKUP_DIR/$DATE"

# Backup MariaDB
echo  "Sauvegarde de MariaDB..."
docker exec mariadb mysqldump \
    --user=root \
    --password=root \
    --all-databases \
    --events \
    --routines \
    --trigers  \
    > "$BACKUP_DIR/$DATE/mariadb_full_backup.sql"

# Backup PostgreSQL
echo  "Sauvegarde de PostgreSQL..."
docker exec postgres pg_dumpall \
    -U postgres \
    > "$BACKUP_DIR/$DATE/postgres_full_backup.sql"

# Compression des backups
cd "$BACKUP_DIR"
tar -czf "$DATE.tar.gz" "$DATE"
rm -rf "$DATE"

# Nettoyage des vieux backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$KEEP_DAYS -delete

echo "Sauvegarde terminée."