#!/bin/bash

# Définition des couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables de configuration
WG_DIR="/etc/wireguard"
SERVER_PORT=51820
SERVER_INTERFACE="wg0"

echo -e "${YELLOW}Installing Wireguard...${NC}"
apt-get update
apt-get install -y wireguard wireguard-tools

# Création des clés du serveur
echo -e "${YELLOW}Generating server keys...${NC}"
wg genkey | tee "${WG_DIR}/server_private.key" | wg pubkey > "${WG_DIR}/server_public.key"
chmod 600 "${WG_DIR}/server_private.key"

# Création des clés client
echo -e "${YELLOW}Generating client keys...${NC}"
wg genkey | tee "${WG_DIR}/client_private.key" | wg pubkey > "${WG_DIR}/client_public.key"
chmod 600 "${WG_DIR}/client_private.key"

# Configuration du serveur
SERVER_PRIVATE_KEY=$(cat "${WG_DIR}/server_private.key")
CLIENT_PUBLIC_KEY=$(cat "${WG_DIR}/client_public.key")

echo -e "${YELLOW}Creating server configuration...${NC}"
cat > "${WG_DIR}/${SERVER_INTERFACE}.conf" << EOF
[Interface]
PrivateKey = ${SERVER_PRIVATE_KEY}
Adress = 10.0.0.1/24
ListenPort = ${SERVER_PORT}
PostUp = iptables -A FORWARD -i ${SERVER_INTERFACE} -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i ${SERVER_INTERFACE} -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIps = 10.0.0.2/32
EOF

chmod 600 "${WG_DIR}/${SERVER_INTERFACE}.conf"

# Création de la configuration client
SERVER_PUBLIC_KEY=$(cat "${WG_DIR}/server_public.key")
CLIENT_PRIVATE_KEY=$(cat "${WG_DIR}/client_private.key")

echo -e "${YELLOW}Creating client configuration...${NC}"
cat > "${WG_DIR}/client.conf" << EOF
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = <SERVER_IP>:${SERVER_PORT}
AllowedIps = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Activation du forwarding IP
echo -e "${YELLOW}Enabling IP forwarding...${NC}"
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

# Démarrage du service
echo -e "${YELLOW}Starting Wireguard service...${NC}"
systemctl enable wg-quick@${SERVER_INTERFACE}
systemctl start wg-quick@${SERVER_INTERFACE}

echo -e "${GREEN}Wireguard setup [OK]${NC}"
echo -e "${YELLOW}Don't forget to replace <SERVER_IP> in ${WG_DIR}/client.conf with your server's public IP address${NC}"
echo -e "${YELLOW}Client configuration is available at: ${WG_DIR}/client.conf${NC}"