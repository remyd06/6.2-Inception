#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[ INFO ] Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "[ INFO ] Setting up MariaDB..."
    mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

exec mariadbd-safe --user=mysql
