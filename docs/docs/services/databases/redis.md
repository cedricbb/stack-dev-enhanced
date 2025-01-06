# Redis

## Vue d'ensemble

Redis 7 est configuré comme un système de cache et de stockage de données en mémoire, avec persistance activée et monitoring intégré.

## Configuration

### Configuration Docker

```yaml
postgres:
  container_name: redis
  restart: always
  image: redis:7-alpine
  commands: redis-server --requirepass ${REDIS_PASSWORD}
  security_opt:
    - no-new-privileges:true
  environment:
    - REDIS_PASSWORD=${REDIS_PASSWORD}
  labels:
    - traefik.enable=false
  ports:
    - 6379:6379
  networks:
    - db
```

### Variables d'Environnement

Dans votre fichier `.env` :
```bash
REDIS_PASSWORD=votre_mot_de_passe_secure
```

## Métriques et Monitoring

### Configuration Redis Exporter

```yaml
redis-exporter:
  container_name: redis-exporter
  image: oliver006/redis_exporter:latest
  depends_on:
    - redis
  environment:
    - REDIS_ADDR=redis:6379
    - REDIS_PASSWORD=${REDIS_PASSWORD}
  networks:
    - frontend
  labels:
    - traefik.enable=true
    - traefik.http.services.redis-exporter.loadbalancer.server.port=9121
```

### Métriques Disponibles

- Utilisation de la mémoire
- Connexions clients
- Opérations par seconde
- Taux de succès du cache
- Latence des commandes

### Tableaux de Bord Grafana

Des tableaux de bord préconfigurés pour :
- Performance globale
- Utilisation de la mémoire
- Statistiques des opérations
- État de la persistance

## Maintenance

### Vérification de l'État

```bash
# Status du service
docker-compose ps redis

# Logs du service
docker-compose logs -f redis

# Informations Redis
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO
```

### Nettoyage et Optimisation

```bash
# Nettoyage manuel des clés expirées
docker exec redis redis-cli -a ${REDIS_PASSWORD} FLUSHEXPIRED

# Analyse de la mémoire
docker exec redis redis-cli -a ${REDIS_PASSWORD} MEMORY STATS

# Défragmentation de la mémoire
docker exec redis redis-cli -a ${REDIS_PASSWORD} MEMORY PURGE
```

### Persistance des Données

Redis est configuré avec persitance RDB :
- Snapshots périodiques
- Sauvegarde automatique
- Restauration au démarrage

## Sécurité

### Conmfiguration Réseau

- Accès limité au rśeau `db`
- Authentification requise
- Port exposé uniquement en local
- Accès distant via VPN

### Bonnes pratiques

1. Protection par mot de passe
2. Désactivation des commandes dangereuses
3. Limitation de la mémoire maximale
4. Surveillance des connexions

## Commandes Utiles

### Connexion et Test

```bash
# Connexion CLI
docker exec -it redis redis-cli -a ${REDIS_PASSWORD}

# Test de connexion
docker exec redis redis-cli -a ${REDIS_PASSWORD} PING

# Informations serveur
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO server
```

### Gestion des Données

```bash
# Liste des clés
docker exec redis redis-cli -a ${REDIS_PASSWORD} KEYS "*"

# Obtenir une valeur
docker exec redis redis-cli -a ${REDIS_PASSWORD} GET key_name

# Définir une valeur
docker exec redis redis-cli -a ${REDIS_PASSWORD} SET key_name value

# Supprimer une clé
docker exec redis redis-cli -a ${REDIS_PASSWORD} DEL key_name
```

### Monitoring

```bash
# Clients connectés
docker exec redis redis-cli -a ${REDIS_PASSWORD} CLIENT LIST

# Statistiques de la mémoire
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO memory

# Statistiques des commandes
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO commandstats
```

### Gestion du cache

```bash
# Taux de succès du cache
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO stats | grep hit_rate

# Nettoyage complet
docker exec redis redis-cli -a ${REDIS_PASSWORD} FLUSHALL

# Nettoyage sélectif
docker exec redis redis-cli -a ${REDIS_PASSWORD} SCAN 0 MATCH "pattern:*" COUNT 100
```

## Résolution des Problèmes

### Problèmes Courants

1. Problèmes de Mémoire
```bash
# Vérification de l'utilisation mémoire
docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO memory

# Liste des grosses clés
docker exec redis redis-cli -a ${REDIS_PASSWORD} --bigkeys
```

2. Problèmes de Connexion
```bash
# Vérification des clients
docker exec redis redis-cli -a ${REDIS_PASSWORD} CLIENT LIST

# Test de latence
docker exec redis redis-cli -a ${REDIS_PASSWORD} --latency
```

3. Problèmes de Performance
```bash
# Surveillance en temps réel
docker exec redis redis-cli -a ${REDIS_PASSWORD} MONITOR

# Analyse des commandes lentes
docker exec redis redis-cli -a ${REDIS_PASSWORD} SLOWLOG GET 10
```

### Scripts de Maintenance

```bash
# Surveillance de l'utilisation mémoire
watch -n 1 'docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO memory | grep used_memory_human'

# Surveillance des connexions
watch -n 1 'docker exec redis redis-cli -a ${REDIS_PASSWORD} CLIENT LIST | wc -l'

# Surveillance des opérations
watch -n 1 'docker exec redis redis-cli -a ${REDIS_PASSWORD} INFO stats | grep ops'
```

## Optimisation

### Configuration recommandée

```bash
# Paramètres de Performance
maxmemory 2gb
maxmemory-policy allkeys-lru
maxclients 10000
timeout 300
tcp-keepalive 300
```

### Paramètres de Persistance

```bash
# Configuration RDB
save 900 1
save 300 10
save 60 10000
rdbcompression yes
rdbchecksum yes
```