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
{
    echo "# MariaDB passwords"
    echo "DATABASE_ROOT_USER=root"
    echo "DATABASE_ROOT_PASSWORD=$(generate_password)"
    echo "# PostgreSQL passwords"
    echo "POSTGRES_DATABASE_USER=postgres"
    echo "POSTGRES_DATABASE_PASSWORD=$(generate_password)"
    echo "# PGAdmin passwords"
    echo "PGADMIN_DEFAULT_EMAIL=admin@admin.com"
    echo "PGADMIN_DEFAULT_PASSWORD=$(generate_password)"
    echo "# Redis passwords"
    echo "REDIS_PASSWORD=$(generate_password)"
    echo "# Grafana passwords"
    echo "GRAFANA_PASSWORD=$(generate_password)"
    echo "# Traefik passwords"
    echo "TRAEFIK_DASHBOARDS_USER=admin"
    echo "TRAEFIK_DASHBOARDS_PASSWORD=$(generate_password)"
} > .env

echo "Mots de passe générés et ajoutés au fichier .env"

