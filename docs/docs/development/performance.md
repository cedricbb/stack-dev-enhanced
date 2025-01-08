# Performance

## 1. Optimisations B1 Pro

### 1.1 Ressources Système
```yaml
# Limites recommandées
CPU Total: 4 cœurs
RAM Total: 8GB

# Répartition
- OS + Services de base: 2GB
- MariaDB: 512MB
- Redis: 256MB
- Applications: 4-5GB restants
```

### 1.2 Surveillance Ressources
```bash
# Monitoring temps réel
make monitoring-status

# Alertes ressources
CPU_THRESHOLD=80
MEMORY_THRESHOLD=75
```

## 2. Optimisations Docker

### 2.1 Images
```dockerfile
# Multi-stage builds
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
COPY --from=builder /app/dist ./dist
```

### 2.2 Volumes
```yaml
volumes:
  # Persistance optimisée
  - mariadb_data:/var/lib/mysql
  - redis_data:/data
```

## 3. Base de Données

### 3.1 MariaDB
```ini
# my.cnf optimisations
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 2
max_connections = 50
```

### 3.2 Indexes
```sql
-- Index stratégiques
CREATE INDEX idx_frequently_searched 
ON table_name(commonly_searched_column);
```

## 4. Cache

### 4.1 Redis
```conf
# redis.conf
maxmemory 256mb
maxmemory-policy allkeys-lru
```

### 4.2 Utilisation
```typescript
// Mise en cache
const cacheKey = `user:${id}`;
await redis.set(cacheKey, JSON.stringify(data), 'EX', 3600);
```

## 5. Applications Web

### 5.1 Build Optimisation
```javascript
// vite.config.js
export default defineConfig({
  build: {
    target: 'esnext',
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom']
        }
      }
    }
  }
});
```

### 5.2 Chargement
```typescript
// Code splitting
const Component = lazy(() => import('./Component'));

// Preload
<link rel="preload" as="image" href="critical.webp" />
```

## 6. API et Requêtes

### 6.1 Rate Limiting
```yaml
# Traefik configuration
middlewares:
  rate-limit:
    rateLimit:
      average: 100
      burst: 50
```

### 6.2 Pagination
```typescript
// Pagination optimisée
const limit = 20;
const offset = (page - 1) * limit;
const results = await db.query(
  'SELECT * FROM table LIMIT ? OFFSET ?',
  [limit, offset]
);
```

## 7. Assets

### 7.1 Images
```typescript
// Optimisation images
import imagemin from 'imagemin';

const optimizeImage = async (buffer) => {
  return imagemin.buffer(buffer, {
    plugins: [
      imageminMozjpeg({ quality: 75 }),
      imageminPngquant({ quality: [0.6, 0.8] })
    ]
  });
};
```

### 7.2 Statiques
```nginx
# Configuration Nginx
location /static/ {
    expires 1y;
    add_header Cache-Control "public, no-transform";
}
```

## 8. Monitoring Performance

### 8.1 Métriques
```typescript
// Prometheus metrics
const requestDuration = new Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'status_code']
});
```

### 8.2 Logs Performance
```typescript
// Performance logging
logger.info('api_performance', {
  endpoint: '/users',
  duration: endTime - startTime,
  statusCode: 200
});
```

## 9. Optimisations Spécifiques

### 9.1 Développement
```bash
# Mode développement optimisé
NODE_ENV=development
VITE_LEGACY=false
```

### 9.2 Production
```bash
# Build production
NODE_ENV=production
VITE_LEGACY=true
```

## 10. Maintenance Performance

### 10.1 Nettoyage
```bash
# Nettoyage régulier
make clean

# Optimisation DB
make db-optimize
```

### 10.2 Surveillance
```bash
# Vérification santé
make check-health

# Analyse performance
make analyze-performance
```

## 11. Troubleshooting Performance

### 11.1 CPU Élevé
1. Identifier la source
```bash
make monitoring-status
docker stats
```

2. Actions
- Redémarrer le service concerné
- Ajuster les limites de ressources
- Optimiser le code

### 11.2 Mémoire Élevée
1. Analyse
```bash
# Vérification mémoire
free -m
docker stats
```

2. Solutions
- Nettoyage cache
- Ajustement limites
- Optimisation requêtes