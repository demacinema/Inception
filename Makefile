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

build_no_cache: create_dirs host_check
	@printf "Building configuration ${name} without cache...\n"
	@${COMPOSE} up -d --build --no-cache

down:
	@printf "Stopping configuration ${name}...\n"
	@${COMPOSE} down

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@sudo docker system prune -a -f

fclean:
	@printf "Full clean of configuration ${name}...\n"
	@${COMPOSE} down -v --rmi all --remove-orphans
	@sudo docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_DIR)
	@printf "Cleaning completed.\n"

re: fclean all
	@printf "Rebuilding configuration ${name}...\n"
	@${COMPOSE} up -d --build --force-recreate
	# this --force-recreate could cause racing conditions in some cases
	# probably better fclean build?

re_clean: fclean
	@${COMPOSE} up -d --build --no-cache

logs:
	@${COMPOSE} logs -f

host_check:
	@if ! sudo grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts; \
	fi

create_dirs:
	@printf "Creating data directories...\n"
	@sudo mkdir -p $(WORDPRESS_DATA_DIR)
	@sudo chmod 777 -R $(WORDPRESS_DATA_DIR)
	@sudo mkdir -p $(MARIADB_DATA_DIR)
	@sudo chmod 777 -R $(MARIADB_DATA_DIR)
	@sudo mkdir -p $(PORTAINER_DATA_DIR)
	@sudo chmod 777 -R $(PORTAINER_DATA_DIR)

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

.PHONY: all build build_no_cache down re re_clean fclean logs create_dirs host_check \
	 test_mariadb test_wordpress test_nginx test_ftp test_adminer test_portainer

# Creates container while also checking logs for mariadb):
# docker compose -f srcs/docker-compose.yml logs -f mariadb 