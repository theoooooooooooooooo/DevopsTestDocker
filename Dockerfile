FROM php:8.2-apache

# Installer Node, PostgreSQL et extensions PDO
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite + .htaccess
RUN a2enmod rewrite && \
    echo "<Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# ServerName pour éviter l'avertissement
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier le backend
WORKDIR /var/www/html
COPY backend/ .

# Copier le frontend
COPY frontend/ ./frontend

# Installer les deps Node
WORKDIR /var/www/html/frontend
RUN npm install

# Retour dans le backend
WORKDIR /var/www/html

# Script de démarrage qui lance PostgreSQL, Node et Apache
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
EXPOSE 3000

CMD ["/start.sh"]
