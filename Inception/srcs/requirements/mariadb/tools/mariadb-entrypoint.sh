#!/bin/bash
set -e

# Path to the .firstrun file
FIRST_RUN_FLAG="/var/lib/mysql/.firstrun"

# **NEW**: Set the root password explicitly if not already set
ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"

# Check if this is the first run by looking for the .firstrun file
if [ ! -e "$FIRST_RUN_FLAG" ]; then
    echo "First run detected, initializing the database..."

    # **NEW**: Modify MariaDB config to allow connections from other containers
    echo "[mysqld]" >> /etc/my.cnf.d/mariadb-server.cnf
    echo "bind-address = 0.0.0.0" >> /etc/my.cnf.d/mariadb-server.cnf
    echo "skip-networking = 0" >> /etc/my.cnf.d/mariadb-server.cnf

    # Fix permissions on the MySQL data directory (important)
    chown -R mysql:mysql /var/lib/mysql

    # Initialize the database if it's the first run
    mysql_install_db --datadir=/var/lib/mysql --user=mysql --skip-test-db --auth-root-authentication-method=socket

    # Start the MariaDB server in the background to allow for database creation
    mysqld_safe &
    mysqld_pid=$!

    # Wait for MariaDB to be ready for connections
    echo "Waiting for MariaDB to be ready..."
    until mysql --protocol=socket -u root -e "SELECT 1;" > /dev/null 2>&1; do
        echo "MariaDB is not yet ready, retrying..."
        sleep 1
    done
    echo "MariaDB is ready."

    # Create the database if not exists
    echo "Creating database ${MYSQL_DATABASE} if not exists..."
    mysql --protocol=socket -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

    # Create the user if not exists and grant privileges
    echo "Creating user ${MYSQL_USER} if not exists..."
    mysql --protocol=socket -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql --protocol=socket -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

    # **NEW**: Set root password explicitly (this was missing before)
    echo "Setting password for root user..."
    mysql --protocol=socket -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"

    # Mark the database initialization as done by creating the .firstrun file
    touch "$FIRST_RUN_FLAG"

    # Shutdown MariaDB server after setup is done
    mysqladmin --protocol=socket -u root shutdown
    wait $mysqld_pid
else
    echo "Database already initialized, skipping setup."
fi

# Start MariaDB normally (this is the default action on subsequent runs)
echo "Starting MariaDB server..."
exec mysqld_safe
