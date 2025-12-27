#!/bin/bash
set -e ## Exit on error
echo "#1 - Starting MariaDB entrypoint script"
# ON FIRST RUN, CONFIGURE MariaDB TO ALLOW REMOTE CONNECTIONS
if [ ! -e /etc/.firstrun ]; then ## if is the first time the container is run
    cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf ## append to the file mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF ## [mysqld] so that other containers can access the database server (not just localhost)
    ## bind-address so that it listens on all interfaces (not just localhost)
    ## skip-networking=0 to enable networking (since by default it's disabled in some MariaDB versions)
    touch /etc/.firstrun ## create the file .firstrun to avoid repeating this step
fi
echo "#2 - MariaDB configuration for remote connections done"
# ON FIRST MOUNT, INITIALIZE THE DATABASE AND CREATE USER ACCOUNTS
if [ ! -e /var/lib/mysql/.firstmount ]; then ## if is the first time the volume is mounted
    # Initialize a database on the volume and start MariaDB in the background
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
        --auth-root-authentication-method=socket >/dev/null 2>/dev/null
    ## mysql_install_db to initialize the database;
    ## --datadir to specify the data directory;
    ## --skip-test-db to skip creating the test database (used for testing purposes);
    ## --user and --group to set ownership of the database files to the mysql user and group;
    ## --auth-root-authentication-method=socket to use socket authentication for the root user
    ## (more secure than password authentication, but allows root to access without a password from localhost only)
    ## >/dev/null 2>/dev/null to suppress output (otherwise it prints a lot of info to the console)
    
    mysqld_safe & ## start the MariaDB server in the background
    mysqld_pid=$! ## get the PID of the background process

    # Wait for the server to be started, then set up database and accounts
    mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
    ## mysqladmin ping to check if the server is up and running;
    ## --silent to suppress output (means it will only return an exit code);
    ## --wait to keep trying until the server is available;
    ## >/dev/null 2>/dev/null to suppress output
echo "#3 - MariaDB temporary server started"
    cat << EOF | mysql --protocol=socket -u root -p=
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
CREATE USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
    ## cat << EOF | mysql ... to execute the SQL commands in the heredoc (so we don't have to do it manually);
    ## --protocol=socket to connect via Unix socket (more secure than TCP/IP);
    ## -u root to connect as root user;
    ## -p= to indicate no password (since we're using socket authentication for root)
    ## CREATE DATABASE to create the database specified by the environment variable MYSQL_DATABASE;
    ## CREATE USER to create a new user with the username and password specified by MYSQL_USER and MYSQL_PASSWORD,
    ## and allow connections from any host ('%');
    ## GRANT ALL PRIVILEGES to give the new user full access to the specified database;
    ## GRANT ALL PRIVILEGES on *.* to 'root'@'%' ... to allow root to connect from any host with the specified password;
    ## FLUSH PRIVILEGES to apply the changes immediately
echo "#4 - MariaDB database and user accounts created"
    # Shut down the temporary server and mark the volume as initialized
    mysqladmin shutdown ## shut down the temporary server (so we can start it normally later)
    touch /var/lib/mysql/.firstmount ## create the file .firstmount to avoid repeating this step
    wait $mysqld_pid ## wait for the background process to finish needed to avoid zombie processes
fi
echo "#5 - MariaDB initialization on first mount done"
exec mysqld_safe ## start MariaDB normally (replacing the current process)
echo "#6 - MariaDB server started"
