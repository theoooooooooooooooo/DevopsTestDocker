FROM php:8.2-apache

# Installer toutes les dépendances en une seule couche
RUN apt-get update && apt-get install -y \
postgresql postgresql-contrib \
libpq-dev \
zip \
unzip \
git \
supervisor \
curl \
sudo \
&& curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
&& apt-get install -y nodejs \
&& docker-php-ext-install pdo pdo_pgsql \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite + autoriser .htaccess
RUN a2enmod rewrite && \
    echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
    FallbackResource /index.php\n\
</Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# Éviter l'avertissement ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier backend
WORKDIR /var/www/html
COPY backend/ .

# Copier frontend
COPY frontend/ ./frontend

# Copier le script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Installer dépendances frontend
WORKDIR /var/www/html/frontend
RUN npm install

# Retour dans backend
WORKDIR /var/www/html

# Exposer le port Render
EXPOSE 10000

# Utiliser le script de démarrage
CMD ["/start.sh"]