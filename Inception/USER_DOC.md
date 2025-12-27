# User Documentation

## Overview

This project provides a small web infrastructure composed of multiple services running in Docker containers.
The stack is designed to deliver a secure WordPress website accessible through HTTPS.

### Provided Services

- NGINX
  Acts as the public entry point of the infrastructure and handles HTTPS connections (TLSv1.2 / TLSv1.3).

- WordPress (PHP-FPM)
  Hosts the WordPress application and processes PHP requests.

- MariaDB
  Stores the WordPress database and user data.

All services are isolated in separate containers and communicate through a private Docker network.

---

## Starting and Stopping the Project

### Start the infrastructure

From the root of the repository, run:

make

This command:
- Builds the Docker images
- Creates volumes and networks
- Starts all services

### Stop the infrastructure

make down

### Stop and remove all data (containers, images, volumes)

make fclean

WARNING: This will permanently delete the WordPress database and files.

---

## Accessing the Website

### Website access

Open a web browser and go to:

https://<login>.42.fr

The website is served securely through HTTPS.

### WordPress administration panel

To access the WordPress admin interface:

https://<login>.42.fr/wp-admin

Use the administrator credentials defined during installation.

---

## Credentials Management

### Environment variables

Non-sensitive configuration values are stored in:

srcs/.env

This file is not committed to version control.

### Secrets

Sensitive credentials such as database passwords are stored using Docker secrets:

secrets/
- db_password.txt
- db_root_password.txt
- credentials.txt

These files are mounted securely into the containers at runtime.

Credentials must never be hardcoded in Dockerfiles or committed to Git.

---

## Checking Service Status

### List running containers

docker ps

All services should appear as running containers.

### Check container logs

docker logs <container_name>

Example:
docker logs nginx

### Verify volumes

docker volume ls

Volumes ensure data persistence even if containers restart.

---

## Troubleshooting

- Ensure Docker and Docker Compose are running
- Verify that the domain <login>.42.fr points to the local IP address
- Check container logs for errors
- Make sure port 443 is not used by another service

---

## Conclusion

This infrastructure is designed to be simple to use while following Docker best practices.
All services are secure, isolated, and persistent across restarts.
