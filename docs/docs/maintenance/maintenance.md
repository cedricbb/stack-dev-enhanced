# Guide de Maintenance

Ce guide détaille les procédures de maintenance pour la stack de développement complète.

## Maintenance Quotidienne

### 1. Vérification de l'État

```bash
# Vérification des services
make ps

# Vérification de la santé
make health-check

# Surveillance des logs
make logs
```

### 2. Surveillance des Métriques

1. Dashboard Grafana
   - Utilisation CPU/Mémoire
   - Statistiques des bases de données
   - Taux d'erreurs
   - Latence des services

2. Vérification des Alertes
```bash
# État des alertes Prometheus
curl -s http://prometheus:9090/api/v1/alerts

# Statut des règles d'alerte
curl -s http://prometheus:9090/api/v1/rules
```

## Maintenance Hebdomadaire

### 1. Sauvegardes

```bash
# Sauvegarde complète
make backup

# Vérification des sauvegardes
ls -lh ./dumps/

# Test de restauration (environnement de test)
make restore-test
```

### 2. Nettoyage

```bash
# Nettoyage des ressources Docker inutilisées
make clean

# Nettoyage des logs anciens
sudo find /var/log/docker/ -mtime +7 -delete

# Nettoyage des sauvegardes anciennes
find ./dumps/ -mtime +30 -delete
```

### 3. Optimisation des Bases de Données

#### MariaDB
```bash
# Analyse des tables
docker exec mariadb mysqlcheck -u root -p --all-databases --analyze

# Optimisation
docker exec mariadb mysqlcheck -u root -p --all-databases --optimize
```

#### PostgreSQL
```bash
# VACUUM ANALYZE
docker exec postgres vacuumdb --all --analyze --verbose

# Maintenance des index
docker exec postgres reindexdb --all --verbose
```

#### Redis
```bash
# Nettoyage des clés expirées
docker exec redis redis-cli FLUSHEXPIRED

# Défragmentation
docker exec redis redis-cli MEMORY PURGE
```

## Maintenance Mensuelle

### 1. Mises à Jour

```bash
# Mise à jour des images
make update

# Vérification des versions
docker-compose images

# Application des mises à jour de sécurité
make security-update
```

### 2. Audit de Sécurité

```bash
# Scan de vulnérabilités
make security-check

# Vérification des permissions
make permissions-check

# Audit des accès
make access-audit
```

### 3. Révision des Performances

1. Analyse des Métriques
   - Tendances d'utilisation
   - Points de congestion
   - Optimisations nécessaires

2. Ajustement des Ressources
   - Allocation mémoire
   - Limites CPU
   - Espace disque

## Maintenance Trimestrielle

### 1. Test de Restauration Complet

```bash
# Environnement de test
make create-test-env
make restore-test

# Validation des données
make validate-restore
```

### 2. Révision des Configurations

1. Traefik
   - Certificats SSL
   - Règles de routage
   - Middlewares

2. Base de Données
   - Paramètres de performance
   - Configuration de réplication
   - Politiques de backup

3. Monitoring
   - Règles d'alerte
   - Rétention des métriques
   - Dashboards

## Procédures d'Urgence

### 1. Récupération après Incident

```bash
# Arrêt propre
make down

# Sauvegarde d'urgence
make emergency-backup

# Restauration
make emergency-restore
```

### 2. Basculement de Services

```bash
# Basculement base de données
make db-failover

# Restauration service
make service-restore
```

## Scripts de Maintenance

### check_stack_health.sh
```bash
#!/bin/bash

echo "=== Stack Health Check ==="

# Vérification des services
docker-compose ps

# Vérification des métriques
for service in prometheus grafana cadvisor; do
    echo "=== $service metrics ==="
    curl -s http://$service:9090/metrics | head -n 5
done

# Vérification des bases de données
echo "=== Database Check ==="
docker exec mariadb mysqladmin ping
docker exec postgres pg_isready
docker exec redis redis-cli ping

echo "=== Done ==="
```

### cleanup_resources.sh
```bash
#!/bin/bash

echo "=== Cleaning Resources ==="

# Nettoyage Docker
docker system prune -f

# Nettoyage des logs
sudo find /var/log/docker/ -mtime +7 -delete

# Nettoyage des sauvegardes
find ./dumps/ -mtime +30 -delete

echo "=== Done ==="
```

## Liste de Contrôle Maintenance

### Quotidien
- [ ] Vérification des services actifs
- [ ] Surveillance des logs d'erreur
- [ ] Vérification des alertes
- [ ] Espace disque disponible

### Hebdomadaire
- [ ] Exécution des sauvegardes
- [ ] Nettoyage des ressources
- [ ] Optimisation des bases de données
- [ ] Vérification des métriques de performance

### Mensuel
- [ ] Mise à jour des images Docker
- [ ] Audit de sécurité
- [ ] Révision des performances
- [ ] Test de restauration partiel

### Trimestriel
- [ ] Test de restauration complet
- [ ] Révision des configurations
- [ ] Mise à jour documentation
- [ ] Audit des accès utilisateurs