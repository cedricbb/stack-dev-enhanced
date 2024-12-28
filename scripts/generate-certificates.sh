#!/bin/bash

# Définition des couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Définition des variables
CERT_DIR="./traefik/certificates"
DOMAIN_CNF="./traefik/domain.cnf"

echo -e "${YELLOW}Starting SSL certificates generation...${NC}"

# Création du répertoire des certificats
mkdir -p $CERT_DIR

# Nettoyage des anciens certificats
echo "Cleaning old certificates..."
rm -f $CERT_DIR/*.pem $CERT_DIR/*.crt $CERT_DIR/*.csr $CERT_DIR/*.srl

# Génération de la clé privée CA
echo "Generating CA private key..."
openssl genrsa -aes256 -out $CERT_DIR/ca.key.pem 2048
chmod 400 $CERT_DIR/ca.key.pem

# Génération du certificat CA
echo "Generating CA certificate..."
openssl req -new -x509 \
    -subj "/C=FR/ST=France/L=Lyon/O=Local Development CA/OU=Development/CN=*.localhost" \
    -extensions v3_ca \
    -days 3650 \
    -key $CERT_DIR/ca.key.pem \
    -sha256 \
    -out $CERT_DIR/ca.pem \
    -config $DOMAIN_CNF

# Génération de la clé privée du domaine
echo "Generating domain private key..."
openssl genrsa -out $CERT_DIR/domain.key.pem 2048

# Génération de la demande de signature de certificat (CSR)
echo "Generating Certificate Signing Request..."
openssl req \
    -subj "/C=FR/ST=France/L=Lyon/O=Local Development/OU=Development/CN=*.localhost" \
    -extensions v3_req \
    -sha256 \
    -new \
    -key $CERT_DIR/domain.key.pem \
    -out $CERT_DIR/domain.csr

# Signature du certificat final
echo "Signing domain certificate..."
openssl x509 -req \
    -extensions v3_req \
    -days 3650 \
    -sha256 \
    -in $CERT_DIR/domain.csr \
    -CA $CERT_DIR/ca.pem \
    -CAkey $CERT_DIR/ca.key.pem \
    -CAcreateserial \
    -out $CERT_DIR/domain.crt \
    -extfile $DOMAIN_CNF

# Vérification des permissions
chmod 644 $CERT_DIR/domain.crt
chmod 644 $CERT_DIR/domain.key.pem

echo -e "${GREEN}SSL certificates generation completed!${NC}"
echo -e "${YELLOW}Don't forget to trust the CA certificate (ca.pem) in your browser/system${NC}"