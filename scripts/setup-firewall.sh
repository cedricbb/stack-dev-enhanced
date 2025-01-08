#!/bin/bash

echo "🔒 Configuration du pare-feu UFW..."

# Règles par défaut
ufw default deny incoming
ufw default allow outgoing

# Ports essentiels
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 51820/udp  # WireGuard

# Accès aux services uniquement via WireGuard
ufw allow from 10.0.0.0/8 to any port 3306 proto tcp  # MariaDB
ufw allow from 10.0.0.0/8 to any port 6379 proto tcp  # Redis

# Activation
ufw --force enable

echo "✅ Configuration UFW terminée"