# ========================================
# Image finale avec PostgreSQL + PHP + Apache
# ========================================
FROM php:8.2-apache

# Installer PostgreSQL et dépendances
RUN apt-get update && apt-get install -y \
    postgresql postgresql-contrib \
    libpq-dev \
    zip \
    unzip \
    git \
    supervisor \
    sudo \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    # Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Activer mod_rewrite
RUN a2enmod rewrite

# Éviter l'avertissement ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurer Apache pour écouter sur le port 10000 (Render au lieu de 80)
RUN sed -i 's/Listen 80/Listen 10000/' /etc/apache2/ports.conf

# Configuration Apache optimale (start.sh adaptera le port dynamiquement)
RUN echo '<VirtualHost *:10000>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/frontend-build\n\
    \n\
    <Directory /var/www/html/frontend-build>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
        FallbackResource /index.html\n\
    </Directory>\n\
    \n\
    # API PHP (préfixe /api)\n\
    Alias /api /var/www/html/index.php\n\
    <Location /api>\n\
        Require all granted\n\
        SetHandler application/x-httpd-php\n\
    </Location>\n\
    \n\
    # Health statique (créé par start.sh)\n\
    Alias /health /var/www/html/health.php\n\
    \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copier le backend
WORKDIR /var/www/html
COPY backend/ ./
RUN composer install --optimize-autoloader || true
# Activer les logs PHP détaillés (debug)
RUN echo "display_errors=On\nerror_reporting=E_ALL" > /usr/local/etc/php/conf.d/dev.ini

# Copier les fichiers statiques du frontend directement
COPY frontend/public/ ./frontend-build

# Configuration PostgreSQL pour accepter les connexions locales
RUN PG_VER=$(ls /etc/postgresql | head -n1) && \
    echo "host all all 127.0.0.1/32 md5" >> /etc/postgresql/$PG_VER/main/pg_hba.conf && \
    echo "host all all ::1/128 md5" >> /etc/postgresql/$PG_VER/main/pg_hba.conf && \
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" /etc/postgresql/$PG_VER/main/postgresql.conf

# Permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Copier le script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Exposer le port 10000 (Render)
EXPOSE 10000

# Utiliser le script de démarrage
CMD ["/start.sh"]