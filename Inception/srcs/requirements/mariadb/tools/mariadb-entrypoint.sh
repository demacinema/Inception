#!/bin/bash
set -e

# Ensure the /run/mysqld directory exists with proper ownership
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld /var/lib/mysql

# Config
cat <<EOF > /etc/my.cnf.d/mariadb-server.cnf
[client-server]
socket = /run/mysqld/mariadb.sock

[mysqld]
user = mysql
datadir = /var/lib/mysql
#socket = /var/lib/mysql/mysql.sock
bind-address = 0.0.0.0
skip-networking = 0
EOF

# Path to the .firstrun file
FIRST_RUN_FLAG="/var/lib/mysql/.firstrun"

# Set the root password explicitly if not already set
ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"

# Check if this is the first run by looking for the .firstrun file
if [ ! -e "$FIRST_RUN_FLAG" ]; then
    echo "First run detected, initializing the database..."

    # Makes sure that Makefile's created folder (demrodri) passes its ownership to mysql user
    chown -R mysql:mysql /var/lib/mysql

    # Initialize the database if it's the first run
    mysql_install_db --datadir=/var/lib/mysql --user=mysql --skip-test-db --auth-root-authentication-method=socket

    # Start the MariaDB server in the background and capture its PID
    mysqld_safe &
    mysqld_pid=$!

    # Wait for MariaDB to be ready for connections
    echo "Waiting for MariaDB to be ready..."
    until mysql --socket=/run/mysqld/mariadb.sock -u root -e "SELECT 1;" > /dev/null 2>&1; do
        echo "MariaDB is not yet ready, retrying..."
        sleep 1
    done
    echo "MariaDB is ready."

    # Create the database if not exists
    echo "Creating database ${MYSQL_DATABASE} if not exists..."
    mysql --socket=/run/mysqld/mariadb.sock -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

    # Create the user if not exists and grant privileges
    echo "Creating user ${MYSQL_USER} if not exists..."
    mysql --socket=/run/mysqld/mariadb.sock -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql --socket=/run/mysqld/mariadb.sock -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

    # **NEW**: Set root password explicitly (this was missing before)
    echo "Setting password for root user..."
    mysql --socket=/run/mysqld/mariadb.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"

    # Mark the database initialization as done by creating the .firstrun file
    touch "$FIRST_RUN_FLAG"

    # Shutdown MariaDB server after setup is done
    mysqladmin --socket=/run/mysqld/mariadb.sock -u root -p"${ROOT_PASSWORD}" shutdown
    wait $mysqld_pid

else
    echo "Database already initialized, skipping setup."
fi

# Start MariaDB as the main process (PID 1) for the container.
echo "Starting MariaDB server..."
exec mysqld_safe
# exec replaces the current shell with the mysqld_safe process, ensuring it runs as PID 1.