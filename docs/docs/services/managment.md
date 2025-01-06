# Interfaces d'Administration

## pgAdmin

### Configuration Docker

```yaml
pgadmin:
  container_name: pgadmin
  image: dpage/pgadmin4:latest
  environment:
    - PGADMIN_DEFAULT_EMAIL=admin@admin.com
    - PGADMIN_DEFAULT_PASSWORD=admin
    - PGADMIN_LISTEN_PORT=5050
    - PGADMIN_CONFIG_SERVER_MODE=True
    - PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED=True
    - PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True
    - PGADMIN_CONFIG_LOGIN_BANNER="Secure access via Traefik - Unauthorized access is prohibited"
    - PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10
    - PGADMIN_CONFIG_PROXY_X_FOR_COUNT=1
    - PGADMIN_CONFIG_PROXY_X_PROTO_COUNT=1
    - PGADMIN_CONFIG_MAX_LOGIN_ATTEMPTS=3
    - PGADMIN_CONFIG_PASSWORD_LENGTH_MIN=8
    - PGADMIN_CONFIG_CHECK_PASSWORD_STRENGTH=True
  networks:
    - db
    - frontend
  labels:
    - traefik.enable=true
    - traefik.http.routers.pgadmin.rule=Host(`pgadmin.localhost`)
    - traefik.http.routers.pgadmin.entrypoints=websecure
    - traefik.http.routers.pgadmin.tls=true
    - traefik.http.services.pgadmin.loadbalancer.server.port=5050
    - traefik.http.routers.pgadmin.middlewares=pgadmin-headers@file,pgadmin-rate@file
```

### Configuration Initiale

1. Accès à l'Interface
```
URL: https://pgadmin.localhost
Email: admin@admin.com
Password: [PGADMIN_DEFAULT_PASSWORD from .env]
```

2. Ajout d'un Nouveau Serveur
```json
{
  "Name": "Local PostgreSQL",
  "Host": "postgres",
  "Port": "5432",
  "Username": "postgres",
  "Password": "[POSTGRES_DATABASE_PASSWORD from .env]",
  "SSLMode": "prefer"
}
```

### Fonctionnalités Principales

1. Gestion des Bases de Données
```sql
-- Création d'une base
CREATE DATABASE nouvelle_base;

-- Gestion des privilèges
GRANT ALL PRIVILEGES ON DATABASE nouvelle_base TO utilisateur;
```

2. Outils de Maintenance
```sql
-- Vacuum
VACUUM ANALYZE table_name;

-- Réindexation
REINDEX TABLE table_name;
```

### Sécurité

1. Configuration SSL
```yaml
PGADMIN_CONFIG_SSL_MODE: 'require'
PGADMIN_CONFIG_SSL_CERT_FILE: '/certs/server.crt'
PGADMIN_CONFIG_SSL_KEY_FILE: '/certs/server.key'
```

2. Authentification à Deux Facteurs
```yaml
PGADMIN_CONFIG_MFA_ENABLED: "True"
PGADMIN_CONFIG_2FA_METHOD: "TOTP"
```

## phpMyAdmin

### Configuration Docker

```yaml
phpmyadmin:
  image: phpmyadmin:latest
  container_name: phpmyadmin
  environment:
    - PMA_HOST=mariadb
    - PMA_PORT=3306
    - PMA_ABSOLUTE_URI=https://phpmyadmin.localhost/
    - APACHE_SERVER_NAME=phpmyadmin.localhost
    - UPLOAD_LIMIT=300M
    - PMA_ARBITRARY=1
  volumes:
    - ./configs/phpmyadmin/apache.conf:/etc/apache2/sites-available/000-default.conf:ro
    - ./configs/phpmyadmin/apache.conf:/etc/apache2/sites-enabled/000-default.conf:ro
  networks:
    - db
    - frontend
  labels:
    - traefik.enable=true
    - traefik.http.routers.phpmyadmin.rule=Host(`phpmyadmin.localhost`)
    - traefik.http.routers.phpmyadmin.entrypoints=websecure
    - traefik.http.routers.phpmyadmin.tls=true
    - traefik.http.services.phpmyadmin.loadbalancer.server.port=80
```

### Configuration Apache

```apache
# /configs/phpmyadmin/apache.conf
<VirtualHost *:80>
    ServerName phpmyadmin.localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options -Indexes
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</Directory>
```

### Fonctionnalités Principales

1. Gestion des Bases de Données
```sql
-- Export de base
mysqldump -u [user] -p [database] > backup.sql

-- Import de base
mysql -u [user] -p [database] < backup.sql
```

2. Outils d'Administration
- Moniteur serveur
- Gestion des utilisateurs
- Gestion des privilèges
- Maintenance des tables

### Sécurité

1. Configuration Sécurisée
```php
// config.user.inc.php
$cfg['ForceSSL'] = true;
$cfg['LoginCookieValidityDisableWarning'] = false;
$cfg['ShowChgPassword'] = true;
```

2. Restriction d'Accès
```apache
# .htaccess
AuthType Basic
AuthName "Restricted Access"
AuthUserFile /etc/phpmyadmin/.htpasswd
Require valid-user
```

## Maintenance Commune

### Sauvegardes

```bash
#!/bin/bash
# backup_databases.sh

# PostgreSQL
docker exec postgres pg_dumpall -U postgres > backups/postgres_$(date +%Y%m%d).sql

# MariaDB
docker exec mariadb mysqldump -u root -p --all-databases > backups/mariadb_$(date +%Y%m%d).sql
```

### Monitoring

1. Logs d'Accès
```bash
# pgAdmin logs
docker-compose logs -f pgadmin

# phpMyAdmin logs
docker-compose logs -f phpmyadmin
```

2. Surveillance des Connexions
```bash
# PostgreSQL
docker exec postgres psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# MariaDB
docker exec mariadb mysql -e "SHOW PROCESSLIST;"
```

## Résolution des Problèmes

### pgAdmin

1. Problèmes de Connexion
```bash
# Vérification des logs
docker-compose logs pgadmin

# Test de connexion direct
docker exec -it postgres psql -U postgres -h localhost
```

2. Problèmes de Performance
```bash
# Nettoyage du cache
docker exec pgadmin rm -rf /var/lib/pgadmin/sessions/*

# Redémarrage du service
docker-compose restart pgadmin
```

### phpMyAdmin

1. Erreurs de Configuration
```bash
# Vérification de la configuration
docker exec phpmyadmin cat /etc/phpmyadmin/config.inc.php

# Test de connexion MySQL
docker exec phpmyadmin mysqladmin -h mariadb -u root ping
```

2. Problèmes de Mémoire
```bash
# Ajustement des limites PHP
docker exec phpmyadmin sed -i 's/memory_limit = 128M/memory_limit = 256M/' /usr/local/etc/php/php.ini
```

## Scripts Utiles

```bash
#!/bin/bash
# check_admin_interfaces.sh

echo "=== Checking Admin Interfaces ==="

# Check pgAdmin
curl -k -s -o /dev/null -w "pgAdmin: %{http_code}\n" https://pgadmin.localhost

# Check phpMyAdmin
curl -k -s -o /dev/null -w "phpMyAdmin: %{http_code}\n" https://phpmyadmin.localhost

# Check Database Connections
echo "=== Checking Database Connections ==="

# PostgreSQL
docker exec postgres pg_isready

# MariaDB
docker exec mariadb mysqladmin ping

echo "=== Done ==="
```