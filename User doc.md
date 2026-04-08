# USER_DOC.md — User & Administrator Documentation

## What is this stack?

This project deploys a self-hosted WordPress website using three containerized services:

| Service | Role | Port |
|---|---|---|
| **NGINX** | Reverse proxy, HTTPS entry point | 443 (only) |
| **WordPress** | PHP-FPM application server | 9000 (internal) |
| **MariaDB** | SQL database | 3306 (internal) |

All traffic goes through NGINX over TLS 1.2/1.3. Port 80 is not exposed — HTTP access is not possible.

---

## Starting and stopping the project

From the root of the repository:

```bash
# Build images and start all containers
make up

# Stop containers and remove volumes
make down

# Full reset: stop, remove containers + images + data directories
make fclean

# Rebuild from scratch
make re
```

> ⚠️ `make fclean` permanently deletes all database data and uploaded WordPress files.

`make up` automatically creates the required data directories on the host:
- `/home/<user>/data/db_data` — MariaDB persistent data
- `/home/<user>/data/wp_data` — WordPress files

---

## Accessing the website

Make sure this line is present in `/etc/hosts`:

```
127.0.0.1   rdedola.42.fr
```

Then open:

| URL | Description |
|---|---|
| `https://rdedola.42.fr` | WordPress website |
| `https://rdedola.42.fr/wp-admin` | Administration panel |

> The browser will show a **certificate warning** — this is expected. The certificate is self-signed. Click "Advanced" → "Proceed anyway".

---

## Credentials

All credentials are stored in `srcs/.env`. This file is never committed to git.

| Variable | Description |
|---|---|
| `SQL_DATABASE` | WordPress database name |
| `SQL_USER` | MariaDB user for WordPress |
| `SQL_PASSWORD` | Password for that user |
| `SQL_ROOT_PASSWORD` | MariaDB root password |
| `WORDPRESS_ADMIN_USER` | WordPress admin login (must not be `admin`) |
| `WORDPRESS_ADMIN_PASS` | WordPress admin password |
| `WORDPRESS_ADMIN_EMAIL` | WordPress admin email |
| `WORDPRESS_USER` | WordPress secondary user login |
| `WORDPRESS_USER_PASS` | Secondary user password |
| `WORDPRESS_USER_EMAIL` | Secondary user email |

---

## Checking that services are running

```bash
# Show status of all containers
docker compose -p inception ps
```

Expected output — all three services must show `Up`:

```
NAME        STATUS          PORTS
nginx       Up X minutes    0.0.0.0:443->443/tcp
wordpress   Up X minutes
mariadb     Up X minutes
```

Check logs for a specific service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

Verify TLS version:

```bash
curl -vI https://rdedola.42.fr --insecure 2>&1 | grep "SSL connection"
# Expected: * SSL connection using TLSv1.3 / ...
```

Verify port 80 is closed:

```bash
curl http://rdedola.42.fr
# Expected: curl: (7) Failed to connect to rdedola.42.fr port 80
```