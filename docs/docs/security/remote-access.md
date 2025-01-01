# Accès à Ditance Sécurisé

Ce guide détaille la configuration de l'accès à distance sécurisé pour la stack de développement, en utilisant Wireguard pour le VPN et Cloudflare Tunnel pour l'exposition des services.

## 1. Configuration Wireguard

### 1.1 Installation

```bash
sudo ./scripts/setup-wireguard.sh
```

Ce script automatise :
- L'installation des paquets nécessaires
- La génération des clés
- La configuration du serveur
- L'activation du service

### 1.2 Configuration du Serveur

Le fichier `/etc/wireguard/wg0.conf` est automatiquement généré avec :

```bash
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIps = 10.0.0.2/32
```

### 1.3 Configuration du Client

Un fichier de configuration client est généré dans `/etc/wireguard/client.conf` :

```bash
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <SERVER_PUBLIC_IP>:51820
AllowedIps = 0.0.0.0/0
PersistentKeepalive = 25
```

### 1.4 Activation et Gestion

```bash
# Démarrage du service Wireguard
sudo systemctl start wg-quick@wg0

# Activation au démarrage
sudo systemctl enable wg-quick@wg0

# Vérification du statut
sudo systemctl status wg-quick@wg0

# Vérification de la connexion
sudo wg show
```

## 2. Configuration de Cloudflare Tunnel

### 2.1 Installation

```bash
sudo ./scripts/setup-cloudflare.sh
```

Le script :
- Installe Cloudflared
- Configure le depot Cloudflare
- Prépare l'environnement de configuration

### 2.2 Configuration

1. Authentification :
```bash
cloudflared login
```
2. Création du tunnel :
```bash
cloudflared tunnel create stack-dev
```
3. Configuration du tunnel (~/.cloudflared/config.yml):
```bash
tunnel : <TUNNEL_ID>
credentials-file : /root/cloudflared/<TUNNEL_ID>.json

ingress:
    # Traefik Dashboard
    - hostname: traefik.votre-domaine.com
    service: http://localhost:8080
    originRequest:
        noTLSVerify: true
    
    # Bases de données
    - hostname: mariadb.votre-domaine.com
    service: http://localhost:3306
    - hostname: postgres.votre-domaine.com
    service: http://localhost:5432
    - hostname: redis.votre-domaine.com
    service: http://localhost:6379

    # Interfaces d'administration
    - hostname: pgadmin.votre-domaine.com
    service: http://localhost:5050
    - hostname: phpmyadmin.votre-domaine.com
    service: http://localhost:80
    - hostname: grafana.votre-domaine.com
    service: http://localhost:3000

    # Route par defaut
    - service: http_status:404
```

### 2.3 DNS et Routage

Configuration des routes DNS pour chaque service:
```bash
cloudflared tunnel route dns <TUNNEL_ID> <SOUS_DOMAINE>
```

### 2.4 Service et Démarrage

```bash
# Installation du service
sudo cloudflared service install

# Démarrage
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

## 3. Maintenance et Surveillance

### 3.1 Commandes Wireguard

```bash
# Status de la connexion
sudo wg show

# Redémarrage
sudo systemctl restart wg-quick@wg0

# logs
sudo journalctl -u wg-quick@wg0
```

### 3.2 Commandes Cloudflare

```bash
# liste des tunnels
cloudflared tunnel list

# Status du service
sudo systemctl status cloudflared

# logs
sudo journalctl -u cloudflared -f

# Test des connexions
curl -v http://votre-domaine.com
```

## 4. Résolution des Problemes

### 4.1 Wireguard

1. Problème de connexion :
```bash
# Vérification du forwarding IP
sudo cat /proc/sys/net/ipv4/ip_forward

# Vérification des règles iptables
sudo iptables -L -n -v
```

2. Problème de routage :
```bash
# Vérification de la configuration
sudo wg show
sudo journalctl -u wg-quick@wg0
```

### 4.2 Cloudflare Tunnel

1. Tunnel non connecté :
```bash
# Vérification détaillée
sudo systemctl status cloudflared
sudo journalctl -u cloudflared --since "5 minutes ago"
```

2. Problème DNS :
```bash
# Vérification des routes
cloudflared tunnel route list

# Tester la résolution DNS
dig +short votre-domaine.com
```

## 5. Sécurité

### 5.1 Bonnes pratiques Wireguard

- Utilisez des clés uniques pour chaque client
- Limitez les AllowedIPs aux réseaux nécessaires
- Activez le PersistentKeppAlive pour les conneions stables
- Mettez à jour régulièrement le système et Wireguard

### 5.2 Bonnes pratiques Cloudflare

- Activez l'authentification à deux facteurs
- Utilisez des tkens d'accès limités
- Surveillez les logs d'accès
- Configuez les règles WAF appropriées