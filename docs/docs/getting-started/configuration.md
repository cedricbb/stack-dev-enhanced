# Guide de Configuration

## 1. Structure des fichiers

```plaintext
.
├── config/           # Configurations des services
├── secrets/          # Secrets Docker
├── scripts/          # Scripts d'administration
├── docs/            # Documentation
└── docker-compose.yml
```

## 2. Configuration des Services

### 2.1 Traefik
```yaml
# config/traefik/traefik.yml
api:
  dashboard: true
  insecure: false

# Optimisations B1 Pro
log:
  level: INFO
  bufferingSize: 100

# Configuration mémoire
accessLog:
  bufferingSize: 100
pilot:
  dashboard: false
```

### 2.2 MariaDB
```cnf
# config/mariadb/my.cnf
[mysqld]
# Optimisations B1 Pro
performance_schema = OFF
table_definition_cache = 400
innodb_buffer_pool_size = 256M
max_connections = 50
```

### 2.3 Redis
```conf
# config/redis/redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lru
appendonly yes
```

### 2.4 Adminer
```yaml
services:
  adminer:
    environment:
      - ADMINER_DEFAULT_SERVER=mariadb
      - ADMINER_DESIGN=dracula
    deploy:
      resources:
        limits:
          cpus: '0.2'
          memory: 256M
```
- Accès : https://adminer.votredomaine.fr
- Identifiants : utiliser les credentials MariaDB

## 3. Gestion des Secrets

### 3.1 Création
```bash
# Génération des secrets
make generate-secrets
```

### 3.2 Utilisation
```yaml
# docker-compose.yml
secrets:
  db_root_password:
    file: ./secrets/db_root_password.txt
```

## 4. Configuration des ressources

### 4.1 Limites par service
```yaml
# docker-compose.yml
services:
  mariadb:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          memory: 256M
```

### 4.2 Priorités
- Base de données : 512MB RAM
- Cache : 256MB RAM
- Proxy : 256MB RAM
- Monitoring : 256MB RAM

## 5. Configuration Réseau

### 5.1 Réseaux Docker
```yaml
networks:
  frontend:
    name: frontend
  backend:
    name: backend
  db:
    name: db
```

### 5.2 Ports exposés
- 80 : HTTP
- 443 : HTTPS
- 51820 : WireGuard

## 6. Configuration SSL/TLS

### 6.1 Let's Encrypt
```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      email: your@email.com
      storage: /letsencrypt/acme.json
      tlsChallenge: true
```

### 6.2 Headers de sécurité
```yaml
headers:
  sslRedirect: true
  forceSTSHeader: true
  stsIncludeSubdomains: true
  stsPreload: true
  stsSeconds: 31536000
```

## 7. Variables d'environnement

### 7.1 Configuration minimale (.env)
```env
DOMAIN_NAME=votredomaine.fr
ACME_EMAIL=votre@email.com
```

## 8. Personnalisation

### 8.1 Ajout de services
1. Créer la configuration dans `config/`
2. Ajouter le service dans `docker-compose.yml`
3. Configurer les labels Traefik
4. Mettre à jour la documentation

### 8.2 Modification des ressources
1. Adapter les limites dans `docker-compose.yml`
2. Mettre à jour la configuration service
3. Tester les performances
4. Documenter les changements