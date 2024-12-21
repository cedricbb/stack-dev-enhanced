# 🚀 Stack de Développement Docker

Cette stack de Développement Docker est une collection de services Docker qui permettent de faciliter le développement et la gestion de projets.

## 📋 Prérequis

- Docker
- Docker Compose
- Git
- Make
- OpenSSL

## 📦 Services Inclus

| Service | Version |Description |
| --- | --- | --- |
🔄 Traefik | v2.10 | Reverse Proxy & Load Balancer
📊 MariaDB | 10.11 | Base de données MySQL
📊 PostgreSQL | 15 | Base de données PostgreSQL
⚡ Redis | 7 | Base de données Redis
🔍 phpMyAdmin | 5.2 | Interface de gestion de bases de données MySQL
📊 pgAdmin | 6 | Interface de gestion de bases de données PostgreSQL
📊 Grafana | 9 | Interface de gestion de dashboards

## 🏗 Structure du projet

Le projet est structuré en trois parties principales:

- **services**: Contient les services Docker composant la stack de Développement Docker.
- **configs**: Contient les fichiers de configuration des services Docker.
- **certs**: Contient les fichiers de certificats SSL.

## 🚦 Guide de démarrage

### 1️⃣  Configuration initiale

1. Clonez le dépôt
```bash
git clone https://github.com/cedricbb/stack-dev-enhanced.git

cd stack-dev-enhanced
```

2. Copiez le fichier `.env.example` et renommez-le en `.env`
```bash
cp .env.example .env
```

3. Editez le fichier `.env` et executez la commande `make generate-passwords` pour générer des mots de passe securisés.
```bash
make generate-passwords
```

### 2️⃣ Initialisation de la stack

1. Exécuter la commande `make init` pour initialiser la stack de Développement Docker.
```bash
make init
```

2. Exécuter la commande `make up` pour lancer la stack de Développement Docker.
```bash
make up
```

## 🌐 Accéder aux services

| Service | URL |
| --- | --- |
🔄 Traefik | https://traefik.localhost/ |
📊 MariaDB | https://mariadb.localhost:3306/ |
📊 PostgreSQL | https://postgres.localhost:5432/ |
⚡ Redis | https://redis.localhost:6379/ |
🔍 phpMyAdmin | https://phpmyadmin.localhost/ |
📊 pgAdmin | https://pgadmin.localhost/ |
📊 Grafana | https://grafana.localhost/

## 🛠 commandes make disponibles

- `make up` : Lancer la stack de Développement Docker.
- `make down` : Arret de la stack de Développement Docker.
- `make restart` : Redémarrer la stack de Développement Docker.
- `make ps` : Afficher la liste des containers de la stack de Développement Docker.
- `make init` : Initialiser la stack de Développement Docker.
- `make generate-passwords` : Genérer des mots de passe securisés.
- `make backup` : Sauvegarder les bases de données.
- `make restore` : Restaurer les bases de données.
- `make clean` : Nettoyer les ressources Docker inutilisées.
- `make logs` : Afficher les logs des containers de la stack de Développement Docker.
- `make update` : Mettre à jour la stack de Développement Docker.
- `make security-check` : Verifier la stack de Développement Docker pour les vulnérabilités.

## 🔐 Configuration SSL

Le certificat SSL est configuré automatiquement lors de la commande `make init`. Vous pouvez le voir dans le dossier `./traefik/certificates`.

1. Ajouter le certificat CA au système
```bash
sudo cp ./traefik/certificates/ca.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

2. Ajouter les entrées DNS au fichier `/etc/hosts`
```bash
echo "127.0.0.1 traefik.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 mariadb.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 postgres.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 redis.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 phpmyadmin.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 pgadmin.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 grafana.localhost" | sudo tee -a /etc/hosts
```

## 📦 Utilisation avec vos projets

Pour ajouter un nouveau projet à la stack de Développement Docker, vous pouvez utiliser les commandes suivantes :

1. Cloner le repository du projet
```bash
git clone https://github.com/cedricbb/nom-de-votre-projet.git
```

2. Copier le fichier `docker-compose.yml` dans le dossier du projet
```bash
cp ../nom-de-votre-projet/docker-compose.yml .
```

3. Editez le fichier `docker-compose.yml` et ajoutez les configurations appropriées pour votre projet.

4. Exécuter la commande `make up` pour lancer la stack de Développement Docker.
```bash
make up
```

## 🔧 Maintenance

- `make clean` : Nettoyer les ressources Docker inutilisées.
- `make logs` : Afficher les logs des containers de la stack de Développement Docker.
- `make update` : Mettre à jour la stack de Développement Docker.
- `make security-check` : Verifier la stack de Développement Docker pour les vulnérabilités.

## 🚨 Résolution des problémes courants

### ❌ Les certificats SSL ne sont pas autorisés

```bash
sudo cp ./traefik/certificates/ca.pem /usr/local/share/ca-certificates/
sudo update-ca-certificates
```
### ❌ Services inaccessibles

```bash
make up
```

### ❌ Les bases de données sont introuvables

```bash
make backup
make restore
```

### ❌ conflit de port

Modifier les ports dans le fichier `.env` :
```bash
DATABASE_PORT=3306
POSTGRES_PORT=5432
REDIS_PORT=6379
```

## 📚 Documentation utile

- [Docker Compose](https://docs.docker.com/compose/)
- [Docker](https://www.docker.com/)
- [Traefik](https://traefik.io/)
- [MariaDB](https://mariadb.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [phpMyAdmin](https://www.phpmyadmin.net/)
- [pgAdmin](https://www.pgadmin.org/)
- [Grafana](https://grafana.com/)

## 🤝 Contribution

Si vous avez des suggestions ou des corrections, n'hesitez pas a contribuer sur [GitHub](https://github.com/cedricbb/stack-dev-enhanced).

## 📝 License

Ce projet est sous license [MIT](https://github.com/cedricbb/stack-dev-enhanced/blob/main/LICENSE).