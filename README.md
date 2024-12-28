# 🚀 Stack de Développement Docker

Cette stack de Développement Docker est une collection de services Docker qui permettent de faciliter le développement et la gestion de projets.

## 📋 Prérequis

- Docker
- Docker Compose
- Git
- Make
- OpenSSL

## 📦 Services Inclus

| Service | Version |Description |
| --- | --- | --- |
🔄 Traefik | v2.10 | Reverse Proxy & Load Balancer
📊 MariaDB | 10.11 | Base de données MySQL
📊 PostgreSQL | 15 | Base de données PostgreSQL
⚡ Redis | 7 | Base de données Redis
🔍 phpMyAdmin | 5.2 | Interface de gestion de bases de données MySQL
📊 pgAdmin | 6 | Interface de gestion de bases de données PostgreSQL
📊 Grafana | 9 | Interface de gestion de dashboards

## 🏗 Structure du projet

Le projet est structuré en trois parties principales:

- **services**: Contient les services Docker composant la stack de Développement Docker.
- **configs**: Contient les fichiers de configuration des services Docker.
- **certs**: Contient les fichiers de certificats SSL.

## 🚦 Guide de démarrage

### 1️⃣  Configuration initiale

1. Clonez le dépôt
```bash
git clone https://github.com/cedricbb/stack-dev-enhanced.git

cd stack-dev-enhanced
```

2. Copiez le fichier `.env.example` et renommez-le en `.env`
```bash
cp .env.example .env
```

3. Editez le fichier `.env` et executez la commande `make generate-passwords` pour générer des mots de passe securisés.
```bash
make generate-passwords
```

### 2️⃣ Initialisation de la stack

1. Exécuter la commande `make init` pour initialiser la stack de Développement Docker.
```bash
make init
```

2. Exécuter la commande `make up` pour lancer la stack de Développement Docker.
```bash
make up
```

## 🔒 Configuration de l'Accès Distant Sécurisé

### Configuration de Wireguard

#### Etape 1 : Prérequis

1. Mise à jour du système :
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

2. Installation des dépendances :
```bash
sudo apt-get install -y wireguard wireguard-tools iptables
```

#### Etape 2 : Configuration du noyau

Configuration du forwarding IP :
```bash
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-wireguard.sudo sysctl -p /etc/sysctl.d/99-wireguard.conf
```

#### Etape 3 : Génération des clés

1. Création des répertoires :
```bash
sudo mkdir -p /etc/wireguard
cd /etc/wireguard
```

2. Génération des clés serveur :
```bash
# Clé privée
wg genkey | sudo tee /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
# Protection des clés
sudo chmod 600 /etc/wireguard/server_private.key
```

3. Génération des clés client :
```bash
# Clé privée
wg genkey | sudo tee /etc/wireguard/client_private.key | wg pubkey | sudo tee /etc/wireguard/client_public.key
# Protection des clés
sudo chmod 600 /etc/wireguard/client_private.key
```

#### Etape 4 : Configuration du serveur

1. Création du fichier de configuration :
```bash
sudo nano /etc/wireguard/wg0.conf
```

2. Contenu du fichier (remplacer '<SERVER_PRIVATE_KEY>' par la clé privée du serveur et '<CLIENT_PUBLIC_KEY>' par la clé publique du client) :
```ini
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.2/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIps = 10.0.0.2/32
```

#### Etape 5 : Configuration du pare-feu

1. Ouvrir le port Wireguard :
```bash
sudo ufw allow 51820/udp
sudo ufw enable
```

#### Etape 6 : Configuration du client

1. Création du fichier de configuration :
```bash
sudo nano /etc/wireguard/client.conf
```

2. Contenu du fichier (remplacer '<IP_SERVER>' par l'adresse IP du serveur et '<CLIENT_PRIVATE_KEY>' par la clé privée du client) :
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <IP_SERVER>:51820
AllowedIps = 0.0.0.0/0
PersistentKeepalive = 25
```

#### Etape 7 : Activation du service

1. Démarrage du service :
```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

2. Verification du statut du service :
```bash
sudo systemctl status wg-quick@wg0
sudo wg show
```

#### Etape 8 : Configuration du client local

1. Installation du client Wireguard sur votre machine locale

2. Import de la configuration client

3. Activation de la connexion

### Configuration de Cloudflare Tunnel (Optionnel en cas d'IPV6 publique)

##### Étape 1 : Prérequis

1. Créer un compte Cloudflare (https://dash.cloudflare.com/sign-up)

2. Avoir un domaine enregistré dans Cloudflare

##### Étape 2 : Installation de Cloudflared

1. Ajout du dépôt Cloudflare :
```bash
# Téléchargement de la clé CPG
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg > /dev/null

# Ajout du dépôt
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list 

2. Installation du package :
```bash
sudo apt-get update
sudo apt-get install -y cloudflared
```

##### Étape 3 : Authentification

1. Lancer l'authentification :
```bash
cloudflared login
```

2. Suivre le lien dans le navigateur et autoriser l'accès

##### Étape 4 : Création du tunnel

1. Création du tunnel :
```bash
cloudflared tunnel create stack-dev
```

2. Noter l'ID du tunnel qui s'affiche

##### Étape 5 : Configuration du tunnel

1. Création du répertoire de configuration :
```bash
mkdir -p ~/.cloudflared
```

2. Création du fichier de configuration :
```bash
sudo nano ~/.cloudflared/config.yml
```

3. Contenu du fichier (remplacer '<TUNNEL_ID>' par l'ID du tunnel) :
```yaml
tunnel: <TUNNEL_ID>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

# Configuration des routes
ingress:
    # Traefik Dashboard
    - hostname: traefik.votre-domaine.com
    service: http://localhost:8080
    originRequest:
        noTLSVerify: true

    # PGAdmin
    - hostname: pgadmin.votre-domaine.com
    service: http://localhost:5050
    originRequest:
        noTLSVerify: true

    # phpMyAdmin
    - hostname: phpmyadmin.votre-domaine.com
    service: http://localhost:80
    originRequest:
        noTLSVerify: true

    # Grafana
    - hostname: grafana.votre-domaine.com
    service: http://localhost:3000
    originRequest:
        noTLSVerify: true

    # Redis
    - hostname: redis.votre-domaine.com
    service: http://localhost:6379
    originRequest:
        noTLSVerify: true

    # MariaDB
    - hostname: mariadb.votre-domaine.com
    service: http://localhost:3306
    originRequest:
        noTLSVerify: true

    # PostgreSQL
    - hostname: postgres.votre-domaine.com
    service: http://localhost:5432
    originRequest:
        noTLSVerify: true

    # Route par défaut
    - service: http_status:404
```

##### Étape 6 : Configuration des DNS

1. Pour chaque sous-domaine dans la configuration :
```bash
cloudflared tunnel route dns <TUNNEL_ID> <SOUS_DOMAINE>
```

Exemple :
```bash
cloudflared tunnel route dns <TUNNEL_ID> traefik.votre-domaine.com
cloudflared tunnel route dns <TUNNEL_ID> pgadmin.votre-domaine.com
```

##### Étape 7 : Installation du service

1. Installation :
```bash
sudo cloudflared service install
```

2. Démarrage :
```bash
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

#### Étape 8 : Vérification et surveillance

1. Vérification du statut :
```bash
sudo systemctl status cloudflared
```

2. Consultation des logs :
```bash
sudo journalctl -u cloudflared -f
```

3. Test des connexions :
```bash
# Test de la connexion HTTP
curl -v http://traefik.votre-domaine.com

# Vérification des tunnels actifs
cloudflared tunnel list
```

### Commandes utiles pour la maintenancce

#### Wireguard :

```bash
# Vérifier l'état de la connexion
sudo wg show

# Redémarrer le service
sudo systemctl restart wg-quick@wg0

# Voir les logs
sudo journalctl -u wg-quick@wg0
```

#### Cloudflare Tunnel :

```bash
# Lister les tunnels
cloudflared tunnel list

# Supprimer un tunnel
cloudflared tunnel delete <TUNNEL_NAME>

# Nettoyer les routes DNS
cloudflared tunnel route dns clean <TUNNEL_ID>

# Voir les statistiques du tunnel
cloudflared tunnel info
```

### Résolution des problémes courants

#### Wireguard :

1. Probléme de connexion :
```bash
# Vérifier les logs
sudo journalctl -u wg-quick@wg0

# Vérifier la configuration
sudo wg show
```

2. Problème de routage :
```bash
# Vérifier le forwarding IP
sudo cat /proc/sys/net/ipv4/ip_forward

# Vérfifier les règles iptables
sudo iptables -L -n -v
```

#### Cloudflare Tunnel :

1. Tunnel non connecté :
```bash
# Vérifier le statut
sudo systemctl status cloudflared

# Vérifier les logs en détail
sudo journalctl -u cloudflared --since "5 minutes ago"
```

2. Problème DNS :
```bash
# Vérifier les routes DNS
cloudflared tunnel route list

# Tester la résolution DNS
dig +short <votre-domaine>
```

## 🌐 Accéder aux services

| Service | URL |
| --- | --- |
🔄 Traefik | https://traefik.localhost/ |
📊 MariaDB | https://mariadb.localhost:3306/ |
📊 PostgreSQL | https://postgres.localhost:5432/ |
⚡ Redis | https://redis.localhost:6379/ |
🔍 phpMyAdmin | https://phpmyadmin.localhost/ |
📊 pgAdmin | https://pgadmin.localhost/ |
📊 Grafana | https://grafana.localhost/

## 🛠 commandes make disponibles

- `make up` : Lancer la stack de Développement Docker.
- `make down` : Arret de la stack de Développement Docker.
- `make restart` : Redémarrer la stack de Développement Docker.
- `make ps` : Afficher la liste des containers de la stack de Développement Docker.
- `make init` : Initialiser la stack de Développement Docker.
- `make generate-passwords` : Genérer des mots de passe securisés.
- `make backup` : Sauvegarder les bases de données.
- `make restore` : Restaurer les bases de données.
- `make clean` : Nettoyer les ressources Docker inutilisées.
- `make logs` : Afficher les logs des containers de la stack de Développement Docker.
- `make update` : Mettre à jour la stack de Développement Docker.
- `make security-check` : Verifier la stack de Développement Docker pour les vulnérabilités.

## 🔐 Configuration SSL

Le certificat SSL est configuré automatiquement lors de la commande `make init`. Vous pouvez le voir dans le dossier `./traefik/certificates`.

1. Ajouter le certificat CA au système
```bash
sudo cp ./traefik/certificates/ca.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

2. Ajouter les entrées DNS au fichier `/etc/hosts`
```bash
echo "127.0.0.1 traefik.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 mariadb.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 postgres.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 redis.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 phpmyadmin.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 pgadmin.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 grafana.localhost" | sudo tee -a /etc/hosts
```

## 📦 Utilisation avec vos projets

Pour ajouter un nouveau projet à la stack de Développement Docker, vous pouvez utiliser les commandes suivantes :

1. Cloner le repository du projet
```bash
git clone https://github.com/cedricbb/nom-de-votre-projet.git
```

2. Copier le fichier `docker-compose.yml` dans le dossier du projet
```bash
cp ../nom-de-votre-projet/docker-compose.yml .
```

3. Editez le fichier `docker-compose.yml` et ajoutez les configurations appropriées pour votre projet.

4. Exécuter la commande `make up` pour lancer la stack de Développement Docker.
```bash
make up
```

## 🔧 Maintenance

- `make clean` : Nettoyer les ressources Docker inutilisées.
- `make logs` : Afficher les logs des containers de la stack de Développement Docker.
- `make update` : Mettre à jour la stack de Développement Docker.
- `make security-check` : Verifier la stack de Développement Docker pour les vulnérabilités.

## 🚨 Résolution des problémes courants

### ❌ Les certificats SSL ne sont pas autorisés

```bash
sudo cp ./traefik/certificates/ca.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates
```
### ❌ Services inaccessibles

```bash
make up
```

### ❌ Les bases de données sont introuvables

```bash
make backup
make restore
```

### ❌ conflit de port

Modifier les ports dans le fichier `.env` :
```bash
DATABASE_PORT=3306
POSTGRES_PORT=5432
REDIS_PORT=6379
```

## 📚 Documentation utile

- [Docker Compose](https://docs.docker.com/compose/)
- [Docker](https://www.docker.com/)
- [Traefik](https://traefik.io/)
- [MariaDB](https://mariadb.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [phpMyAdmin](https://www.phpmyadmin.net/)
- [pgAdmin](https://www.pgadmin.org/)
- [Grafana](https://grafana.com/)

## 🤝 Contribution

Si vous avez des suggestions ou des corrections, n'hesitez pas a contribuer sur [GitHub](https://github.com/cedricbb/stack-dev-enhanced).

## 📝 License

Ce projet est sous license [MIT](https://github.com/cedricbb/stack-dev-enhanced/blob/main/LICENSE).