# DEV_DOC.md — Developer Documentation

## Prerequisites

- Docker Engine (>= 20.10)
- Docker Compose plugin (`docker compose`)
- GNU Make
- sudo access (required for creating host directories and setting permissions)

---

## Project structure

```
inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env                            ← credentials (never commit)
    └── requirements/
        ├── NGINX/
        │   ├── Dockerfile              ← alpine:3.23, nginx + openssl, self-signed cert
        │   └── nginx.conf              ← TLS 1.2/1.3, fastcgi_pass to wordpress:9000
        ├── WordPress/
        │   ├── Dockerfile              ← alpine:3.22, php84-fpm + wp-cli
        │   ├── auto_config.sh          ← downloads WP core, creates config, installs, creates user
        │   └── www.conf                ← PHP-FPM pool listening on 0.0.0.0:9000
        └── MariaDB/
            ├── Dockerfile              ← alpine:3.23, mariadb + mariadb-client
            ├── entrypoint.sh           ← initializes DB on first run, creates user and database
            └── my.cnf                  ← datadir, socket, bind 0.0.0.0:3306
```

---

## Environment setup from scratch

### 1. Clone the repository

```bash
git clone https://github.com/rdedola/inception.git
cd inception
```

### 2. Create `srcs/.env`

```env
# MariaDB
SQL_DATABASE=wordpress
SQL_USER=rdedola
SQL_PASSWORD=yourpassword
SQL_ROOT_PASSWORD=yourrootpassword

# WordPress
WORDPRESS_URL=rdedola.42.fr
WORDPRESS_ADMIN_USER=god          # must NOT be "admin"
WORDPRESS_ADMIN_PASS=yourpassword
WORDPRESS_ADMIN_EMAIL=rdedola@student.42.fr
WORDPRESS_USER=rdedola
WORDPRESS_USER_PASS=yourpassword
WORDPRESS_USER_EMAIL=rdedola@student.42.fr
```

> ⚠️ `.env` must never be committed. It is listed in `.gitignore`.

### 3. Add domain to `/etc/hosts`

```bash
echo "127.0.0.1   rdedola.42.fr" | sudo tee -a /etc/hosts
```

---

## Build and launch

```bash
make up
```

This command does the following in order:
1. Creates `/home/<user>/data/db_data` and `/home/<user>/data/wp_data` on the host
2. Sets permissions to 777 on those directories
3. Runs `docker-compose up -d --build` — builds the three images and starts the containers

Equivalent manual command:
```bash
USERNAME=$(whoami) docker-compose -f srcs/docker-compose.yml -p inception up -d --build
```

---

## Managing containers

```bash
# Status of all containers
docker compose -p inception ps

# Logs (follow mode)
docker compose -p inception logs -f nginx
docker compose -p inception logs -f wordpress
docker compose -p inception logs -f mariadb

# Stop containers (keeps volumes and images)
make down

# Individual service debug builds
make mariadb_build && make mariadb_run
make wordpress_build && make wordpress_run
make nginx_build && make nginx_run

# Stop a debug container
make mariadb_stop
make wordpress_stop
make nginx_stop
```

---

## Useful debug commands

```bash
# Check TLS version used by NGINX
curl -vI https://rdedola.42.fr --insecure 2>&1 | grep "SSL connection"

# Enter MariaDB as root
docker exec -it mariadb mariadb -u root -p

# Check WordPress database content
docker exec -it mariadb mariadb -u root -p123 -e "USE wordpress; SHOW TABLES;"

# List volumes
docker volume ls

# Inspect volume mount path
docker volume inspect inception_db_data
docker volume inspect inception_wp_data
```

---

## Data persistence

| Data | Storage location on host | Docker volume |
|---|---|---|
| MariaDB database files | `/home/<user>/data/db_data` | `inception_db_data` |
| WordPress files | `/home/<user>/data/wp_data` | `inception_wp_data` |

Both volumes use `driver: local` with `type: none` (bind mount). The host directories are created by `make up` and survive `make down`. They are only deleted by `make fclean` / `make clear`.

NGINX mounts the WordPress volume in **read-only** mode (`wp_data:/var/www/html:ro`) — it serves static files but cannot write to the WordPress directory.

---

## Container initialization logic

### MariaDB (`entrypoint.sh`)
- On first run (no `/var/lib/mysql/mysql` directory), calls `mariadb-install-db` then bootstraps the database via `mysqld --bootstrap`
- Creates the database, the application user with `GRANT ALL`, and sets the root password
- On subsequent runs, skips initialization and goes directly to `exec mariadbd-safe`

### WordPress (`auto_config.sh`)
- Waits 5 seconds for MariaDB to be ready
- On first run (no `wp-config.php`), downloads WordPress core, creates `wp-config.php`, runs `wp core install`, creates the secondary user
- On subsequent runs, skips setup and launches `php-fpm84 -F -R`

### NGINX (`Dockerfile`)
- Generates a self-signed TLS certificate at build time with `openssl req -x509`
- Certificate is stored at `/etc/nginx/ssl/inception.crt` and `/etc/nginx/ssl/inception.key`
- Only listens on port 443, TLS 1.2 and 1.3 enforced via `ssl_protocols TLSv1.2 TLSv1.3`
- Forwards PHP requests to `wordpress:9000` via FastCGI