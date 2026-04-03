FROM	alpine:3.22

EXPOSE	9000

RUN		apk update && apk upgrade && apk add --no-cache \
			wget \
			php84 \
			php84-fpm \
			php84-mysqli \
			php84-phar \
			php84-iconv \
			mariadb-client

# Link php84 to php
RUN		ln -s /usr/bin/php84 /usr/bin/php

# Add group and user 'www-data'
RUN		addgroup -g 82 -S www-data || true
RUN		adduser -u 82 -D -S -G www-data www-data || true

# Create folder to contain web files and set permissions
RUN		mkdir -p /var/www
RUN		chown -R www-data:www-data /var/www
RUN		chmod -R 755 /var/www

# Copy custom PHP-FPM pool configuration
COPY	www.conf /etc/php84/php-fpm.d/www.conf

# Change memory limit
RUN		sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php84/php.ini

# Download CLI and set permissions
RUN		wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN		chmod 755 wp-cli.phar
RUN		mv wp-cli.phar /usr/local/bin/wp

# Copy and execute the auto-configuration script and set permissions
COPY	auto_config.sh /auto_config.sh
RUN		chmod 755 /auto_config.sh

ENTRYPOINT [ "sh", "/auto_config.sh" ]