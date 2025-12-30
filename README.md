*This project has been created as part of the 42 curriculum by <demrodri@student.42wolfsburg.de>.*

# Inception

## Description

Inception is a system administration project whose goal is to design and deploy a small web infrastructure using Docker and Docker Compose.  
The project focuses on containerization, service isolation, networking, data persistence, and security best practices.

The infrastructure is composed of multiple services running in separate Docker containers, all orchestrated through Docker Compose and executed inside a virtual machine.

The final setup provides a secure WordPress website served through NGINX over HTTPS, with persistent data storage and proper secret management.

---

## Project Overview

The project includes the following services:

- **NGINX**: Acts as the single entry point to the infrastructure and handles HTTPS connections using TLSv1.2 or TLSv1.3.
- **WordPress (PHP-FPM)**: Runs the WordPress application without a web server.
- **MariaDB**: Provides the relational database used by WordPress.

All services:
- Run in dedicated containers
- Are built from custom Dockerfiles
- Use Alpine base images
- Communicate through a Docker network
- Restart automatically in case of failure

---

## Infrastructure Architecture

- One Docker network for inter-container communication
- Two Docker volumes:
  - One for WordPress database persistence
  - One for WordPress website files
- One exposed port: **443 (HTTPS only)**

NGINX is the **only public entry point** to the infrastructure.

---

## Instructions

### Prerequisites

- Linux virtual machine
- Docker
- Docker Compose
- `make`
- Domain name configured to point to the local machine:
`demrodri.42.fr`


### Installation and Launch

Clone the repository and run: `make`

### This command:

- Builds all Docker images
- Creates the required volumes and network
- Starts all containers

### To stop the infrastructure: `make down`

### To remove containers, images, and volumes: `make fclean`
---
## Environment Variables and Secrets

- Environment variables are stored in a .env file and are not committed to the repository. 

- Sensitive data such as database passwords are stored using Docker secrets.

- No credentials are hardcoded in Dockerfiles.

This approach ensures better security and follows Docker best practices.



# Design Choices and Comparisons
## Virtual Machines vs Docker

Virtual Machines virtualize entire operating systems, leading to higher resource usage.

Docker containers share the host kernel and isolate applications, making them lightweight, faster to start, and easier to deploy.

    *Docker was chosen for its efficiency, portability, and ease of orchestration.*

## Secrets vs Environment Variables

Environment Variables are useful for configuration but are visible to processes and can be exposed unintentionally.

Docker Secrets are designed to securely store sensitive data such as passwords and credentials.

Secrets are used in this project to protect confidential information.

## Docker Network vs Host Network

Host network removes network isolation and poses security risks.

Docker networks allow controlled communication between containers while maintaining isolation.

A custom Docker network ensures safe and predictable service communication.

## Docker Volumes vs Bind Mounts

Bind mounts depend on host paths and are less portable.

Docker volumes are managed by Docker and better suited for persistent application data.

Volumes are used to store the database and WordPress files reliably.

---
# Resources

Docker Documentation: https://docs.docker.com/

Docker Compose Documentation: https://docs.docker.com/compose/

NGINX Documentation: https://nginx.org/en/docs/

WordPress Documentation: https://wordpress.org/documentation/

MariaDB Documentation: https://mariadb.com/kb/en/documentation/

# Notes

This project was developed following the constraints of the 42 Inception subject.
All services are isolated, secured, and designed to follow production-oriented best practices.


---
---