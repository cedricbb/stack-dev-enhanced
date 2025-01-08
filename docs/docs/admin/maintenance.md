# Guide de Maintenance

## 1. Monitoring

### 1.1 Surveillance des Ressources

#### Netdata
```bash
# Démarrage monitoring
make monitoring-start

# Vérification status
make monitoring-status
```

Métriques importantes :
- CPU : < 80%
- RAM : < 75%
- Swap : < 50%
- Disque : < 80%

#### Portainer
- Gestion des conteneurs
- Surveillance des logs
- Gestion des volumes

### 1.2 Vérification Santé
```bash
# Vérification complète
make check-health
```

## 2. Sauvegardes

### 2.1 Sauvegarde Régulière
```bash
# Sauvegarde manuelle
make backup

# Sauvegarde automatique (cron)
0 2 * * * cd /chemin/stack && make backup
```

### 2.2 Restauration
```bash
# Restauration complète
make restore BACKUP_DATE=YYYY-MM-DD-HH-MM-SS

# Vérification après restauration
make check-health
```

## 3. Nettoyage

### 3.1 Ressources Docker
```bash
# Nettoyage complet
make clean

# Nettoyage sélectif
docker system prune --volumes
```

### 3.2 Logs
```bash
# Rotation des logs
make logs-rotate
```

## 4. Mises à jour

### 4.1 Services
```bash
# Arrêt des services
make stop

# Sauvegarde
make backup

# Mise à jour
make update

# Redémarrage
make start
```

### 4.2 Système
```bash
# Mise à jour système
sudo apt update
sudo apt upgrade

# Redémarrage si nécessaire
sudo reboot
```

## 5. Optimisation

### 5.1 Performance

#### MariaDB
```bash
# Vérification performances
mysql -e "SHOW GLOBAL STATUS"

# Optimisation tables
mysql -e "OPTIMIZE TABLE *"
```

#### Redis
```bash
# Vérification cache
redis-cli info | grep used_memory

# Nettoyage cache
redis-cli FLUSHDB
```

### 5.2 Stockage
```bash
# Vérification espace
df -h

# Nettoyage
make clean
```

## 6. Résolution des problèmes

### 6.1 Services
```bash
# Vérification logs
make logs [service]

# Redémarrage service
docker compose restart [service]
```

### 6.2 Performance
```bash
# Si CPU > 80%
make monitoring-status
docker stats

# Si RAM > 75%
make clean
make restart
```

## 7. Maintenance Préventive

### 7.1 Quotidien
- Vérifier les logs
- Surveiller les ressources
- Vérifier les services

### 7.2 Hebdomadaire
- Faire une sauvegarde
- Nettoyer les ressources inutilisées
- Vérifier les mises à jour

### 7.3 Mensuel
- Tester les restaurations
- Optimiser les bases de données
- Vérifier les certificats

## 8. Automatisation

### 8.1 Cron Jobs
```bash
# Sauvegarde quotidienne
0 2 * * * make backup

# Nettoyage hebdomadaire
0 3 * * 0 make clean

# Vérification santé
*/15 * * * * make check-health
```

### 8.2 Alertes
Configuration dans Netdata :
- Seuils d'alerte
- Notifications
- Rapports périodiques