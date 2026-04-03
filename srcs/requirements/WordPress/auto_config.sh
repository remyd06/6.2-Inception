#!/bin/sh

sleep 5

echo "[ INFO ] Starting WordPress..."

if [ ! -f "/var/www/html/wp-config.php" ]; then
	wp core download \
        --path="/var/www/html"

	cd /var/www/html

	wp config create \
		--allow-root \
		--dbname="${SQL_DATABASE}" \
		--dbuser="${SQL_USER}" \
		--dbpass="${SQL_PASSWORD}" \
		--dbhost=mariadb:3306 \
		--path='/var/www/html'

	wp core install \
		--url="${WORDPRESS_URL}" \
        --title="inception" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASS}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}"

	wp user create \
		"${WORDPRESS_USER}" \
		"${WORDPRESS_USER_EMAIL}" \
		--user_pass="${WORDPRESS_USER_PASS}" \
		--role=author
fi

chmod -R 755 /var/www/html

echo "[ INFO ] Running "
exec php-fpm84 -F -R