#!/bin/bash

# Définition des couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Instaling Cloudflared...${NC}"

#Téléchargement de la clé GPG Cloudflare
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

#Ajout du repo Cloudflare
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] http://pkg.cloudflare.com/cloudflare $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare.list

# Installation de Cloudflared
apt-get update && apt-get install -y cloudflared

# Création du répertoire de configuration
mkdir -p /etc/cloudflared

echo -e "${GREEN}Cloudflared installation completed!${NC}"
echo -e "${YELLOW}Please run 'cloudflared login' to authenticate with your Cloudflare account${NC}"