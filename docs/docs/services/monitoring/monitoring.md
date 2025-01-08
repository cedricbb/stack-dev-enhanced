# 🔍 Monitoring de la Stack

## Services de monitoring

### 🐋 Portainer

Portainer est une interface web qui permet de gérer facilement vos conteneurs Docker.

#### Fonctionnalités principales :
- Gestion des conteneurs
- Gestion des volumes
- Gestion des réseaux
- Gestion des images
- Gestion des stacks Docker Compose
- Surveillance des ressources

#### Accès :
- URL : https://portainer.localhost
- Identifiant par défaut : admin
- Mot de passe : défini dans le fichier .env

### 📊 Netdata

Netdata est un outil de monitoring en temps réel pour les systèmes et les applications.

#### Fonctionnalités principales :
- Monitoring système en temps réel
- Métriques détaillées
- Alertes configurables
- Intégration avec Netdata Cloud
- Surveillance des conteneurs Docker

#### Accès :
- URL : https://netdata.localhost
- Pas d'authentification locale requise
- Pour Netdata Cloud : configuration via NETDATA_CLAIM_TOKEN

## Configuration

### Portainer

1. Premier accès :
```bash
# Créer le mot de passe admin
make portainer-password
```

2. Configuration des endpoints :
- Local -> déjà configuré
- Remote -> Ajouter vos endpoints distants

3. Configuration des utilisateurs :
- Aller dans Settings -> Users
- Créer des utilisateurs avec les permissions appropriées

### Netdata

1. Configuration de Netdata Cloud :
```bash
# Configurer l'intégration avec Netdata Cloud
make netdata-claim
```

2. Configuration des alertes :
- Éditer `/etc/netdata/health.d/*.conf`
- Redémarrer Netdata pour appliquer les changements

3. Configuration des collecteurs :
- Éditer `/etc/netdata/python.d/*.conf`
- Activer/désactiver les collecteurs selon vos besoins

## Maintenance

### Sauvegardes

1. Sauvegarder les données :
```bash
# Sauvegarde complète
make monitoring-backup
```

2. Restaurer les données :
```bash
# Restauration à partir d'une sauvegarde
make monitoring-restore BACKUP_DATE=YYYY-MM-DD-HH-MM-SS
```

### Logs

```bash
# Voir les logs des services de monitoring
make monitoring-logs

# Voir le status
make monitoring-status
```

### Mise à jour

```bash
# Mettre à jour les services
make update

# Redémarrer les services
make monitoring-stop
make monitoring-start
```

## Sécurité

### Portainer

1. Bonnes pratiques :
- Changer le mot de passe admin régulièrement
- Utiliser des tokens API plutôt que des mots de passe
- Limiter les permissions des utilisateurs
- Activer l'authentification à deux facteurs

2. Configuration SSL :
- Utilise déjà TLS via Traefik
- Vérifier les certificats régulièrement

### Netdata

1. Bonnes pratiques :
- Limiter l'accès au dashboard via un reverse proxy
- Configurer des alertes pour les événements de sécurité
- Surveiller les logs pour détecter les activités suspectes

2. Configuration du pare-feu :
- Port 19999 accessible uniquement via Traefik
- Limiter l'accès aux métriques sensibles

## Troubleshooting

### Portainer

1. Interface inaccessible :
```bash
# Vérifier le status
make monitoring-status

# Redémarrer le service
make monitoring-stop
make monitoring-start
```

2. Problèmes d'authentification :
```bash
# Réinitialiser le mot de passe admin
make portainer-password
```

### Netdata

1. Métriques manquantes :
```bash
# Vérifier les logs
docker-compose logs netdata

# Redémarrer le service
docker-compose restart netdata
```

2. Problèmes de performance :
- Vérifier la configuration des resources Docker
- Ajuster les intervalles de collecte
- Désactiver les collecteurs non utilisés

## Commandes make disponibles

| Commande | Description |
|----------|-------------|
| `monitoring-start` | Démarrer les services de monitoring |
| `monitoring-stop` | Arrêter les services de monitoring |
| `monitoring-logs` | Afficher les logs |
| `monitoring-status` | Vérifier le status |
| `portainer-password` | Changer le mot de passe Portainer |
| `netdata-claim` | Configurer Netdata Cloud |
| `monitoring-backup` | Sauvegarder les données |
| `monitoring-restore` | Restaurer les données |