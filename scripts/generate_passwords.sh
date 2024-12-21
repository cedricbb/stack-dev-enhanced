#!/bin/bash

#fonction pour générer un mot de passe aléatoire
generate_password() {
    openssl rand -base64 24
}

# Création du fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    touch .env
fi

# Génération des mots de passe
echo "DATABASE_USER_PASSWORD=$(generate_password)" >> .env
echo "POSTGRES_DATABASE_PASSWORD=$(generate_password)" >> .env
echo "REDIS_PASSWORD=$(generate_password)" >> .env
echo "GRAFANA_PASSWORD=$(generate_password)" >> .env

echo "Mots de passe générés et ajoutés au fichier .env"

