FROM	alpine:3.23

EXPOSE	443

RUN		apk update && apk upgrade && apk add --no-cache \
			nginx \
			openssl

# Create folder to contain ssl keys and set permissions
RUN		mkdir -p /etc/nginx/ssl

RUN		openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
			-keyout /etc/nginx/ssl/inception.key \
			-subj "/C=FR/ST=PACA/L=Nice/O=42/OU=42Nice/CN=rdedola.42.fr/UID=rdedola"

RUN		mkdir -p /var/run/nginx

COPY	nginx.conf /etc/nginx/nginx.conf

RUN		getent group www-data || addgroup -g 82 -S www-data
RUN		getent passwd www-data || adduser -u 82 -D -S -G www-data www-data

RUN		mkdir -p /var/www/html
RUN		chown -R www-data:www-data /var/www/html

CMD ["nginx", "-g", "daemon off;"]
