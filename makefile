# Inclure les variables d'environnement
include .env
export $(shell sed 's/=.*//' .env)

# Définition de la date
DATE := $(shell /bin/date "+%Y-%m-%d-%H-%M-%S")

# Définition des couleurs
_END        = \033[0m
_BOLD       = \033[1m
_RED        = \033[31m
_GREEN      = \033[32m
_YELLOW     = \033[33m
_BLUE       = \033[34m
_PURPLE     = \033[35m
_CYAN       = \033[36m
_WHITE      = \033[37m

define print_title
	@printf "$(_GREEN)$(_BOLD)$(1) :$(_END)\n";
endef

define print_command
	@printf "$(_CYAN)$(_BOLD)make %-10s$(_END) - %s\n" "$(1)" "$(2)"
endef

# Commande d'aide par défaut
.PHONY: help
help:
	@echo "\n"
	$(call print_title,STACK DEVELOPMENT COMMANDS)
	@echo "\n"
	$(call print_title, BASIC COMMANDS)
	$(call print_command, up, Start all containers)
	$(call print_command, down, Stop all containers)
	$(call print_command, restart, Restart all containers)
	$(call print_command, ps, Show running containers)
	$(call print_title, SETUP COMMANDS)
	$(call print_command, init, Initial setup (certificates, networks))
	$(call print_command, ssl, Generate SSL certificates)
	$(call print_command, networks, Create Docker networks)
	$(call print_title, DATABASE COMMANDS)
	$(call print_command, backup, Backup all database)
	$(call print_command, restore, Restore databases from backup)
	$(call print_title, MAINTENANCE COMMANDS)
	$(call print_command, clean, Clean unused Docker Ressources)
	$(call print_command, logs, Show Container logs)
	$(call print_command, update, Update all containers)

# Commandes de base
up:
	@echo "${_YELLOW}Starting stack-dev containers...${_END}"
	@docker-compose up -d
	@echo "${_GREEN}Starting stack-dev containers [OK]${_END}"

down:
	@echo "${_YELLOW}Stopping stack-dev containers...${_END}"
	@docker-compose down
	@echo "${_GREEN}Stopping stack-dev containers [OK]${_END}"

restart:
	@echo "${_YELLOW}Restarting stack-dev containers...${_END}"
	@make down
	@make up
	@echo "${_GREEN}Stack restarted [OK]${_END}"

ps:
	@echo "${_YELLOW}Listing stack-dev containers...${_END}"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo "${_GREEN}Listing stack-dev containers [OK]${_END}"

# Commandes de setup
create-dirs:
	@echo "${_YELLOW}Creating directories...${_END}"
	@mkdir -p ./certs ./data./dumps ./phpmyadmin
	@chown -R $(shell id -u):$(shell id -g) ./certs ./data ./dumps ./phpmyadmin
	@chmod -R 755 ./certs ./data ./dumps ./phpmyadmin
	@echo "${_GREEN}Directories created [OK]${_END}"

init: create-dirs networks ssl up
	@echo "${_GREEN}Stack initialisation completed [OK]${_END}"

networks:
	@echo "${_YELLOW}Creating Docker networks...${_END}"
	@docker network create frontend 2>/dev/null || true
	@docker network create backend 2>/dev/null || true
	@docker network create db 2>/dev/null || true
	@echo "${_GREEN}Docker networks created [OK]${_END}"

ssl:
	@echo "${_YELLOW}Generating SSL certificates...${_END}"
	@chmod +x ./scripts/ssl.sh
	@./scripts/ssl.sh
	@echo "${_GREEN}SSL certificates generated [OK]${_END}"

# Commandes de base de données
backup:
	@echo "${_YELLOW}Backing up databases...${_END}"
	@mkdir -p ./dumps/$(DATE)
	@docker-compose exec -T mariadb mysqldump --user=root --password="${DATABASE_PASSWORD} ${DATABASE_NAME}" > ./dumps/$(DATE)/mariadb_backup.sql
	@docker-compose exec -T postgres pg_dump -U postgres "${POSTGRES_DATABASE_NAME}" > ./dumps/$(DATE)/postgres_backup.sql
	@echo "${_GREEN}Databases backed up [OK]${_END}"

restore:
	@if [ -z "$(BACKUP_DATE)" ]; then \
		echo "${_RED}Error: BACKUP_DATE is required. Usage: make restore BACKUP_DATE=YYY-MM-DD-HH-MM-SS${_END}"; \
		exit 1; 
	fi
	@echo "${_YELLOW}Restoring databases from ./dumps/$(BACKUP_DATE)...${_END}"
	@docker-compose exec -T mariadb mysql --user=root --password=${DATABASE_PASSWORD} ${DATABASE_NAME} < ./dumps/$(BACKUP_DATE)/mariadb_backup.sql
	@docker-compose exec -T postgres psql -U postgres ${POSTGRES_DATABASE_NAME} < ./dumps/$(BACKUP_DATE)/postgres_backup.sql
	@echo "${_GREEN}Databases restored [OK]${_END}"

# COmmandes de maintenance
clean:
	@echo "${_YELLOW}Cleaning unused Docker Ressources...${_END}"
	@docker system prune --volumes -f
	@echo "${_GREEN}Cleaning unused Docker Ressources [OK]${_END}"

logs:
	@echo "${_YELLOW}Showing logs...${_END}"
	@docker-compose logs -f
	@echo "${_GREEN}Showing logs [OK]${_END}"

update:
	@echo "${_YELLOW}Updating containers...${_END}"
	@docker-compose pull
	@make restart
	@echo "${_GREEN}Updating containers [OK]${_END}"

# Commandes de sécurité
security-check:
	@echo "${_YELLOW}${_BOLD}Starting security check...${_END}"
	@docker-compose config
	@echo "${_YELLOW}${_BOLD}Checking container vulnerabilities...${_END}"
	@docker-compose pull
	@docker-compose build --pull
	@docker scan traefik
	@docker scan mariadb
	@docker scan postgres
	@echo "${_GREEN}${_BOLD}Security check [OK]${_END}"

setup-firewall:
	@echo "${_YELLOW}${_BOLD}Setting up UFW firewall...${_END}"
	@sudo ufw default deny incoming
	@sudo ufw default allow outgoing
	@sudo ufw allow ssh
	@sudo allow 51820/udp
	@sudo ufw allow http
	@sudo ufw allow https
	@sudo ufw enable
	@echo "${_GREEN}${_BOLD}UFW firewall setup [OK]${_END}"

setup-wireguard:
	@echo "${_YELLOW}${_BOLD}Setting up WireGuard...${_END}"
	@chmod +x ./scripts/setup-wireguard.sh
	@./scripts/setup-wireguard.sh
	@echo "${_GREEN}${_BOLD}WireGuard setup [OK]${_END}"

setup-security: setup-firewall setup-wireguard
	@echo "${_GREEN}${_BOLD}Security setup completed [OK]${_END}"

# Commandes de développement
generate-passwords:
	@echo "${_YELLOW}${_BOLD}Generating secure passwords...${_END}"
	@chmod +x ./scripts/generate_passwords.sh
	@./scripts/generate_passwords.sh
	@echo "${_GREEN}${_BOLD}Passwords generated [OK]${_END}"

# Commandes de tunnel
setup-cloudflare:
	@echo "${_YELLOW}${_BOLD}Setting up Cloudflare tunnel...${_END}"
	@chmod +x ./scripts/setup-cloudflare.sh
	@./scripts/setup-cloudflare.sh
	@echo "${_GREEN}${_BOLD}Cloudflare tunnel setup [OK]${_END}"

start-tunnel:
	@echo "${_YELLOW}${_BOLD}Starting Cloudflare tunnel...${_END}"
	@sudo systemctl start cloudflared
	@echo "${_GREEN}${_BOLD}Cloudflare tunnel started [OK]${_END}"

stop-tunnel:
	@echo "${_YELLOW}${_BOLD}Stopping Cloudflare tunnel...${_END}"
	@sudo systemctl stop cloudflared
	@echo "${_GREEN}${_BOLD}Cloudflare tunnel stopped [OK]${_END}"

tunnel-status:
	@echo "${_YELLOW}${_BOLD}Checking Cloudflare tunnel status...${_END}"
	@sudo systemctl status cloudflared

# Documentation
.PHONY: docs-build docs-serve docs-stop

docs-build:
	@echo "${_YELLOW}${_BOLD}🏗️ Building documentation...${_END}"
	@docker-compose build docs

docs-serve:
	@echo "${_YELLOW}${_BOLD}📚 Starting documentation server...${_END}"
	@docker-compose up -d docs

docs-stop:
	@echo "${_YELLOW}${_BOLD}🛑 Stopping documentation server...${_END}"
	@docker-compose stop docs

docs-init:
	@echo "${_YELLOW}${_BOLD}📝 Initializing documentation structure...${_END}"
	mkdir -p ./docs/docs
	chown -R $(shell id -u):$(shell id -g) ./docs
	chmod -R 755 ./docs
	@echo "${_GREEN}${_BOLD}Documentation initialized [OK]${_END}"

update-hosts:
	@echo "${_YELLOW}${_BOLD}Updating /etc/hosts...${_END}"
	@if ! grep -q "docs.localhost" /etc/hosts; then \
		echo "127.0.0.1 docs.localhost" | sudo tee -a /etc/hosts; \
	fi
	@echo "${_GREEN}${_BOLD}/etc/hosts updated [OK]${_END}"