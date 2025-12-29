# Used to make sure remains consistent and it's lightweight helps with security and performance.
FROM alpine:3.22

# Creates a user 'mysql' with UID 999 and adds it to the 'ping' group
# This is done to avoid running the MariaDB server as the root (User 0) for security reasons.
# It will handle volume permission consistency issues.
RUN adduser -D -u 999 -G ping mysql

# Updates the package list and installs MariaDB server, MariaDB client, and bash shell.
RUN apk update && \
    apk add mariadb mariadb-client bash

# Creates the necessary directories for MariaDB data and configuration files inside the container.
COPY tools/mariadb-entrypoint.sh /usr/local/bin/

# Sets the appropriate permissions to make the entrypoint script executable.
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/mariadb-entrypoint.sh" ]

# "Documentation" that specifies the port on which the container listens for connections.
# Not used in this project, because mariadb communicates via docker-network internal network.
EXPOSE 3306