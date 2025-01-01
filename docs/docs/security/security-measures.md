# Mesures de sécurité

Ce document détaille les mesures de sécurité mises en place dans la stack de développement.

## 1. Sécurité SSL/TLS

### 1.1 Génération des Certificats

Le script `scripts/generate-certificates.sh` gère la création et le renouvellement des certificats :

```bash
make ssl-init
```

Configuration SSL dans `ssl.sh` :
- Génération d'une autorité de certfication (CA)
- Création de certificats de domaine signés
- Rotation automatique des certificats
- Configuratio des permissions

### 1.2 Configuration Traefik SSL

```bash
# Configuration des endpoints SSL
entrypoints:
    websecure:
        address: ":443"
        http:
            tls: true
        middleware:
            - secure-headers@file
```

## 2. Sécurité des Conteneurs

### 2.1 Configuration Docker

Restriction de sécurité appliquées à tous les conteneurs :
```bash
security_opt:
    - no-new-privileges:true
```

### 2.2 Isolation Réseau

Orgnisation des réseaux Docker :
```bash
networks:
    frontend:
        name : frontend
        external: false
    backend:
        name : backend
        external: false
    db:
        name : db
        external: false
```

## 3. Sécurité des Bases de Données

### 3.1 MariaDB

MariaDB :
```bash
environment:
    - MARIADB_ROOT_USER=${DATABASE_ROOT_USER}
    - MARIADB_ROOT_PASSWORD=${DATABASE_ROOT_PASSWORD}
    - MARIADB_ROOT_HOST=%
```

### 3.2 PostgreSQL

PostgreSQL :
```bash
environment:
    - POSTGRES_PASSWORD=${POSTGRES_DATABASE_PASSWORD}
    - POSTGRES_USER=${POSTGRES_DATABASE_USER}
    - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
```

### 3.3 Redis

Redis :
```bash
command: redis-server --requirepass ${REDIS_PASSWORD}
environment:
    - REDIS_PASSWORD=${REDIS_PASSWORD}
```

## 4. Gestion des Mots de Passe

### 4.1 Génération Sécurisée

Le script `scripts/generate-passwords.sh` crée des mots de passe forts :

```bash
# fonction de génération
generate_passwords() {
    openssl rand -base64 24
}
```

### 4.2 Stockage Sécurisé

- Utilisation de variables d'environnement
- Fichier `.env` isolé
- Pas de mots de passe en clair dans les configurations

## 5. Monitoring et Alertes

### 5.1 Health Checks

Le script `scripts/health_check.sh` surveille :
- Etat des conteneurs
- Accessibilité des services
- Connectivité des bases de données

Configuration des alertes :
```bash
# Slack
SLACK_WEBHOOK_URL="votre-webhook-slack"

# Email
EMAIL="votre-adresse-email"
```

### 5.2 Métriques

Configuration des exportateurs de métriques :
```bash
# MariaDB Metrics
    ports:
      - "9104:9104"

# Postgres Exporter
    environment:
      - DATA_SOURCE_NAME=postgresql://user:password@postgres:5432/

# Redis Exporter
    environment:
      - REDIS_ADDR=redis:6379
      - REDIS_PASSWORD=${REDIS_PASSWORD}
```

## 6. Sauvegardes Sécurisées

### 6.1 Configuration des sauvegardes

Le script `scripts/backup.sh` gère :
- Sauvegardes chiffrées
- Rotation automatique
- Compression des données

```bash
# Configuration
BACKUP_DIR="./dumps"
KEEP_DAYS=7
```

### 6.2 Gestion des sauvegardes

```bash
# Sauvegarde manuelle
make backup

# Restauration
make restore
```

## 7. Middlewares de Sécurité

### 7.1 Headers de Sécurité

Configuration Traefik :
```bash
http:
    middlewares:
        secure-headers:
            headers:
                browserXssFilter: true
                contentTypeNosniff: true
                frameDeny: true
                sslRedirect: true
                stsSeconds: 31536000
                stsIncludeSubdomains: true
```

### 7.2 Rate Limiting
```bash
middlewares:
    rate-limit:
        rateLimit:
            average: 100
            burst: 50
```

## 8. Protection des Interfaces d'Administration

### 8.1 PGAdmin :

```bash
environment:
    - PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=true
    - PGADMIN_CONFIG_MASTER_PASSWORD-REQUIRED=true
    - PGADMIN_CONFIG_MAX_LOGIN_ATTEMPTS=3
```

### 8.2 Grafana :

```bash
environment:
    - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    - GF_SECURITY_ADMIN_USER=admin
```

## 9. Maintenance de la Sécurité

### 9.1 Vérifications Régulières

```bash
# Vérification de la sécurité
make security-check

# Mise à jour de la stack
make update
```

### 9.2 Logs de Sécurité

Centralisation des logs :
```bash
# Consultation des logs
make logs

# Logs spécifiques
make logs [service_name]
```

## 10. Authentification à Deux Facteurs (2FA)

### 10.1 Installation de Google Authenticator PAM

```bash
# Installation
sudo apt-get install -y libpam-google-authenticator
```

### 10.2 Configuration par Service

PGAdmin 2FA :
```bash
environment:
    - PGADMIN_CONFIG_MFA_ENABLED: "true"
    - PGADMIN_CONFIG_2FA_METHOD: "TOTP"
    - PGADMIN_CONFIG_2FA_TIMEOUT: "300"
```

Grafana 2FA :
```bash
environment:
    - GF_AUTH_BASIC_ENABLED: "true"
    - GF_AUTH_DISABLE_LOGIN_FORM: "false"
    - GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
    - GF_SECURITY_DISABLE_GRAVATAR: "true"
    - GF_SECURITY_COOKIE_SECURE: "true"
```

## 11. Configuration du Pare-Feu (UFW)

### 11.1 Installation et Configuration de Base

```bash
# Installation
sudo apt-get install -y ufw

# Configuration par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### 11.2 Règles de Base

```bash
# SSH
sudo ufw allow 22/tcp

# HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# WireGuard
sudo ufw allow 51820/udp

# Accès aux bases de données uniquement depuis  le VPN
sudo ufw allow from 10.0.0.0/8 to any port 3306 proto tcp # MariaDB
sudo ufw allow from 10.0.0.0/8 to any port 5432 proto tcp # PostgreSQL
sudo ufw allow from 10.0.0.0/8 to any port 6379 proto tcp # Redis
```

### 11.3 Activation et Gestion

```bash
# Activation
sudo ufw enable

# Vérification du statut
sudo ufw status verbose

# Liste des règles numérotées
sudo ufw status numbered
```

## 12. Protection avec Fail2Ban

### 12.1 Installation

```bash
# Installation
sudo apt-get install -y fail2ban
```

### 12.2 Configuration de Base

Créez `/etc/fail2ban/jail.local` :
```bash
[DEFAULT]
# Temps de baissement en secondes
bantime = 3600
# Période d'analyse en secondes
findtime = 600
# Nombre maximum de tentatives
maxretry = 3

# Protection SSH
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log

# Protection Traefik
[traefik-auth]
enabled = true
port = 80,443
filter = traefik-auth
logpath = /var/log/traefik/access.log
maxretry = 5
findtime = 300
bantime = 3600

# Protection MariaDB
[mariadb]
enabled = true
port = 3306
filter = mariadb
logpath = /var/log/mysql/error.log
maxretry = 3
findtime = 600
bantime = 3600

# Protection PostgreSQL
[pgsql]
enabled = true
port = 5432
filter = pgsql
logpath = /var/log/postgresql/postgresql-*.log
maxretry = 3
findtime = 600
bantime = 3600
```

### 12.3 Filtres Personnalisés

Crééz `/etc/fail2ban/filter.d/traefik-auth.conf` :
```bash
[Definition]
failregex = ^.*Authorization failed, invalid username or password from <HOST>.*$
ignoreregex =
```

### 12.4 Gestion du service

```bash
# Démarrage du service
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Vérification du statut
sudo systemctl status fail2ban

# Gestion des bans
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip <IP>
```

### 12.5 Surveillance des Logs

```bash
# Surveillance en temps réel
sudo tail -f /var/log/fail2ban.log

# Vérification des bans actifs
sudo fail2ban-client status traefik-auth
```

## 13. Recommandations

1. Changez régulièrement les mots de passe
2. Surveillez les logs de sécurité
3. Maintenez les images à jour
4. Effectuez des sauvegardes régulières
5. Testez la restauration des sauvegardes
6. Vérifiez régulièrement les permissions
7. Auditez les accès aux services
8. Documentez les incidents de sécurité