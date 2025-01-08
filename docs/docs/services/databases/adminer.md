# Adminer

## 1. Vue d'ensemble

Adminer est une interface web légère pour la gestion des bases de données, optimisée pour le B1 Pro.

## 2. Configuration

### 2.1 Configuration Docker
```yaml
adminer:
  container_name: adminer
  image: adminer:latest
  environment:
    - ADMINER_DEFAULT_SERVER=mariadb
    - ADMINER_DESIGN=dracula
  deploy:
    resources:
      limits:
        cpus: '0.2'
        memory: 256M
      reservations:
        memory: 64M
```

### 2.2 Accès
- URL : https://adminer.votredomaine.fr
- Serveur par défaut : mariadb
- Systèmes supportés :
  - MariaDB/MySQL
  - PostgreSQL
  - SQLite
  - MongoDB
  - Elasticsearch

## 3. Utilisation

### 3.1 Connexion
1. Accédez à https://adminer.votredomaine.fr
2. Sélectionnez le type de base de données
3. Entrez les credentials :
   - Serveur : mariadb ou postgres
   - Utilisateur : de votre base de données
   - Mot de passe : secret correspondant

### 3.2 Fonctionnalités principales
- Gestion des tables
- Exécution de requêtes SQL
- Import/Export de données
- Gestion des utilisateurs
- Monitoring de base

## 4. Sécurité

### 4.1 Accès
- Authentification requise
- Accès via HTTPS uniquement
- Protection par Traefik

### 4.2 Bonnes pratiques
- Changer les mots de passe régulièrement
- Limiter les permissions des utilisateurs
- Surveiller les logs d'accès

## 5. Performance

### 5.1 Limites de ressources
```yaml
deploy:
  resources:
    limits:
      cpus: '0.2'
      memory: 256M
```

### 5.2 Optimisations
- Interface légère
- Mise en cache des requêtes
- Chargement à la demande

## 6. Maintenance

### 6.1 Logs
```bash
# Consulter les logs
make logs adminer

# Statut du service
docker compose ps adminer
```

### 6.2 Mises à jour
```bash
# Mise à jour image
docker compose pull adminer

# Redémarrage
docker compose restart adminer
```

## 7. Troubleshooting

### 7.1 Problèmes courants
1. Erreur de connexion
   - Vérifier les credentials
   - Vérifier l'accès à la base de données
   - Vérifier les logs

2. Performance lente
   - Vérifier les ressources allouées
   - Nettoyer le cache navigateur
   - Optimiser les requêtes

### 7.2 Solutions
```bash
# Redémarrage rapide
make restart-adminer

# Vérification santé
make check-health
```

## 8. Bonnes Pratiques

### 8.1 Utilisation
- Limiter les requêtes lourdes
- Utiliser les exports avec précaution
- Éviter les modifications en production

### 8.2 Sécurité
- Accès uniquement via VPN en production
- Surveillance des actions critiques
- Backups avant modifications importantes