DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := $(HOME)/data
COMPOSE := docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE)

WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb
PORTAINER_DATA_DIR := $(DATA_DIR)/portainer

DOMAIN_NAME := $(shell grep DOMAIN_NAME $(ENV_FILE) | cut -d '=' -f2)

name = inception

all: create_dirs host_check
	@printf "Launching configuration ${name}...\n"
	@${COMPOSE} up -d

build: create_dirs host_check
	@printf "Building configuration ${name}...\n"
	@${COMPOSE} up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@${COMPOSE} down

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a -f

fclean:
	@printf "Full clean of configuration ${name}...\n"
	@${COMPOSE} down -v --rmi all --remove-orphans
	@docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_DIR)
	@printf "Cleaning completed.\n"

re: fclean all
	@printf "Rebuilding configuration ${name}...\n"
	@${COMPOSE} up -d --build --force-recreate

re_clean: fclean
	@${COMPOSE} up -d --build --no-cache

logs:
	@${COMPOSE} logs -f

host_check:
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts; \
	fi

create_dirs:
	@printf "Creating data directories...\n"
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)
	@mkdir -p $(PORTAINER_DATA_DIR)
	@chmod 777 $(WORDPRESS_DATA_DIR)
	@chmod 777 $(MARIADB_DATA_DIR)
	@chmod 777 $(PORTAINER_DATA_DIR)

# -------------- TESTS --------------
test_mariadb: create_dirs host_check
	@${COMPOSE} up -d --build mariadb
	@${COMPOSE} logs -f mariadb

test_wordpress: create_dirs host_check
	@${COMPOSE} up -d --build wordpress
	@${COMPOSE} logs -f wordpress

test_nginx: create_dirs host_check
	@${COMPOSE} up -d --build nginx
	@${COMPOSE} logs -f nginx

test_ftp: create_dirs host_check
	@${COMPOSE} up -d --build ftp
	@${COMPOSE} logs -f ftp

test_adminer: create_dirs host_check
	@${COMPOSE} up -d --build adminer
	@${COMPOSE} logs -f adminer

test_portainer: create_dirs host_check
	@${COMPOSE} up -d --build portainer
	@${COMPOSE} logs -f portainer

.PHONY: all build down re clean fclean logs create_dirs host_check re_clean

# docker compose -f srcs/docker-compose.yml logs -f mariadb (just checking logs for mariadb)