#!/bin/bash

echo "🔒 Configuration de Fail2ban..."

# Installation
apt-get install -y fail2ban

# Configuration de base
cat > /etc/fail2ban/jail.local << EOL
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log

[traefik-auth]
enabled = true
port = 80,443
filter = traefik-auth
logpath = /var/log/traefik/access.log
maxretry = 5
findtime = 300
bantime = 3600
EOL

# Création du filtre Traefik
cat > /etc/fail2ban/filter.d/traefik-auth.conf << EOL
[Definition]
failregex = ^.*Authorization failed, invalid username or password from <HOST>.*$
ignoreregex =
EOL

# Redémarrage du service
systemctl restart fail2ban
systemctl enable fail2ban

echo "✅ Configuration Fail2ban terminée"