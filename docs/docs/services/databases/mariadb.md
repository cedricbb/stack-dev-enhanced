# MariaDB

## 1. Configuration Optimisée B1 Pro

### 1.1 Configuration Docker
```yaml
# docker-compose.yml
services:
  mariadb:
    image: mariadb:10.11
    command: --performance_schema=OFF --table_definition_cache=400
    secrets:
      - db_root_password
    environment:
      - MARIADB_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
    volumes:
      - mariadb_data:/var/lib/mysql
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          memory: 256M
```

### 1.2 Configuration MariaDB
```ini
# config/mariadb/my.cnf
[mysqld]
# Désactivation des fonctionnalités non essentielles
performance_schema = OFF
skip_name_resolve = ON

# Cache et Mémoire
table_definition_cache = 400
table_open_cache = 256
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M

# Connexions
max_connections = 50
thread_cache_size = 10

# InnoDB optimisations
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Optimisation requêtes
sort_buffer_size = 2M
join_buffer_size = 2M
```

## 2. Gestion

### 2.1 Commandes de base
```bash
# Connexion
docker compose exec mariadb mysql -u root -p

# Sauvegarde
make backup-db

# Restauration
make restore-db BACKUP_DATE=YYYY-MM-DD
```

### 2.2 Surveillance
```sql
-- Status
SHOW GLOBAL STATUS;

-- Variables
SHOW VARIABLES;

-- Processus
SHOW PROCESSLIST;
```

## 3. Maintenance

### 3.1 Optimisation
```sql
-- Analyse tables
ANALYZE TABLE table_name;

-- Optimisation tables
OPTIMIZE TABLE table_name;

-- Vérification tables
CHECK TABLE table_name;
```

### 3.2 Maintenance régulière
```bash
# Nettoyage
make db-clean

# Optimisation
make db-optimize
```

## 4. Sécurité

### 4.1 Secrets
```bash
# Génération nouveau mot de passe
make generate-db-password

# Application changement
make update-db-password
```

### 4.2 Réseau
```yaml
networks:
  db:     # Réseau isolé
    internal: true
```

## 5. Sauvegarde

### 5.1 Configuration
```bash
# Sauvegarde automatique
0 2 * * * make backup-db

# Rotation
KEEP_BACKUPS=7  # Garde 7 jours
```

### 5.2 Scripts
```bash
# Sauvegarde complète
mysqldump --all-databases > backup.sql

# Sauvegarde spécifique
mysqldump database_name > backup.sql
```

## 6. Performance

### 6.1 Monitoring
```sql
-- Cache hits
SHOW GLOBAL STATUS LIKE 'innodb_buffer_pool_reads';

-- Connexions
SHOW GLOBAL STATUS LIKE 'Threads_connected';
```

### 6.2 Optimisation requêtes
```sql
-- Analyse requêtes lentes
SHOW VARIABLES LIKE 'slow_query_log%';
SET GLOBAL slow_query_log = 1;
```

## 7. Troubleshooting

### 7.1 Problèmes courants
```bash
# Logs
docker compose logs mariadb

# Statut
docker compose ps mariadb
```

### 7.2 Performance
```sql
-- Tables verrouillées
SHOW OPEN TABLES WHERE In_use > 0;

-- Processus bloquants
SHOW PROCESSLIST;
```

## 8. Bonnes Pratiques

### 8.1 Quotidien
- Vérifier les logs
- Surveiller l'espace disque
- Monitorer les connexions

### 8.2 Hebdomadaire
- Sauvegarde complète
- Analyse des tables
- Vérification des performances

### 8.3 Mensuel
- Test de restauration
- Optimisation des tables
- Revue des permissions