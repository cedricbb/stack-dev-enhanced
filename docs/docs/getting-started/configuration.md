# Guide de Configuration

Ce guide détaille la configuration des différents services de la stack de développement.

## 1. Configuration des services

### 1.1 Sécurité

#### 1.1.1 Gestion des Mots de Passe

Les mots de passe sont gérés via le fichier `.env`. Pour régénérer des mots de passe sécurisés :

```bash
make generate-passwords
```

Le script `scripts/generate-passwords.sh` génère automatiquement :
- Identifiants root MariaDB
- Identifiants PostgreSQL
- Identifiants PGAdmin
- Mot de passe Redis
- Mot de passe Grafana
- Identifiants du dashboard Traefik

#### 1.1.2 Certificats SSL

Les certificats SSL sont gérés dans le dossier `traefik/certificates`. Pour les renouveler :

```bash
make ssl-renew
```

### 1.2. Bases de données

#### 1.2.1 MariaDB

Configuration dans `config/mariadb/` :
- Charset et Collation
- Paramètres de performances
- Configuration des métriques

#### 1.2.2 PostgreSQL

Paramètres principaux :
```env
POSTGRES_DATABASE_USER=postgres
POSTGRES_DATABASE_PASSWORD=votre-mot-de-passe
POSTGRES_HOST_AUTH_METHOD=scram-sha-256
```

#### 1.2.3 Redis

Configuration via les variables d'environnement :
```env
REDIS_PASSWORD=votre-mot-de-passe
```

### 1.3. Monitoring

#### 1.3.1 Prometheus

Le fichier `config/prometheus/prometheus.yml` définit :
- Les cibles de scraping
- Les intervalles de collecte
- Les règles d'alertes

#### 1.3.2 Grafana

Principaux paramètres :
```env
GF_SERVER_ROOT_URL=http://grafana.localhost
GF_SECURITY_ADMIN_PASSWORD=votre-mot-de-passe
GF_SECURITY_ADMIN_USER=admin
```

### 1.4. Exporters de Métriques

#### 1.4.1 MariaDB Metrics

Le script `scripts/mariadb_metrics.sh` confgure :
- La collecte des métriques MariaDB
- L'exposition sur le port 9104
- Les métriques personnalisées

#### 1.4.2 Redis et Postgres Exporters

Configuration automatique via docker-compose :
- Redis Exporter : Port 9121
- Postgres Exporter : Port 9187

## 2. Sauvegardes

### 2.1 Configuration des Sauvegardes

Le script `scripts/backup.sh` gère :
- Sauvegarde complète MariaDB
- Sauvegarde complète PostgreSQL
- Compression des backups
- Rotation automatique (7 jours par défaut)

Pour exécuter une sauvegarde manuelle :

```bash
make backup
```

Configuration de la rotation des sauvegardes dans `backup.sh` :
```bash
KEEP_DAYS=7 # Nombre de jours de rétention
```

## 3. Monitoring de Santé

### 3.1 Health Checks

Le script `scripts/health_checks.sh` surveille :
- L'état des conteneurs
- L'accéssibiité des services web
- La connectivité des bases de données

Configuration des alertes :
```bash
# Dans votre environnement
export SLACK_WEBHOOK_URL="votre-url-de-webhook-slack"
export ALERT_EMAIL="votre-adresse-email"
```

## 4. Configuration de l'Accès à Distance

### 4.1 Wireguard

Configuration dans `/etc/wireguard/wg0.conf` :
- Port d'écoute : 51820
- Plage d'adresses : 10.0.0.0/24
- Règles de forwarding

### 4.2 Cloudflare Tunnel

Configuration dans `~/.cloudflared/config.yml` :
- Routes des services
- Règles de sécurité
- Configuration TLS

## 5. Maintenance

### 5.1 Commandes Make Disponibles

```bash
make up                 # Démarrer la stack
make down               # Arretter la stack
make restart            # Redémarrer la stack
make ps                 # Status des services
make logs               # Logs des services
make backup             # Sauvegarder les données
make restore            # Restaurer les données
make clean              # Nettoyer les ressources inutiles
make update             # Mettre à jour la stack
make security-check     # Verifier la sécurité
```

### 5.2 Logs et Monitoring

Accès aux logs :
```bash
# Tous les services
make logs

# Service spécifique
make logs [service_name]
```

### 5.3 Mise à jour

Pour mettre à jour la stack :

```bash
git pull
make update
```

## 6. Personnalisation

### 6.1 Ajout de Services

1. Créez un nouveau service dans `docker-compose.yml`
2. Ajoutez la configuration dans `configs/`
3. Mettez à jour les middlewares Traefik si nécessaire
4. Ajoutez les entrées DNS locales

### 6.2 Configuration Avancée

Pour des besoins spécifiques :

1. Modifiez les fichiers de configuration dans `configs/`
2. Ajustez les variables d'environnement dans `.env`
3. Mettez à jour les scripts de maintenance si nécessaire