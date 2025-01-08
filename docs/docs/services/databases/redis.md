# Redis

## 1. Configuration Optimisée B1 Pro

### 1.1 Configuration Docker
```yaml
# docker-compose.yml
services:
  redis:
    image: redis:7-alpine
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          cpus: '0.2'
          memory: 256M
        reservations:
          memory: 64M
```

### 1.2 Configuration Redis
```conf
# config/redis/redis.conf
# Mémoire
maxmemory 256mb
maxmemory-policy allkeys-lru

# Persistance
appendonly yes
appendfsync everysec

# Connexions
maxclients 50
timeout 300

# Sécurité
protected-mode yes
```

## 2. Gestion

### 2.1 Commandes de base
```bash
# Connexion
docker compose exec redis redis-cli -a ${REDIS_PASSWORD}

# Monitoring
redis-cli info

# Nettoyage
redis-cli FLUSHDB  # Base courante
redis-cli FLUSHALL # Toutes les bases
```

### 2.2 Surveillance
```bash
# Stats en temps réel
redis-cli --stat

# Monitoring
redis-cli monitor
```

## 3. Maintenance

### 3.1 Nettoyage
```bash
# Nettoyage cache
make redis-clean

# Optimisation
make redis-optimize
```

### 3.2 Maintenance régulière
```bash
# Vérification
redis-cli --scan | wc -l  # Nombre de clés

# Statistiques
redis-cli info | grep used_memory
```

## 4. Sécurité

### 4.1 Authentification
```bash
# Changement mot de passe
make redis-password

# Vérification accès
redis-cli ping
```

### 4.2 Réseau
```yaml
networks:
  backend:  # Réseau interne uniquement
```

## 5. Performance

### 5.1 Monitoring
```bash
# Stats mémoire
redis-cli info memory

# Stats clients
redis-cli info clients
```

### 5.2 Optimisation
```bash
# Configuration mémoire
redis-cli config set maxmemory-policy allkeys-lru
redis-cli config set maxmemory "256mb"
```

## 6. Politique de Cache

### 6.1 Configuration
```conf
# Politique d'éviction
maxmemory-policy allkeys-lru  # Least Recently Used
# Échantillons pour éviction
maxmemory-samples 5
```

### 6.2 Gestion
```bash
# Statistiques éviction
redis-cli info stats | grep evicted

# Taille actuelle
redis-cli info memory | grep used_memory_human
```

## 7. Persistance

### 7.1 Configuration
```conf
# AOF
appendonly yes
appendfsync everysec

# RDB
save 900 1    # 15 min si 1 changement
save 300 10   # 5 min si 10 changements
save 60 10000 # 1 min si 10000 changements
```

### 7.2 Gestion
```bash
# Sauvegarde manuelle
redis-cli BGSAVE

# Status persistance
redis-cli info persistence
```

## 8. Troubleshooting

### 8.1 Problèmes courants
```bash
# Logs
docker compose logs redis

# Connexions
redis-cli client list
```

### 8.2 Performance
```bash
# Commandes lentes
redis-cli SLOWLOG GET

# Clients bloqués
redis-cli CLIENT LIST
```

## 9. Monitoring

### 9.1 Métriques importantes
```bash
# Usage mémoire
used_memory_human
used_memory_peak_human

# Clients
connected_clients
blocked_clients

# Performance
instantaneous_ops_per_sec
hit_rate
```

### 9.2 Alertes
```bash
# Seuils d'alerte
maxmemory-warning 75%  # Alerte à 75% utilisation
```

## 10. Bonnes Pratiques

### 10.1 Quotidien
- Vérifier usage mémoire
- Surveiller nombre de connexions
- Monitorer les évictions

### 10.2 Hebdomadaire
- Analyse des clés
- Vérification persistance
- Nettoyage si nécessaire

### 10.3 Mensuel
- Optimisation configuration
- Revue des politiques de cache
- Test de charge