# MariaDB

## Vue d'ensemble

MariaDB est configuré dans notre stack avec la version 10.11, incluant des métriques de surveillance et une configuration de sauvegarde automatisée.

## Configuration

### Configuration Docker

```yaml
container_name: mariadb
restart: always
image: mariadb:10.11
security_opt:
  - no-new-privileges:true
environment:
    - MARIADB_ROOT_USER=${DATABASE_ROOT_USER}
    - MARIADB_ROOT_PASSWORD=${DATABASE_ROOT_PASSWORD}
    - MARIADB_ROOT_HOST=%
volumes:
    - mariadb:/var/lib/mysql
    - ./dumps:/dumps
    - ./configs/mariadb:/etc/prometheus/mariadb:ro
    - ./scripts:/scripts:ro

ports:
    - 3306:3306

networks:
    - db
```

### Variables d'environnement

Dans votre fichier `.env` :
```bash
DATABASE_ROOT_USER=root
DATABASE_ROOT_PASSWORD=votre_mot_de_passe_secure
```

## Sauvegarde et Restauration

### Sauvegarde Manuelle

```bash
# Sauvegarde complète
docker exec mariadb mysqldump \
    --user=root \
    --password=root \
    --all-databases \
    --events \
    --routines \
    --triggers \
    > ./dumps/$(date +%Y-%m-%d_%H-%M-%S)/mariadb_fulll_backup.sql
```

### Sauvegarde automatique

Le script `scripts/backup.sh` effectue :
- Sauvegardes quotidiennes
- Compression des données
- Rotation automatique (conservation 7 jours)

```bash
make backup
```

### Restauration

```bash
# Restauration complète
cat ./dumps/backup.sql | docker exec -i mariadb mysql -u root -proot
```

## Métriques et Monitoring

### Configuration des Métriques

Le service mariadb-metrics expose les métriques pour Prometheus :
```yaml
mariadb-metrics:
    image: bittnami/mysqld-exporter:latest
    container_name: mariadb-metrics
    command:
        - --mysqld.username=root:secure_password
        - --mysqld.adress=127.0.0.1:3306
    ports:
        - 9104:9104
    networks:
        - frontend
        - db
```

### Métriques Disponibles

- Connexions actives
- Opérations par seconde
- Utilisation de la mémoire
- Performance des requêtes
- État des réplications

## Tableaux de Bord Grafana

Des tableaux de bord préconfigurés sont disponibles dans Grafana pour visualiser :
- Performance globale
- Utilisation des ressources
- Statistiques des requêtes
- État de la réplication

## Maintenance

### Vérification de l'État

```bash
# status du service
docker-compose ps mariadb

# logs du service
docker-compose logs -f mariadb

# Vérification de la connexion
docker exec mariadb mysqladmin ping -h localhost
```

### Optimisation

```bash
# Analyse des tables
docker exec mariadb mysqlcheck -u root -p --all-databases --analyze

# Optimisation des tables
docker exec mariadb mysqlcheck -u root -p --all-databases --optimize
```

### Maintenance Programmée

Tâches recommandées :
1. Vérification hebdomadaire des logs
2. Analyse mensuelle des tables
3. Test trimestriel de restauration
4. Rotation des sauvegardes (automatique)

## Sécurité

### Configuration Réseau

- Accès limité au réseau `db`
- Port exposé uniquement pour le développement local
- Accès distant via VPN uniquement

### Bonnes Pratiques

1. Changez régulièrement les mots de passe
2. Limitez les privilèges des utilisateurs
3. Activez les logs d'audit
4. Surveillez les tentatives de connexion
5. Maintenez MariaDB à jour

## Résolution des Problèmes

### Problèmes Courants

1. Connexion impossible
```bash
# Vérification des logs
docker-compose logs mariadb

# Vérification du réseau
docker exec mariadb mysqladmin ping
```

2. Performance dégradée
```bash
# Vérification des processus
docker exec mariadb mysqladmin processlist

# Analyse des requêtes lentes
docker exec mariadb tail -f /var/log/mysql/slow-query.log
```

3. Erreurs de sauvegarde
```bash
# Vérification de l'espace disque
docker exec mariadb df -h

# Test de sauvegarde manuelle
docker exec mariadb mysqldump --version

## Commandes Utiles

```bash
# Connexion à la base
docker exec -it mariadb mysql -uroot -p

# Import des données
docker exec -i mariadb mysql -uroot -p database_name < ./dumps/dump.sql

# Export des données
docker exec mariadb mysqldump -uroot -p database_name > ./dumps/dump.sql

# Création d'utilisateur
docker exec mariadb mysql -uroot -p -e "CREATE USER 'newuser'@%' IDENTIFIED BY 'password';"

# Attribution des droits
docker exec mariadb mysql -uroot -p -e "GRANT ALL PRIVILEGES ON database.* TO 'newuser'@'%';"
```