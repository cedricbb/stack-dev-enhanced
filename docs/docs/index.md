# Stack de Développement Optimisée B1 Pro

## Vue d'ensemble

Cette stack de développement est optimisée pour fonctionner sur un BMAX B1 Pro avec :
- CPU : Intel N4100/N4120
- RAM : 8GB
- Stockage : 256GB SSD

## Services

| Service | Description | Port | URL |
|---------|-------------|------|-----|
| Traefik | Reverse Proxy | 80/443 | traefik.votredomaine.fr |
| MariaDB | Base de données | 3306 | - |
| Redis | Cache | 6379 | - |
| Portainer | Gestion Docker | 9000 | portainer.votredomaine.fr |
| Netdata | Monitoring | 19999 | netdata.votredomaine.fr |
| Documentation | MkDocs | 8000 | docs.votredomaine.fr |
| Service | Description | Port | URL |
| Adminer | Interface BDD | 8080 | adminer.votredomaine.fr |

## Démarrage Rapide

1. Installation
```bash
git clone https://github.com/votre-repo/stack-dev.git
cd stack-dev
make init
```

2. Configuration
```bash
# Générer les secrets
make generate-secrets

# Configurer VPN
make setup-wireguard
```

3. Démarrage
```bash
make start
```

## Organisation du Projet

```plaintext
.
├── config/          # Configurations des services
├── secrets/         # Secrets Docker
├── scripts/         # Scripts d'administration
├── docs/           # Documentation
└── docker-compose.yml
```

## Sécurité

- VPN WireGuard pour accès distant
- Pare-feu UFW configuré
- Fail2ban activé
- Let's Encrypt pour SSL/TLS

## Fonctionnalités

### Développement
- Support multi-projets
- Hot reload optimisé
- Environnement isolé
- Documentation intégrée

### Monitoring
- Surveillance ressources
- Alertes configurables
- Logs centralisés
- Interface web

### Sécurité
- VPN intégré
- SSL/TLS automatique
- Secrets sécurisés
- Accès restreint

## Utilisation

### Commandes Principales
```bash
make start         # Démarrer la stack
make stop          # Arrêter la stack
make status        # Voir le status
make logs          # Voir les logs
```

### Développement
```bash
make create-project    # Nouveau projet
make dev              # Mode développement
make build            # Build production
```

### Monitoring
```bash
make monitoring-status  # Status services
make check-health      # Vérification santé
```

## Limitations B1 Pro

### Ressources
- CPU : Limité à 4 cœurs
- RAM : Maximum 8GB
- Stockage : Selon SSD

### Recommandations
- Maximum 3-4 projets simultanés
- Build séquentiel
- Monitoring actif des ressources

## Documentation Détaillée

- [Guide d'Installation](getting-started/installation.md)
- [Configuration](getting-started/configuration.md)
- [Sécurité](security/security-measures.md)

## Contribution

1. Fork le projet
2. Créez une branche (`git checkout -b feature/amélioration`)
3. Commit (`git commit -am 'Ajout fonctionnalité'`)
4. Push (`git push origin feature/amélioration`)
5. Créez une Pull Request

## Support

- Documentation : https://docs.votredomaine.fr
- Issues : GitHub Issues
- Wiki : GitHub Wiki
