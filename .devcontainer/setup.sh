#!/bin/bash
set -e

# Install WP-CLI directly
if ! command -v wp &> /dev/null; then
    curl -O https://githubusercontent.com
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Wait for MariaDB to be ready using PHP
until php -r 'new PDO("mysql:host=db;dbname=wordpress", "wordpress", "wordpress_password");' 2>/dev/null; do
    echo "Waiting for database..."
    sleep 2
done

# Dynamically set the Codespace URL
SITE_URL="https://${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

# Configure and install WordPress if not already installed
if ! wp core is-installed --allow-root; then
    wp config set WP_HOME "$SITE_URL" --allow-root
    wp config set WP_SITEURL "$SITE_URL" --allow-root
    wp config set FORCE_SSL_ADMIN true --raw --allow-root
    
    # Ensure HTTPS is detected behind GitHub's reverse proxy
    wp config set \$_SERVER[\'HTTPS\'] \'on\' --raw --allow-root

    wp core install \
        --url="$SITE_URL" \
        --title="Codespace WordPress" \
        --admin_user="admin" \
        --admin_password="password" \
        --admin_email="admin@example.com" \
        --skip-email \
        --allow-root
fi

echo "WordPress is ready at: $SITE_URL"
