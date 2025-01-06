# PostgreSQL

## Vue d'ensemble

PostgreSQL 15 est configuré dans notre stack avec support de monitoring, métriques, et sauvegardes automatisées.

## Configuration

### Configuration Docker

```yaml
postgres:
  container_name: postgres
  restart: always
  image: postgres:15-alpine
  security_opt:
    - no-new-privileges:true
  environment:
    - POSTGRES_PASSWORD=${POSTGRES_DATABASE_PASSWORD}
    - POSTGRES_USER=${POSTGRES_DATABASE_USER}
    - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
  volumes:
    - postgres:/var/lib/postgresql/data
    - ./dumps:/dumps
  ports:
    - 5432:5432
  networks:
    - db
```

### Variables d'Environnement

Dans votre fichier `.env` :
```bash
POSTGRES_DATABASE_USER=postgres
POSTGRES_DATABASE_PASSWORD=votre_mot_de_passe_secure
```

## Sauvegarde et Restauration

### Sauvegarde Manuelle

```bash
# Sauvegarde complète
docker exec postgres pg_dumpall -U postgres > ./dumps/$(date +%Y-%m-%d_%H-%M-%S)/postgres_full_backup.sql
```

### Sauvegarde Automatique

Le script `scripts/backup.sh` gère :
- Sauvegardes quotidiennes
- Compression des données
- Rotation automatique (conservation 7 jours)
```bash
# Lancer une sauvegarde
make backup
```

### Restauration

```bash
# Restauration complète
cat ./dumps/backup.sql | docker exec -i postgres psql -U postgres
```

## Métriques et Monitoring

### Configuration des Métriques

Le service postgres-exporter expose les métriques pour Prometheus :
```yaml
postgres-exporter:
  container_name: postgres-exporter
  image: prometheuscommunity/postgres-exporter:latest
  environment:
    - DATA_SOURCE_NAME=postgresql://user:password@postgres:5432/
  networks:
    - frontend
```

### Métriques Disponibles

- Statistiques de connexion
- Performance des requêtes
- Utilisation des ressources
- État des réplications
- Statistiques des tables/index

### Tableaux de Bord Grafana

Des tableaux de bord préconfigurés pour :
- Surveillance des performances
- Utilisation des ressources
- Analyse des requêtes
- État du cluster

## Maintenance

### Vérification de l'État

```bash
# Status du service
docker-compose ps postgres

# Logs du service
docker-compose logs -f postgres

# Vérification de la connexion
docker exec postgres pg_isready
```

### Optimisation

```bash
# Analyse des tables
docker exec -it postgres vacuumdb --analyze --all

# Nettoyage complet
docker exec -it postgres vacuumdb --full --all
```

### Maintenance Programmée

Tâches recommandées :
1. Vaccum Analyze hebdomadaire
2. Vérification des logs quotidienne
3. Test de restauration trimestriel
4. Mise à jour des statistiques
5. Encryption des données sensibles

## Résolution des Problèmes

### Problèmes Courants

1. Echec de connexion
```bash
# Vérification des logs
docker-compose logs postgres

# Test de connexion
docker exec postgres pg_isready -U postgres
```

2. Performances dégradées
```bash
# Analyse des processus
docker exec -it postgres psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# Requêtes lentes
docker exec -it postgres psql -U postgres -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
```

3. Problèmes de sauvegarde
```bash
# Vérification de l'espace
docker exec postgres df -h

# Test de sauvegarde
docker exec postgres pg_dumpall --version
```

### Commandes Utiles

```bash
# Connexion psql
docker exec -it postgres psql -U postgres

# Import de base
docker exec -i postgres psql -U postgres -d database_name < dump.sql

# Export de base
docker exec postgres pg_dump -U postgres database_name > dump.sql

# Création d'utilisateur
docker exec -it postgres psql -U postgres -c "CREATE USER user_name WITH PASSWORD 'password';"

# Attribution des droits
docker exec -it postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE database_name TO user_name;"

# Statistiques des tables
docker exec -it postgres psql -U postgres -c "SELECT schemaname, tablename, n_live_tup, n_dead_tup FROM pg_stat_user_tables ORDER BY n_dead_tup DESC;"
```

### Scripts Utiles

```bash
# Surveillance des connexions actives
docker exec -it postgres psql -U postgres -c "
SELECT datname, usename, client_addr, state, query 
FROM pg_stat_activity 
WHERE state != 'idle';"

# Taille des bases de données
docker exec -it postgres psql -U postgres -c "
SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
FROM pg_database;"

# Index inutilisés
docker exec -it postgres psql -U postgres -c "
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes 
WHERE idx_scan = 0 
AND tablename NOT LIKE 'pg_%';"
```