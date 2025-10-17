# FROM php:8.2-apache

# # Installer PostgreSQL, Node.js, npm et PDO pour PostgreSQL
# RUN apt-get update && apt-get install -y \
#     libpq-dev \
#     postgresql \
#     nodejs \
#     npm \
#     && docker-php-ext-install pdo pdo_pgsql \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Activer mod_rewrite + autoriser .htaccess
# RUN a2enmod rewrite && \
#     echo "<Directory /var/www/html>\n\
#         AllowOverride All\n\
#         Require all granted\n\
#     </Directory>" > /etc/apache2/conf-available/allow-override.conf && \
#     a2enconf allow-override

# # Eviter l'avertissement ServerName
# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# # Copier backend
# WORKDIR /var/www/html
# COPY backend/ .

# # Copier frontend
# COPY frontend/ ./frontend

# # Installer dépendances frontend
# WORKDIR /var/www/html/frontend
# RUN npm install

# # Retour dans backend
# WORKDIR /var/www/html

# # Exposer uniquement le port que Render forwarde
# EXPOSE 10000

# # CMD : PostgreSQL, Node frontend sur PORT, Apache backend sur 8080 en arrière-plan
# CMD service postgresql start && \
#     su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\" || true" && \
#     su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\" || true" && \
#     cd /var/www/html/frontend && PORT=${PORT:-10000} npm start & \
#     apache2-foreground
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

# Copier backend
WORKDIR /var/www/html
COPY backend/ .

# Copier frontend
COPY frontend/ ./frontend

# Installer dépendances frontend
WORKDIR /var/www/html/frontend
RUN npm install

# Retour dans le dossier du backend
WORKDIR /var/www/html

# Adapter Apache pour écouter sur le port Render ($PORT)
RUN sed -i "s/80/\${PORT}/g" /etc/apache2/ports.conf && \
    sed -i "s/:80/:${PORT}/g" /etc/apache2/sites-available/000-default.conf || true

# Exposer uniquement le port utilisé par Render
EXPOSE 10000

# Lancer PostgreSQL + Apache + Node sur le même conteneur
CMD service postgresql start && \
    su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\" || true" && \
    su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\" || true" && \
    cd /var/www/html/frontend && npm start & \
    sed -i "s/80/${PORT}/g" /etc/apache2/ports.conf && \
    sed -i "s/:80/:${PORT}/g" /etc/apache2/sites-available/000-default.conf && \
    apache2-foreground
