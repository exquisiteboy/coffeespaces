#!/bin/bash
set -e

WP_CONFIG="/var/www/html/wp-config.php"
HOST="${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
SITE_URL="https://${HOST}"

# Wait for MariaDB to be ready
until php -r 'new PDO("mysql:host=db;dbname=wordpress", "wordpress", "wordpress_password");' 2>/dev/null; do
    echo "Waiting for database..."
    sleep 2
done

# Wait until WordPress entrypoint generates wp-config.php
while [ ! -f "$WP_CONFIG" ]; do
    echo "Waiting for wp-config.php..."
    sleep 1
done

# Inject Codespace URL and reverse-proxy headers if not already present
if ! grep -q "WP_HOME" "$WP_CONFIG"; then
    sed -i "/That's all, stop editing/i define('WP_HOME', '${SITE_URL}');\ndefine('WP_SITEURL', '${SITE_URL}');\n\$_SERVER['HTTP_HOST'] = '${HOST}';\n\$_SERVER['HTTPS'] = 'on';" "$WP_CONFIG"
fi

echo "WordPress is ready at: ${SITE_URL}"


