# Mesures de Sécurité

## 1. Secrets et Authentification

### 1.1 Secrets Docker
```yaml
# docker-compose.yml
secrets:
  db_root_password:
    file: ./secrets/db_root_password.txt
```

### 1.2 Génération Sécurisée
```bash
# Génération de nouveaux secrets
make generate-secrets

# Rotation des secrets
make generate-secrets
make restart
```

## 2. Sécurité des Services

### 2.1 Traefik
```yaml
# Headers de sécurité
security_headers:
  # Protection XSS
  browserXssFilter: true
  # Protection MIME sniffing
  contentTypeNosniff: true
  # HSTS
  stsSeconds: 31536000
  stsIncludeSubdomains: true
  # Frames
  customFrameOptionsValue: "SAMEORIGIN"
```

### 2.2 Bases de données
- Accès uniquement depuis les réseaux internes
- Authentification par secrets
- Pas d'exposition directe des ports

### 2.3 Redis
- Protection par mot de passe
- Limite de mémoire stricte
- Accès restreint au réseau backend

## 3. Sécurité Réseau

### 3.1 Réseaux Docker
```yaml
networks:
  frontend:    # Pour services exposés
  backend:     # Pour services internes
  db:          # Pour bases de données
```

### 3.2 Pare-feu (UFW)
```bash
# Règles essentielles
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 51820/udp  # WireGuard
```

### 3.3 Fail2ban
```ini
# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[traefik-auth]
enabled = true
port = 80,443
```

## 4. Protection contre les Attaques

### 4.1 Rate Limiting
```yaml
# Traefik configuration
middlewares:
  rate-limit:
    rateLimit:
      average: 100
      burst: 50
```

### 4.2 Protection DDoS
- Fail2ban actif
- Rate limiting
- Headers de sécurité

### 4.3 Filtrage IP
```yaml
middlewares:
  ipwhitelist:
    ipWhiteList:
      sourceRange:
        - "10.0.0.0/8"  # VPN
```

## 5. SSL/TLS

### 5.1 Let's Encrypt
```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      email: your@email.com
      storage: /letsencrypt/acme.json
      tlsChallenge: true
```

### 5.2 Configuration TLS
- TLS 1.3 uniquement
- Certificats automatiques
- HSTS activé

## 6. Monitoring de Sécurité

### 6.1 Logs
```bash
# Surveillance des logs
make logs

# Logs de sécurité
tail -f /var/log/auth.log
```

### 6.2 Alertes
- Notifications Fail2ban
- Alertes Netdata
- Surveillance des ressources

## 7. Maintenance Sécurité

### 7.1 Mises à jour
```bash
# Mise à jour système
sudo apt update && sudo apt upgrade

# Mise à jour services
make update
```

### 7.2 Vérifications
```bash
# Vérification sécurité
make security-check

# Santé des services
make check-health
```

## 8. Sauvegardes Sécurisées

### 8.1 Backup
```bash
# Sauvegarde chiffrée
make backup

# Vérification intégrité
make verify-backup
```

### 8.2 Restauration
```bash
# Restauration sécurisée
make restore BACKUP_DATE=YYYY-MM-DD
```

## 9. VPN (WireGuard)

### 9.1 Configuration
```ini
# /etc/wireguard/wg0.conf
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

### 9.2 Gestion
```bash
# Status
wg show

# Redémarrage
systemctl restart wg-quick@wg0
```

## 10. Bonnes Pratiques

### 10.1 Sécurité Système
- Updates automatiques critiques
- Fail2ban actif
- Pare-feu configuré
- VPN pour accès admin

### 10.2 Sécurité Application
- Rate limiting actif
- Headers sécurisés
- HTTPS forcé
- Secrets sécurisés

### 10.3 Monitoring
- Logs centralisés
- Alertes configurées
- Surveillance ressources
- Audit régulier