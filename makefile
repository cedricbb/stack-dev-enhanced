# Inclure les variables d'environnement
include .env
export $(shell sed 's/=.*//' .env)

# Définition de la date
DATE := $(shell /bin/date "+%Y-%m-%d-%H-%M-%S")

# Couleurs
_END        = \033[0m
_BOLD       = \033[1m
_GREEN      = \033[32m
_YELLOW     = \033[33m

# Commandes principales
.PHONY: init setup-secrets generate-secrets create-dirs networks ssl start stop restart status logs clean

init: create-dirs setup-secrets networks ssl copy-dockerfiles ## Initialisation complète
	@echo "${_GREEN}${_BOLD}✅ Installation terminée${_END}"

# Configuration des secrets
setup-secrets: ## Crée et configure les secrets
	@echo "${_YELLOW}${_BOLD}🔐 Configuration des secrets...${_END}"
	@mkdir -p ./secrets
	@chmod 700 ./secrets
	@make generate-secrets

generate-secrets: ## Génère de nouveaux secrets
	@echo "${_YELLOW}${_BOLD}🔑 Génération des secrets...${_END}"
	@openssl rand -base64 32 > ./secrets/db_root_password.txt
	@openssl rand -base64 32 > ./secrets/redis_password.txt
	@openssl rand -base64 32 > ./secrets/portainer_password.txt
	@chmod 600 ./secrets/*
	@echo "${_GREEN}${_BOLD}✅ Secrets générés${_END}"

# Structure des dossiers
create-dirs: ## Crée la structure des dossiers
	@echo "${_YELLOW}${_BOLD}📁 Création des dossiers...${_END}"
	# Dossiers de configuration
	@mkdir -p ./config/{traefik,docs}
	# Dossiers system
	@mkdir -p ./scripts
	@mkdir -p ./secrets
	@mkdir -p ./docs
	# Dossiers Docker
	@mkdir -p ./docker/dev/{node,php,python}
	@mkdir -p ./docker/prod/{node,php,python}
	# Dossiers des projets
	@mkdir -p ./projects/{next,nuxt,symfony,python,wordpress,angular,react,vue}
	# Dossiers data
	@mkdir -p ./data
	@mkdir -p ./dumps
	# Permissions
	@chmod 755 ./config ./scripts ./docs ./docker ./projects
	@chmod 700 ./secrets
	@echo "${_GREEN}${_BOLD}✅ Structure des dossiers créée${_END}"

# Configuration réseau
networks: ## Crée les réseaux Docker
	@echo "${_YELLOW}${_BOLD}🌐 Création des réseaux...${_END}"
	@docker network create frontend 2>/dev/null || true
	@docker network create backend 2>/dev/null || true
	@docker network create db 2>/dev/null || true
	@echo "${_GREEN}${_BOLD}✅ Réseaux créés${_END}"

# SSL/TLS
ssl: ## Configure SSL/TLS avec Let's Encrypt
	@echo "${_YELLOW}${_BOLD}🔒 Configuration SSL...${_END}"
	@chmod +x ./scripts/ssl.sh
	@./scripts/ssl.sh
	@echo "${_GREEN}${_BOLD}✅ SSL configuré${_END}"

copy-dockerfiles: ## Copie les Dockerfiles par défaut
	@echo "${_YELLOW}${_BOLD}📝 Copie des Dockerfiles...${_END}"
	@cp ./docker/templates/dev/node/Dockerfile ./docker/dev/node/
	@cp ./docker/templates/dev/php/Dockerfile ./docker/dev/php/
	@cp ./docker/templates/dev/python/Dockerfile ./docker/dev/python/
	@cp ./docker/templates/prod/node/Dockerfile ./docker/prod/node/
	@cp ./docker/templates/prod/php/Dockerfile ./docker/prod/php/
	@cp ./docker/templates/prod/python/Dockerfile ./docker/prod/python/
	@echo "${_GREEN}${_BOLD}✅ Dockerfiles copiés${_END}"

check-structure: ## Vérifie la structure des dossiers
	@echo "${_YELLOW}${_BOLD}🔍 Vérification de la structure...${_END}"
	@test -d ./config || (echo "❌ Dossier config manquant" && exit 1)
	@test -d ./docker/{dev,prod}/{node,php,python} || (echo "❌ Dossiers Docker manquants" && exit 1)
	@test -d ./projects/{next,nuxt,symfony,python} || (echo "❌ Dossiers projets manquants" && exit 1)
	@test -d ./scripts || (echo "❌ Dossier scripts manquant" && exit 1)
	@test -d ./secrets || (echo "❌ Dossier secrets manquant" && exit 1)
	@test -d ./docs || (echo "❌ Dossier docs manquant" && exit 1)
	@echo "${_GREEN}${_BOLD}✅ Structure vérifiée${_END}"

# Gestion des conteneurs
start: ## Démarre la stack
	@echo "${_YELLOW}${_BOLD}🚀 Démarrage de la stack...${_END}"
	@docker-compose up -d
	@echo "${_GREEN}${_BOLD}✅ Stack démarrée${_END}"

stop: ## Arrête la stack
	@echo "${_YELLOW}${_BOLD}🛑 Arrêt de la stack...${_END}"
	@docker-compose down
	@echo "${_GREEN}${_BOLD}✅ Stack arrêtée${_END}"

restart: stop start ## Redémarre la stack

status: ## Affiche le status des conteneurs
	@echo "${_YELLOW}${_BOLD}📊 Status des conteneurs${_END}"
	@docker-compose ps

logs: ## Affiche les logs
	@docker-compose logs -f

# Sauvegarde et restauration
.PHONY: backup restore

backup: ## Sauvegarde les données
	@echo "${_YELLOW}${_BOLD}💾 Sauvegarde...${_END}"
	@mkdir -p ./backups/$(DATE)
	@chmod +x ./scripts/backup.sh
	@./scripts/backup.sh $(DATE)
	@echo "${_GREEN}${_BOLD}✅ Sauvegarde terminée${_END}"

restore: ## Restaure une sauvegarde
	@if [ -z "$(BACKUP_DATE)" ]; then \
		echo "${_RED}${_BOLD}⚠️ BACKUP_DATE requis. Usage: make restore BACKUP_DATE=YYYY-MM-DD-HH-MM-SS${_END}"; \
		exit 1; \
	fi
	@echo "${_YELLOW}${_BOLD}📦 Restauration...${_END}"
	@./scripts/restore.sh $(BACKUP_DATE)
	@echo "${_GREEN}${_BOLD}✅ Restauration terminée${_END}"

# Monitoring
.PHONY: monitoring-start monitoring-stop monitoring-logs monitoring-status

monitoring-start: ## Démarre le monitoring
	@echo "${_YELLOW}${_BOLD}📊 Démarrage du monitoring...${_END}"
	@docker-compose up -d portainer netdata
	@echo "${_GREEN}${_BOLD}✅ Monitoring démarré${_END}"

monitoring-stop: ## Arrête le monitoring
	@echo "${_YELLOW}${_BOLD}🛑 Arrêt du monitoring...${_END}"
	@docker-compose stop portainer netdata
	@echo "${_GREEN}${_BOLD}✅ Monitoring arrêté${_END}"

monitoring-logs: ## Affiche les logs du monitoring
	@docker-compose logs -f portainer netdata

monitoring-status: ## Status du monitoring
	@echo "${_YELLOW}${_BOLD}📊 Status du monitoring${_END}"
	@docker-compose ps portainer netdata

# Documentation
.PHONY: docs-serve docs-build docs-stop

docs-serve: ## Démarre le serveur de documentation
	@echo "${_YELLOW}${_BOLD}📚 Démarrage de la documentation...${_END}"
	@docker-compose up -d docs
	@echo "${_GREEN}${_BOLD}✅ Documentation disponible sur docs.${DOMAIN_NAME}${_END}"

docs-build: ## Compile la documentation
	@echo "${_YELLOW}${_BOLD}🏗️ Compilation de la documentation...${_END}"
	@docker-compose run --rm docs mkdocs build
	@echo "${_GREEN}${_BOLD}✅ Documentation compilée${_END}"

docs-stop: ## Arrête le serveur de documentation
	@docker-compose stop docs

# Maintenance
clean: ## Nettoie les ressources inutilisées
	@echo "${_YELLOW}${_BOLD}🧹 Nettoyage...${_END}"
	@docker system prune -f --volumes
	@echo "${_GREEN}${_BOLD}✅ Nettoyage terminé${_END}"

update-hosts: ## Met à jour le fichier hosts
	@echo "${_YELLOW}${_BOLD}📝 Mise à jour de /etc/hosts...${_END}"
	@echo "127.0.0.1 ${DOMAIN_NAME}" | sudo tee -a /etc/hosts
	@echo "127.0.0.1 docs.${DOMAIN_NAME}" | sudo tee -a /etc/hosts
	@echo "127.0.0.1 portainer.${DOMAIN_NAME}" | sudo tee -a /etc/hosts
	@echo "127.0.0.1 netdata.${DOMAIN_NAME}" | sudo tee -a /etc/hosts
	@echo "${_GREEN}${_BOLD}✅ /etc/hosts mis à jour${_END}"

# Surveillance
check-health: ## Vérifie la santé des services
	@echo "${_YELLOW}${_BOLD}🏥 Vérification de la santé...${_END}"
	@chmod +x ./scripts/health_check.sh
	@./scripts/health_check.sh
	@echo "${_GREEN}${_BOLD}✅ Vérification terminée${_END}"

# Aide
help: ## Affiche l'aide
	@echo "Usage: make [commande]"
	@echo ""
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Sécurité
.PHONY: setup-security setup-wireguard setup-firewall setup-fail2ban

setup-security: ## Configure tous les aspects de sécurité
	@echo "${_YELLOW}${_BOLD}🔒 Configuration de la sécurité...${_END}"
	@make setup-wireguard
	@make setup-firewall
	@make setup-fail2ban
	@echo "${_GREEN}${_BOLD}✅ Sécurité configurée${_END}"

setup-wireguard: ## Configure WireGuard
	@echo "${_YELLOW}${_BOLD}🔒 Configuration de WireGuard...${_END}"
	@chmod +x ./scripts/setup-wireguard.sh
	@sudo ./scripts/setup-wireguard.sh
	@echo "${_GREEN}${_BOLD}✅ WireGuard configuré${_END}"

setup-firewall: ## Configure le pare-feu UFW
	@echo "${_YELLOW}${_BOLD}🔒 Configuration du pare-feu...${_END}"
	@chmod +x ./scripts/setup-firewall.sh
	@sudo ./scripts/setup-firewall.sh
	@echo "${_GREEN}${_BOLD}✅ Pare-feu configuré${_END}"

setup-fail2ban: ## Configure Fail2ban
	@echo "${_YELLOW}${_BOLD}🔒 Configuration de Fail2ban...${_END}"
	@chmod +x ./scripts/setup-fail2ban.sh
	@sudo ./scripts/setup-fail2ban.sh
	@echo "${_GREEN}${_BOLD}✅ Fail2ban configuré${_END}"

# Commandes Adminer
adminer-logs: ## Affiche les logs d'Adminer
	@echo "${_YELLOW}${_BOLD}📋 Logs Adminer...${_END}"
	@docker-compose logs -f adminer

adminer-restart: ## Redémarre Adminer
	@echo "${_YELLOW}${_BOLD}🔄 Redémarrage Adminer...${_END}"
	@docker-compose restart adminer
	@echo "${_GREEN}${_BOLD}✅ Adminer redémarré${_END}"

adminer-status: ## Statut d'Adminer
	@echo "${_YELLOW}${_BOLD}📊 Status Adminer${_END}"
	@docker-compose ps adminer

# Création de projets
next-create: ## Crée un nouveau projet Next.js
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/next/$$name && \
	docker-compose run --rm -w /projects/next/$$name node-dev \
		npx create-next-app . \
		--typescript \
		--tailwind \
		--src-dir \
		--app \
		--import-alias "@/*" && \
	echo "✅ Projet Next.js '$$name' créé"

nuxt-create: ## Crée un nouveau projet Nuxt
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/nuxt/$$name && \
	docker-compose run --rm -w /projects/nuxt/$$name node-dev \
		npx nuxi init . && \
	echo "✅ Projet Nuxt '$$name' créé"

symfony-create: ## Crée un nouveau projet Symfony
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/symfony/$$name && \
	docker-compose run --rm -w /projects/symfony/$$name php-dev \
		composer create-project symfony/skeleton . && \
	echo "✅ Projet Symfony '$$name' créé"

python-create: ## Crée un nouveau projet Python
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/python/$$name && \
	docker-compose run --rm -w /projects/python/$$name python-dev \
		python -m venv venv && \
		source venv/bin/activate && \
		pip install && \
	echo "✅ Projet Python '$$name' créé"

wordpress-create: ## Crée un nouveau projet Wordpress avec Bedrock
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/wordpress/$$name && \
	docker-compose run --rm -w /projects/wordpress/$$name php-dev \
		composer create-project roots/bedrock . && \
	echo "✅ Projet Wordpress '$$name' créé"

angular-create: ## Crée un nouveau projet Angular
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/angular/$$name && \
	docker-compose run --rm -w /projects/angular/$$name node-dev \
		npx @angular/cli new . --directory=. --style=scss --routing=true --skip-git && \
	echo "✅ Projet Angular '$$name' créé"

react-create: ## Crée un nouveau projet React
	@read -p "Nom du projet: " name; \
	mkdir -p ./projects/react/$$name && \
	docker-compose run --rm -w /projects/react/$$name node-dev \
		npx create-react-app . \
		--template typescript --legacy-peer-deps && \
	echo "✅ Projet React '$$name' créé"
	
# Développement
next-dev: ## Lance le serveur de développement Next.js
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/next/$$name node-dev \
		npm run dev -- --port 3000 --hostname 0.0.0.0

nuxt-dev: ## Lance le serveur de développement Nuxt
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/nuxt/$$name node-dev \
		npm run dev -- --port 3000 --host 0.0.0.0

symfony-dev: ## Lance le serveur de développement Symfony
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/symfony/$$name php-dev \
		symfony serve --port=8000 --no-tls --allow-http

angular-dev: ## Lance le serveur de développement Angular
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/angular/$$name node-dev \
		ng serve --port 4200 --host 0.0.0.0 --disable-host-check

react-dev: ## Lance le serveur de développement React
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/react/$$name node-dev \
		PORT=3000 HOST=0.0.0.0 npm start

vue-dev: ## Lance le serveur de développement Vue.js
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/vue/$$name node-dev \
		npm run dev -- --port 5173 --host 0.0.0.0

python-dev: ## Lance le serveur de développement Python
	@read -p "Nom du projet: " name; \
	docker-compose run --force-rm -w /projects/python/$$name python-dev \
		python app.py

wordpress-dev: ## Lance le serveur de développement Wordpress
	@read -p "Nom du projet: " name; \
	docker-compose run --force-rm -w /projects/wordpress/$$name php-dev \
		composer install && \
		wp server --host=0.0.0.0

# Build production
next-build: ## Build Next.js pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/next/$$name node-dev \
		npm run build && npm run lint

nuxt-build: ## Build Nuxt pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/nuxt/$$name node-dev \
		npm run build && npm run generate

symfony-build: ## Build Symfony pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/symfony/$$name php-dev \
		composer install --no-dev --optimize-autoloader && \
		composer dump-env prod && \
		php bin/console cache:clear --env=prod

angular-build: ## Build Angular pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/angular/$$name node-dev \
		ng build --configuration production --optimization

react-build: ## Build React pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/react/$$name node-dev \
		npm run build && npm run lint

vue-build: ## Build Vue.js pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/vue/$$name node-dev \
		npm run type-check && npm run build

python-build: ## Build Python pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --force-rm -w /projects/python/$$name python-dev \
		python -m build

wordpress-build: ## Build Wordpress pour production
	@read -p "Nom du projet: " name; \
	docker-compose run --force-rm -w /projects/wordpress/$$name php-dev \
		composer install --no-dev --optimize-autoloader && \
		composer update --no-dev

# Installation dépendances
next-install: ## Installe les dépendances Next.js
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/next/$$name node-dev \
		npm install && npm audit fix

nuxt-install: ## Installe les dépendances Nuxt
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/nuxt/$$name node-dev \
		npm install && npm audit fix

symfony-install: ## Installe les dépendances Symfony
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/symfony/$$name php-dev \
		composer install && \
		composer validate && \
		php bin/console cache:clear

angular-install: ## Installe les dépendances Angular
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/angular/$$name node-dev \
		npm install && npm audit fix

react-install: ## Installe les dépendances React
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/react/$$name node-dev \
		npm install --legacy-peer-deps && npm audit fix

vue-install: ## Installe les dépendances Vue.js
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/vue/$$name node-dev \
		npm install && npm audit fix

wordpress-install: ## Installe les dépendances Wordpress
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/wordpress/$$name php-dev \
		composer install

# Commandes utiles
project-lint: ## Lance le linter
	@read -p "Type (next/nuxt/symfony/angular/wordpress/react/vue): " type; \
	read -p "Nom du projet: " name; \
	if [ $$type = "next" ] || [ $$type = "nuxt" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			npm run lint; \
	elif [ $$type = "wordpress" ]; then \
		docker-compose run --force-rm -w /projects/$$type/$$name php-dev \
			composer run-script lint; \
	else \
		docker-compose run --rm -w /projects/$$type/$$name php-dev \
			php vendor/bin/phpcs; \
	fi

project-test: ## Lance les tests
	@read -p "Type (next/nuxt/symfony/angular/wordpress/react/vue): " type; \
	read -p "Nom du projet: " name; \
	if [ $$type = "next" ] || [ $$type = "nuxt" ]; then \
		docker-compose run --force-rm -w /projects/$$type/$$name node-dev \
			npm run test; \
	elif [ $$type = "wordpress" ]; then \
		docker-compose run --force-rm -w /projects/$$type/$$name php-dev \
			composer run-script test; \
	else \
		docker-compose run --force-rm -w /projects/$$type/$$name php-dev \
			php bin/phpunit; \
	fi

# Commandes d'optimisation
optimize-images: ## Optimise les images du projet
	@read -p "Type (vue/react/angular/wordpress): " type; \
	read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/$$type/$$name node-dev \
		npx imagemin-cli "public/images/**/*" --out-dir="public/images/optimized"

analyze-bundle: ## Analyse la taille du bundle
	@read -p "Type (vue/react/angular): " type; \
	read -p "Nom du projet: " name; \
	if [ $$type = "vue" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			npx vite-bundle-analyzer; \
	elif [ $$type = "react" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			npm run analyze; \
	elif [ $$type = "angular" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			ng build --stats-json && npx webpack-bundle-analyzer dist/stats.json; \
	fi

optimize-db: ## Optimise la base de données WordPress
	@read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/wordpress/$$name php-dev \
		wp db optimize && \
		wp cache flush

create-component: ## Crée un nouveau composant
	@read -p "Type (vue/react/angular): " type; \
	read -p "Nom du projet: " name; \
	read -p "Nom du composant: " component; \
	if [ $$type = "vue" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			npm run generate:component $$component; \
	elif [ $$type = "react" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			npx generate-react-cli component $$component; \
	elif [ $$type = "angular" ]; then \
		docker-compose run --rm -w /projects/$$type/$$name node-dev \
			ng generate component $$component; \
	fi

storybook-dev: ## Lance Storybook en développement
	@read -p "Type (vue/react/angular): " type; \
	read -p "Nom du projet: " name; \
	docker-compose run --rm -w /projects/$$type/$$name node-dev \
		npm run storybook

deploy-staging: ## Déploie sur l'environnement de staging
	@read -p "Type (vue/react/angular/wordpress): " type; \
	read -p "Nom du projet: " name; \
	make build type=$$type name=$$name && \
	docker-compose -f docker-compose.staging.yml up -d $$type-$$name