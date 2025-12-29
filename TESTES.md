 Inception Project – Functional and Security Tests

 This document guides you step by step to test your Inception project setup. 
 It includes commands and procedures for mandatory and bonus services, security checks, and cleanup.

 ---
❌✅

# 1. Preparation
Ensure you are running this on a VM and Docker/Docker Compose are installed:

- docker --version
- docker compose version
---
# 2. Build and Launch
Clean up any previous containers/volumes:

- docker stop $(docker ps -qa)
- docker rm $(docker ps -qa)
- docker rmi -f $(docker images -qa)
- docker volume rm $(docker volume ls -q)
- docker network rm $(docker network ls -q) 2>/dev/null

- make fclean
---
# 3. Build and start services:

- make build

# 4. Check running containers:

- docker ps

Expected containers:
 - nginx
 - wordpress
 - mariadb
 - redis (bonus)
 - ftp (bonus)
 - adminer (bonus)
 - static-site (bonus)
 - portainer (bonus)
---

# 5. Functional Tests
## NGINX
### 1. Open your browser:
            https://demrodri.42.fr
### 2. Check HTTPS/TLS:
- openssl s_client -connect demrodri.42.fr:443 -tls1_2
- openssl s_client -connect demrodri.42.fr:443 -tls1_3
### 3. Check open ports:
- docker container ls
- sudo netstat -tulnp | grep 443
---
## WordPress
### 1. Access the site:
            https://demrodri.42.fr
### 2. Log in with admin credentials:
            - Username: WORDPRESS_ADMIN_USER
            - Password: WORDPRESS_ADMIN_PASSWORD
### 3. Log in with regular user credentials:
            - Username: WORDPRESS_USER
            - Password: WORDPRESS_PASSWORD
### 4. Create a post/page to confirm functionality.
---
## MariaDB
### 1. Confirm WordPress connects (site loads without errors).  
### 2. Optionally, connect via CLI:
docker exec -it mariadb mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"
### 3. Check users and tables:
SELECT User, Host FROM mysql.user;
SHOW TABLES;
---
 ## Volumes
 ### 1. Stop and restart containers:
 - make down
 - make build
 ### 2. Confirm data persists:
 - ls /home/demrodri/data/wordpress
 - docker exec -it mariadb ls /var/lib/mysql
 ---
## Network
- docker network ls
- docker network inspect <your_network_name>

All containers should be on the same custom network.
---
# Bonus Services
# Redis
1. Log in to WordPress and install Redis plugin if needed.  
2. Verify caching:
- docker exec -it redis redis-cli
- KEYS *
---
# FTP
- ftp <VM_IP>
### Login with FTP credentials and verify WordPress files access
---
# Adminer
1. Open in browser:
http://localhost:8080
2. Log in using MariaDB credentials.
3. Browse and manage the database.
---
## Static Site
http://localhost:80
---
## Portainer
1. Open in browser:
http://localhost:9000
or
https://localhost:9443
2. Log in and manage Docker containers.
---
# Security and Compliance Checks
 1. Ensure no passwords are hardcoded in Dockerfiles:

 grep -R "PASSWORD" ./srcs/requirements/*/Dockerfile

 2. Ensure environment variables and secrets are used correctly:  
 Check `.env` and `secrets/` folder.  

 3. Check for forbidden infinite loops:

 grep -R "tail -f" ./srcs/requirements/*/*.sh
 grep -R "while true" ./srcs/requirements/*/*.sh

 4. Verify domain resolves:

 ping demrodri.42.fr

 ---

# Logs and Debugging

 make logs

 Or check container logs manually:

 docker logs wordpress
 docker logs nginx
 docker logs mariadb

 Check container health:

 docker ps --format "table {{.Names}}\t{{.Status}}"

 All containers should show `Up`.

 ---

# Clean Up

 Stop all containers:

 make down

 Remove all data:

 make fclean
