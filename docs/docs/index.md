# 🚀 Stack de Développement Docker

Cette stack de développement Docker est une collection complète de services pour faciliter le développement et la gestion de projets.

## 📋 Documentation

La documentation complète est disponible dans le dossier `docs/` :

### 🏗️ Installation et Configuration
- [Guide d'Installation](docs/getting-started/installation.md)
- [Guide de Configuration](docs/getting-started/configuration.md)

### 🔐 Sécurité
- [Accès à Distance](docs/security/remote-access.md)
- [Mesures de Sécurité](docs/security/security-measures.md)

### 📊 Services
#### Bases de Données
- [MariaDB](docs/services/databases/mariadb.md)
- [PostgreSQL](docs/services/databases/postgresql.md)
- [Redis](docs/services/databases/redis.md)

#### Monitoring
- [Prometheus](docs/services/monitoring/prometheus.md)
- [Grafana](docs/services/monitoring/grafana.md)
- [cAdvisor](docs/services/monitoring/cadvisor.md)

#### Métriques
- [Exporters de Métriques](docs/services/metrics/exporters.md)

#### Administration
- [Interfaces d'Administration](docs/services/management/admin-interfaces.md)

### 🛠️ Maintenance
- [Guide de Maintenance](docs/maintenance/maintenance.md)

## 📦 Services Inclus

| Service | Version | Description |
| --- | --- | --- |
| 🔄 Traefik | v2.10 | Reverse Proxy & Load Balancer |
| 📊 MariaDB | 10.11 | Base de données MySQL |
| 📊 PostgreSQL | 15 | Base de données PostgreSQL |
| ⚡ Redis | 7 | Base de données Redis |
| 🔍 phpMyAdmin | 5.2 | Interface MariaDB |
| 📊 pgAdmin | 6 | Interface PostgreSQL |
| 📊 Grafana | 9 | Visualisation de métriques |
| 📊 Prometheus | latest | Collecte de métriques |
| 📊 cAdvisor | latest | Monitoring conteneurs |

## 🚦 Démarrage Rapide

```bash
# Clonage du projet
git clone https://github.com/votre-username/stack-dev-enhanced.git
cd stack-dev-enhanced

# Configuration
cp .env.example .env
make generate-passwords

# Initialisation et démarrage
make init
make up
```

## 🛠️ Commandes Principales

```bash
make up              # Démarrer la stack
make down            # Arrêter la stack
make ps              # Status des services
make logs            # Logs des services
make backup          # Sauvegarder les données
make restore         # Restaurer les données
make update          # Mettre à jour la stack
```

## 🌐 Accès aux Services

Tous les services sont accessibles via HTTPS :
- https://traefik.localhost - Dashboard Traefik
- https://phpmyadmin.localhost - Interface MariaDB
- https://pgadmin.localhost - Interface PostgreSQL
- https://grafana.localhost - Visualisation
- https://prometheus.localhost - Métriques

## 🤝 Contribution

Les contributions sont bienvenues ! N'hésitez pas à :
1. Forker le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commiter vos changements (`git commit -am 'Ajout de fonctionnalité'`)
4. Pusher la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence [MIT](LICENSE).