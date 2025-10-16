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

# Eviter l'avertissement ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier backend
WORKDIR /var/www/html
COPY backend/ .

# Copier frontend
COPY frontend/ ./frontend

# Installer dépendances frontend
WORKDIR /var/www/html/frontend
RUN npm install

# Retour dans backend
WORKDIR /var/www/html

# Exposer les ports
EXPOSE 80
EXPOSE 3000

# CMD pour lancer PostgreSQL + Node + Apache en une seule commande
CMD service postgresql start && \
    su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\" || true" && \
    su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\" || true" && \
    cd /var/www/html/frontend && nohup npm start & \
    apache2-foreground
