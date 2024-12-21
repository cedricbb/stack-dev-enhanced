#!/bin/bash

# Définition des couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Définition des variables
CERT_DIR="./traefik/certificates"
DOMAIN_CNF="./domain.cnf"

echo -e "${YELLOW}Démarrage de la création des certificats SSL${NC}"

# Création du répertoire pour les certificats
mkdir -p $CERT_DIR

# Nettoyage des anciens certificats
echo -e "${YELLOW}Nettoyage des anciens certificats${NC}"
rm -f $CERT_DIR/*.pem $CERT_DIR/*.csr $CERT_DIR/*.crt $CERT_DIR/*.srl

# Génération de la clé privée CA
echo -e "${YELLOW}Géneration de la clé privée CA${NC}"
openssl genrsa -out $CERT_DIR/ca.key.pem 2048
chmod 400 $CERT_DIR/ca.key.pem

# Génération du certificat CA
echo -e "${YELLOW}Géneration du certificat CA${NC}"
openssl req -new -x509 \
-subj "/C=FR/ST=France/L=Lyon/O=Local Development CA/OU=Development/CN=*.localhost" \
-extensions v3_ca \
-days 3650 \
-key $CERT_DIR/ca.key.pem \
-sha256 \
-out $CERT_DIR/ca.pem \
-config $DOMAIN_CNF

# Génération de la clé privée du domaine
echo -e "${YELLOW}Géneration de la clé privée du domaine${NC}"
openssl genrsa -out $CERT_DIR/domain.key.pem 2048

echo -e "${YELLOW}Géneration de la demande de signature du certificat (CSR)${NC}"
openssl req -new \
-subj "/C=FR/ST=France/L=Lyon/O=Local Development CA/OU=Development/CN=*.localhost" \
-key $CERT_DIR/domain.key.pem \
-out $CERT_DIR/domain.csr \
-config $DOMAIN_CNF

# Signature du certificat de domaine avec le certificat CA
echo -e "${YELLOW}Signature du certificat de domaine${NC}"
openssl x509 -req \
-in $CERT_DIR/domain.csr \
-CA $CERT_DIR/ca.pem \
-CAkey $CERT_DIR/ca.key.pem \
-CAcreateserial \
-out $CERT_DIR/domain.crt \
-days 365 \
-sha256 \
-extensions v3_req \
-extfile $DOMAIN_CNF

# Vérfification des permissions sur les fichiers
echo -e "${YELLOW}Vérification des permissions sur les fichiers${NC}"
chmod 644 $CERT_DIR/domain.crt
chmod 644 $CERT_DIR/domain.key.pem

echo -e "${GREEN}Création des certificats SSL terminée${NC}"
echo -e "${YELLOW}N'oubliez pas d'autoriser le certificat CA (ca.pem) dans votre navigateur pour le domaine ${NC}"