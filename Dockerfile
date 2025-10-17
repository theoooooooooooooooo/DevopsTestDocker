FROM php:8.2-apache

# Installer PostgreSQL, Node.js, npm et PDO pour PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite + autoriser .htaccess
RUN a2enmod rewrite && \
    echo "<Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# Éviter l'avertissement ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier tout le projet dans le conteneur
WORKDIR /var/www/html
COPY . .

# Installer dépendances Node.js
RUN npm install

# Exposer le port que Render forwarde
EXPOSE 10000

# CMD : PostgreSQL, Node frontend, Apache backend
CMD service postgresql start && \
    su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\" || true" && \
    su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\" || true" && \
    PORT=${PORT:-10000} node server.js & \
    apache2-foreground
