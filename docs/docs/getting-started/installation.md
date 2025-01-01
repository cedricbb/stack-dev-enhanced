# Guide d'installation

Ce guide détaille les étapes d'installation de la stack de développement

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- Docker (>= 20.10.0)
- Docker Compose (>= 2.0.0)
- Git
- Make
- OpenSSL

## 1. Clonage du projet

```bash
git clone https://github.com/cedricbb/stack-dev-enhanced.git
cd stack-dev-enhanced
```

## 2. Configuration SSL

La stack utilise des certificats SSL pour sécuriser les communications. Le script `scripts/generate-certificates.sh` gère la création des certificats.

### 2.1 Génération des Certificats

```bash
make ssl-init
```

Ce script va :
- Créer un répertoire pour les certificats
- Générer une autorité de certification (CA)
- Créer un certificat de domaine signé par la CA
- Configurer les permissions appropriées

### 2.2 Installation du Certificat CA

Pour que votre navigateur fasse confiance aux certificats :

```bash
sudo cp ./traefik/certificates/ca.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

## 3. Configuration de l'Accès à Distance (Optionnel)

### 3.1 Installation de Wireguard

Si vous souhaitez accéder à votre stack à distance de manière sécurisée :

```bash
sudo ./scripts/setup-wireguard.sh
```

Le script va :
- Installer Wireguard
- Générer les clés serveur et client
- Configurer le serveur VPN
- Activer le forwarding IP
- Démarrer le service

### 3.2 Configuration de Cloudflare Tunnel (Optionnel en cas d'IPV6 publique)

Pour une exposition sécurisée sur Internet :

```bash
sudo ./scripts/setup-cloudflare.sh
```

Ce script :
- Installe Cloudflared
- Configure le dépçot Cloudflare
Prépare l'environnement pour les tunnels

## 4. Configuration des Variables d'Environnement

Générez des mots de passe sécurisés pour tous les services :

```bash
make generate-passwords
```

Cette commande va créer un fichier `.env` contenant :

- Identifiants MariaDB
- Identifiants PostgreSQL
- Identifiants PGAdmin
- Mot de passe Redis
- Mot de passe Grafana
Identifiants du dashboard Traefik

## 5. Configuration du DNS Local

Ajoutez les entrées suivantes à votre fichier `/etc/hosts` :

```bash
127.0.0.1 traefik.localhost
127.0.0.1 docs.localhost
127.0.0.1 mariadb.localhost
127.0.0.1 postgres.localhost
127.0.0.1 redis.localhost
127.0.0.1 phpmyadmin.localhost
127.0.0.1 pgadmin.localhost
127.0.0.1 grafana.localhost
127.0.0.1 prometheus.localhost
127.0.0.1 cadvisor.localhost
```

## 6. Démarrage de la Stack

Initialisez et démarrez la stack :

```bash
# Initialisation
make init

# Démarrage
make up
```

## 7. Vérification de l'Installation

Vérifiez que tous les services sont opérationnels :

```bash
make ps
make health-check
```

## 8. Résolution des Problèmes Courants

### Certificats non reconnus

Si les certificats ne sont pas reconnus par votre navigateur :

```bash
sudo update-ca-certificates --fresh
```

### Conflits de Ports

Si vous rencontrez des conflits de ports, modifiez les ports dans le fichier .`.env` :

```bash
DATABASE_PORT=3306
POSTGRES_PORT=5432
REDIS_PORT=6379
```

### Services Inaccessibles

Vérifiez l'état des services :

```bash
docker-compose logs [service_name]
```

## Prochaines Étapes

Une fois l'installation terminée, consultez le Guide de configuration pour personnaliser votre environnement.
