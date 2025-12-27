# Developer Documentation

## Introduction

This document is intended for developers who want to understand, build, and maintain the Inception infrastructure.
It describes the project setup, build process, container management, and data persistence.

---

## Prerequisites

To work on this project, you need:

- Linux-based operating system (virtual machine)
- Docker
- Docker Compose
- GNU Make
- Internet connection (for base images only)

---

## Project Structure

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        ├── wordpress/
        └── mariadb/

Each service has:
- Its own directory
- Its own Dockerfile
- Configuration files where needed

---

## Environment Setup

### Environment variables

Create and configure the environment file:

srcs/.env

This file contains non-sensitive variables such as:
- Domain name
- Database user
- Database name

### Secrets

Sensitive data must be stored in the secrets directory:

- Database passwords
- WordPress credentials

Secrets are mounted into containers using Docker secrets.

---

## Building and Launching the Project

### Build and start the infrastructure

make

This command:
- Builds all Docker images
- Starts containers using Docker Compose
- Creates volumes and networks if needed

### Stop containers

make down

### Full cleanup

make fclean

---

## Managing Containers

### List containers

docker ps

### Enter a running container

docker exec -it <container_name> sh

### Restart a service

docker restart <container_name>

---

## Managing Volumes and Data Persistence

### Volumes location

Persistent data is stored on the host at:

/home/<login>/data

### Volumes used

- WordPress database volume
- WordPress website files volume

These volumes ensure that:
- Database data is not lost on container restart
- Uploaded files and WordPress configuration persist

### List volumes

docker volume ls

---

## Docker Networking

The infrastructure uses a custom Docker network defined in docker-compose.yml.

Benefits:
- Isolated inter-service communication
- No exposure of internal services to the host
- Improved security and control

---

## Development Notes

- Each container runs a single service
- No infinite loops or fake foreground processes are used
- Services run as proper daemons
- Containers restart automatically on failure

---

## Maintenance Tips

- Regularly check logs for warnings or errors
- Avoid modifying containers manually; update Dockerfiles instead
- Rebuild images after configuration changes

---

## Conclusion

This project follows Docker best practices for containerization, security, and maintainability.
The architecture is modular, extensible, and suitable for small production-like environments.
