#!/bin/bash

# Configuration
MYSQL_USER="root"
MYSQL_PASSWORD="secure_password"
MYSQL_HOST="mariadb"

# Fonction pour exécuter les requêtes SQL et formatter en métriques Prometheus
get_metrics() {
    mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < /etc/prometheus/mariadb/metrics.sql | \
    while IFS=$'\t' read -r name value; do
        echo "mariadb_${name,,} $value"
    done
}

# Point de terminaison HTTP simple
while true; do
    nc -l -p 9104 -c 'echo -e "HTTP/1.1 200 OK\nContent-Type: text/plain\n\n$(get_metrics)"'
done