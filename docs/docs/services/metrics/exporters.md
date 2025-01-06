# Exporters de Métriques

Ce document détaille la configuration et l'utilisation des différents exporters de métriques de la stack.

## Redis Exporter

### Configuration Docker

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
    - traefik.http.routers.redis-exporter.rule=Host(`redis-exporter.localhost`)
    - traefik.http.routers.redis-exporter.entrypoints=websecure
    - traefik.http.routers.redis-exporter.tls=true
    - traefik.http.services.redis-exporter.loadbalancer.server.port=9121
```

### Métriques Principales

```promql
# Connexions
redis_connected_clients

# Mémoire
redis_memory_used_bytes
redis_memory_max_bytes

# Performances
redis_commands_total
redis_commands_duration_seconds_total

# Cache
redis_keyspace_hits_total
redis_keyspace_misses_total
```

### Tableau de Bord Grafana

```json
{
  "title": "Redis Metrics",
  "panels": [
    {
      "title": "Commands per Second",
      "targets": [{
        "expr": "rate(redis_commands_total[5m])"
      }]
    },
    {
      "title": "Memory Usage",
      "targets": [{
        "expr": "redis_memory_used_bytes"
      }]
    },
    {
      "title": "Connected Clients",
      "targets": [{
        "expr": "redis_connected_clients"
      }]
    }
  ]
}
```

## PostgreSQL Exporter

### Configuration Docker

```yaml
postgres-exporter:
  container_name: postgres-exporter
  image: prometheuscommunity/postgres-exporter:latest
  environment:
    - DATA_SOURCE_NAME=postgresql://user:password@postgres:5432/
  networks:
    - frontend
  labels:
    - traefik.enable=true
    - traefik.http.routers.postgres-exporter.rule=Host(`postgres-exporter.localhost`)
    - traefik.http.services.postgres-exporter.loadbalancer.server.port=9187
```

### Métriques Principales

```promql
# Activité des bases
pg_stat_database_numbackends
pg_stat_database_xact_commit
pg_stat_database_xact_rollback

# Performance des requêtes
pg_stat_statements_total_time_seconds
pg_stat_statements_calls

# Taille des bases
pg_database_size_bytes

# Réplication
pg_stat_replication_lag_bytes
```

### Tableau de Bord Grafana

```json
{
  "title": "PostgreSQL Metrics",
  "panels": [
    {
      "title": "Active Connections",
      "targets": [{
        "expr": "pg_stat_database_numbackends"
      }]
    },
    {
      "title": "Transaction Rate",
      "targets": [{
        "expr": "rate(pg_stat_database_xact_commit[5m])"
      }]
    },
    {
      "title": "Database Size",
      "targets": [{
        "expr": "pg_database_size_bytes"
      }]
    }
  ]
}
```

## MariaDB Metrics

### Configuration Docker

```yaml
mariadb-metrics:
  image: bitnami/mysqld-exporter:latest
  container_name: mariadb-metrics
  command:
    - "--mysqld.username=root:secure_password"
    - "--mysqld.address=127.0.0.1:3306"
  ports:
    - "9104:9104"
  networks:
    - frontend
    - db
  depends_on:
    - mariadb
```

### Métriques Principales

```promql
# Connexions
mysql_global_status_threads_connected
mysql_global_status_threads_running

# Performance
mysql_global_status_questions
mysql_global_status_slow_queries

# InnoDB
mysql_global_status_innodb_row_reads
mysql_global_status_innodb_row_writes

# Cache
mysql_global_status_qcache_hits
mysql_global_status_qcache_inserts
```

### Tableau de Bord Grafana

```json
{
  "title": "MariaDB Metrics",
  "panels": [
    {
      "title": "Active Threads",
      "targets": [{
        "expr": "mysql_global_status_threads_connected"
      }]
    },
    {
      "title": "Query Rate",
      "targets": [{
        "expr": "rate(mysql_global_status_questions[5m])"
      }]
    },
    {
      "title": "InnoDB Operations",
      "targets": [{
        "expr": "rate(mysql_global_status_innodb_row_reads[5m])"
      }]
    }
  ]
}
```

## Configuration Prometheus Commune

### Scraping Configuration

```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
    metrics_path: /metrics
    scrape_interval: 15s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
    metrics_path: /metrics
    scrape_interval: 15s

  - job_name: 'mariadb'
    static_configs:
      - targets: ['mariadb-metrics:9104']
    metrics_path: /metrics
    scrape_interval: 15s
```

## Alertes

### Règles d'Alerte Communes

```yaml
groups:
  - name: database_alerts
    rules:
      # Redis
      - alert: RedisHighMemoryUsage
        expr: redis_memory_used_bytes / redis_memory_max_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage high"

      # PostgreSQL
      - alert: PostgresHighConnections
        expr: pg_stat_database_numbackends > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High number of Postgres connections"

      # MariaDB
      - alert: MariaDBHighThreads
        expr: mysql_global_status_threads_connected > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High number of MariaDB connections"
```

## Maintenance

### Vérification de l'État

```bash
# Vérification des exporters
for exporter in redis-exporter postgres-exporter mariadb-metrics; do
    echo "=== $exporter ==="
    docker-compose ps $exporter
    curl -s localhost:9121/metrics | head -n 5  # Redis
    curl -s localhost:9187/metrics | head -n 5  # Postgres
    curl -s localhost:9104/metrics | head -n 5  # MariaDB
done
```

### Scripts Utiles

```bash
#!/bin/bash
# check_metrics.sh

check_exporter() {
    local name=$1
    local port=$2
    echo "Checking $name on port $port..."
    
    if curl -s localhost:$port/metrics > /dev/null; then
        echo "✅ $name metrics available"
    else
        echo "❌ $name metrics unavailable"
    fi
}

check_exporter "Redis" 9121
check_exporter "Postgres" 9187
check_exporter "MariaDB" 9104
```

## Résolution des Problèmes

### Problèmes Courants

1. Métriques Non Disponibles
```bash
# Vérification des logs
docker-compose logs redis-exporter
docker-compose logs postgres-exporter
docker-compose logs mariadb-metrics

# Test des connexions
docker exec redis-exporter wget -qO- localhost:9121/metrics
docker exec postgres-exporter wget -qO- localhost:9187/metrics
docker exec mariadb-metrics wget -qO- localhost:9104/metrics
```

2. Problèmes d'Authentification
```bash
# Vérification des variables d'environnement
docker-compose config

# Test des connexions aux bases
docker exec redis-exporter redis-cli -h redis ping
docker exec postgres-exporter psql -h postgres -U postgres -c "SELECT 1"
docker exec mariadb-metrics mysqladmin -h mariadb -u root ping
```