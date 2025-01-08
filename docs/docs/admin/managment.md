# Guide de Gestion

## 1. Gestion des Services

### 1.1 Commandes de base
```bash
# Démarrage/Arrêt
make start
make stop
make restart

# Status
make status
make logs
```

### 1.2 Gestion des ressources
```bash
# Vérification ressources
make monitoring-status

# Nettoyage
make clean
```

## 2. Gestion des Containers

### 2.1 Limites de ressources
```yaml
# Optimisation B1 Pro
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      memory: 256M
```

### 2.2 Monitoring
```bash
# Status détaillé
docker stats

# Logs conteneur spécifique
docker compose logs [service]
```

## 3. Gestion des Données

### 3.1 Volumes
```yaml
volumes:
  mariadb_data:
  redis_data:
  portainer_data:
```

### 3.2 Sauvegardes
```bash
# Sauvegarde complète
make backup

# Restauration
make restore BACKUP_DATE=YYYY-MM-DD
```

## 4. Gestion des Accès

### 4.1 VPN
```bash
# Status VPN
make vpn-status

# Nouveau client
make vpn-add-client
```

### 4.2 Authentification
- Gestion via Traefik
- Authentification BasicAuth
- Rate limiting

## 5. Maintenance

### 5.1 Mises à jour
```bash
# Mise à jour services
make update

# Mise à jour système
sudo apt update && sudo apt upgrade
```

### 5.2 Nettoyage
```bash
# Nettoyage Docker
make clean

# Nettoyage logs
make logs-rotate
```

## 6. Monitoring

### 6.1 Surveillance temps réel
```bash
# Status services
make monitoring-status

# Logs en direct
make logs
```

### 6.2 Alertes
- Configuration Netdata
- Alertes email
- Notifications Slack

## 7. Résolution des problèmes

### 7.1 Services
```bash
# Vérification santé
make check-health

# Redémarrage service
docker compose restart [service]
```

### 7.2 Performance
```bash
# Si CPU > 80%
make monitoring-status
make clean

# Si RAM > 75%
make clean
make restart
```

## 8. Documentation

### 8.1 Accès
```bash
# Serveur documentation
make docs-serve

# Build documentation
make docs-build
```

### 8.2 Mise à jour
```bash
# Mise à jour docs
make docs-update
```

## 9. Sécurité

### 9.1 Vérifications
```bash
# Vérification sécurité
make security-check

# Logs sécurité
make security-logs
```

### 9.2 Maintenance
```bash
# Rotation secrets
make generate-secrets

# Mise à jour sécurité
make security-update
```

## 10. Optimisations

### 10.1 Performance
- Monitoring ressources
- Ajustement limites
- Nettoyage régulier

### 10.2 Automatisation
```bash
# Cron jobs
0 2 * * * make backup
0 3 * * 0 make clean
*/15 * * * * make check-health
```

## 11. Bonnes Pratiques

### 11.1 Quotidien
- Vérifier les logs
- Surveiller les ressources
- Vérifier la santé

### 11.2 Hebdomadaire
- Sauvegarde complète
- Nettoyage ressources
- Vérification mises à jour

### 11.3 Mensuel
- Test restauration
- Audit sécurité
- Optimisation ressources# Guide de Gestion

## 1. Gestion des Services

### 1.1 Commandes de base
```bash
# Démarrage/Arrêt
make start
make stop
make restart

# Status
make status
make logs
```

### 1.2 Gestion des ressources
```bash
# Vérification ressources
make monitoring-status

# Nettoyage
make clean
```

## 2. Gestion des Containers

### 2.1 Limites de ressources
```yaml
# Optimisation B1 Pro
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      memory: 256M
```

### 2.2 Monitoring
```bash
# Status détaillé
docker stats

# Logs conteneur spécifique
docker compose logs [service]
```

## 3. Gestion des Données

### 3.1 Volumes
```yaml
volumes:
  mariadb_data:
  redis_data:
  portainer_data:
```

### 3.2 Sauvegardes
```bash
# Sauvegarde complète
make backup

# Restauration
make restore BACKUP_DATE=YYYY-MM-DD
```

## 4. Gestion des Accès

### 4.1 VPN
```bash
# Status VPN
make vpn-status

# Nouveau client
make vpn-add-client
```

### 4.2 Authentification
- Gestion via Traefik
- Authentification BasicAuth
- Rate limiting

## 5. Maintenance

### 5.1 Mises à jour
```bash
# Mise à jour services
make update

# Mise à jour système
sudo apt update && sudo apt upgrade
```

### 5.2 Nettoyage
```bash
# Nettoyage Docker
make clean

# Nettoyage logs
make logs-rotate
```

## 6. Monitoring

### 6.1 Surveillance temps réel
```bash
# Status services
make monitoring-status

# Logs en direct
make logs
```

### 6.2 Alertes
- Configuration Netdata
- Alertes email
- Notifications Slack

## 7. Résolution des problèmes

### 7.1 Services
```bash
# Vérification santé
make check-health

# Redémarrage service
docker compose restart [service]
```

### 7.2 Performance
```bash
# Si CPU > 80%
make monitoring-status
make clean

# Si RAM > 75%
make clean
make restart
```

## 8. Documentation

### 8.1 Accès
```bash
# Serveur documentation
make docs-serve

# Build documentation
make docs-build
```

### 8.2 Mise à jour
```bash
# Mise à jour docs
make docs-update
```

## 9. Sécurité

### 9.1 Vérifications
```bash
# Vérification sécurité
make security-check

# Logs sécurité
make security-logs
```

### 9.2 Maintenance
```bash
# Rotation secrets
make generate-secrets

# Mise à jour sécurité
make security-update
```

## 10. Optimisations

### 10.1 Performance
- Monitoring ressources
- Ajustement limites
- Nettoyage régulier

### 10.2 Automatisation
```bash
# Cron jobs
0 2 * * * make backup
0 3 * * 0 make clean
*/15 * * * * make check-health
```

## 11. Bonnes Pratiques

### 11.1 Quotidien
- Vérifier les logs
- Surveiller les ressources
- Vérifier la santé

### 11.2 Hebdomadaire
- Sauvegarde complète
- Nettoyage ressources
- Vérification mises à jour

### 11.3 Mensuel
- Test restauration
- Audit sécurité
- Optimisation ressources