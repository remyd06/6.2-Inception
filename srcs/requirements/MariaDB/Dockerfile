FROM	alpine:3.23

EXPOSE	3306

# Install MariaDB
RUN		apk update && apk upgrade && apk add --no-cache \
			mariadb \
			mariadb-client

# Create necessary directories for MariaDB and set permissions
RUN		mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy custom MariaDB configuration file
COPY	my.cnf /etc/my.cnf

# Copy and execute the auto-configuration script and set permissions
COPY	entrypoint.sh /entrypoint.sh
RUN     chmod +x /entrypoint.sh

ENTRYPOINT [ "sh", "/entrypoint.sh" ]
