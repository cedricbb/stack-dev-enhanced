# Accès à Distance

## 1. Configuration WireGuard

### 1.1 Installation du serveur
```bash
# Installation et configuration
make setup-wireguard
```

### 1.2 Configuration serveur
```ini
# /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

### 1.3 Client
```ini
# /etc/wireguard/client.conf
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = votre-ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## 2. Configuration Pare-feu

### 2.1 UFW
```bash
# Installation et configuration
make setup-firewall
```

### 2.2 Règles
```bash
# Ports autorisés
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 51820/udp  # WireGuard

# Services internes via VPN uniquement
ufw allow from 10.0.0.0/8 to any port 3306  # MariaDB
ufw allow from 10.0.0.0/8 to any port 6379  # Redis
```

## 3. Configuration Fail2ban

### 3.1 Installation
```bash
# Installation et configuration
make setup-fail2ban
```

### 3.2 Configuration
```ini
# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[traefik-auth]
enabled = true
port = 80,443
maxretry = 5
```

## 4. DNS et Domaine

### 4.1 Configuration DNS
```text
Type    Nom    Valeur
A       @      <VOTRE_IP>
CNAME   *      @
```

### 4.2 Sous-domaines
- traefik.votredomaine.fr
- portainer.votredomaine.fr
- docs.votredomaine.fr

## 5. SSL/TLS

### 5.1 Let's Encrypt
Configuration automatique via Traefik :
- Renouvellement automatique
- Challenge TLS
- Certificats wildcard

### 5.2 Sécurité
```yaml
# Traefik headers
headers:
  sslRedirect: true
  forceSTSHeader: true
  stsSeconds: 31536000
  stsIncludeSubdomains: true
```

## 6. Monitoring à Distance

### 6.1 Accès aux services
- Portainer : https://portainer.votredomaine.fr
- Netdata : https://netdata.votredomaine.fr

### 6.2 Sécurité
- Accès uniquement via VPN
- Authentification requise
- Rate limiting activé

## 7. Maintenance à Distance

### 7.1 Commandes disponibles
```bash
# Status des services
make status

# Logs
make logs

# Santé
make check-health
```

### 7.2 Sécurité
- Session SSH limitées
- Clés SSH uniquement
- Fail2ban actif

## 8. Résolution des Problèmes

### 8.1 VPN
```bash
# Vérification WireGuard
sudo wg show
sudo systemctl status wg-quick@wg0

# Logs
sudo journalctl -u wg-quick@wg0
```

### 8.2 Connexion
```bash
# Status Fail2ban
sudo fail2ban-client status

# Déblocage IP
sudo fail2ban-client set traefik-auth unbanip <IP>
```

## 9. Bonnes Pratiques

### 9.1 Sécurité
- Changer régulièrement les clés VPN
- Surveiller les logs d'accès
- Maintenir les règles de pare-feu à jour

### 9.2 Performance
- Limiter le nombre de connexions simultanées
- Monitorer la bande passante
- Optimiser les configurations réseau