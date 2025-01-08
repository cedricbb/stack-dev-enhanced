# Guide d'Installation

## Prérequis

### Système
- Ubuntu Server 22.04 LTS
- Docker 24.0+
- Docker Compose v2.0+
- Make
- Git

### Matériel (B1 Pro)
- CPU : Intel N4100/N4120
- RAM : 8GB
- Stockage : 256GB SSD

## 1. Installation initiale

### 1.1 Clonage du projet
```bash
git clone https://github.com/votre-username/stack-dev.git
cd stack-dev
```

### 1.2 Configuration de base
```bash
# Création du fichier .env
cp .env.example .env

# Édition des variables
nano .env
```

Variables requises :
```env
DOMAIN_NAME=votredomaine.fr
ACME_EMAIL=votre@email.com
```

### 1.3 Initialisation
```bash
# Initialisation complète
make init
```

Cette commande :
- Crée la structure des dossiers
- Génère les secrets
- Configure les réseaux Docker
- Met en place SSL/TLS

## 2. Configuration de la Sécurité

### 2.1 Installation des prérequis
```bash
sudo apt update
sudo apt install -y ufw fail2ban wireguard
```

### 2.2 Configuration sécurité
```bash
# Configuration complète
make setup-security
```

Cette commande configure :
- WireGuard VPN
- Pare-feu UFW
- Fail2ban

## 3. Démarrage des Services

### 3.1 Lancement de la stack
```bash
make start
```

### 3.2 Vérification
```bash
# Status des services
make status

# Vérification santé
make check-health
```

## 4. Configuration DNS

### 4.1 Configuration locale
```bash
make update-hosts
```

### 4.2 Configuration DNS externe
Ajoutez ces enregistrements DNS pour votre domaine :
```text
Type    Nom              Valeur
A       @               <VOTRE_IP_SERVER>
CNAME   *              @
```

## 5. Accès aux Services

| Service    | URL                                  |
|------------|--------------------------------------|
| Traefik    | https://traefik.votredomaine.fr     |
| Portainer  | https://portainer.votredomaine.fr    |
| Netdata    | https://netdata.votredomaine.fr      |
| Docs       | https://docs.votredomaine.fr         |

## 6. Vérification et Maintenance

### 6.1 Logs
```bash
# Tous les services
make logs

# Service spécifique
docker compose logs [service]
```

### 6.2 Sauvegardes
```bash
# Sauvegarde
make backup

# Restauration
make restore BACKUP_DATE=YYYY-MM-DD-HH-MM-SS
```

## 7. Problèmes courants

### 7.1 Certificats SSL
Si les certificats ne sont pas générés :
```bash
make ssl
```

### 7.2 Services inaccessibles
```bash
# Redémarrage des services
make restart

# Vérification des logs
make logs
```

### 7.3 Problèmes de performances
```bash
# Vérification des ressources
make monitoring-status
```

## 8. Mise à jour

### 8.1 Mise à jour des services
```bash
# Arrêt des services
make stop

# Sauvegarde
make backup

# Mise à jour et redémarrage
git pull
make start
```

## 9. Prochaines étapes

Une fois l'installation terminée :
1. Configurez WireGuard sur vos appareils
2. Changez les mots de passe par défaut
3. Consultez la documentation des services