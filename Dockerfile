FROM php:8.2-apache

# Installer toutes les dépendances
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

# Activer mod_rewrite
RUN a2enmod rewrite

# Éviter l'avertissement ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurer Apache pour écouter sur le port 10000 (Render)
RUN sed -i 's/Listen 80/Listen 10000/' /etc/apache2/ports.conf

# Configuration Apache personnalisée pour servir frontend + backend
RUN echo '<VirtualHost *:10000>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    \n\
    # Frontend statique\n\
    <Directory /var/www/html/public>\n\
        Options -Indexes +FollowSymLinks\n\
        AllowOverride None\n\
        Require all granted\n\
    </Directory>\n\
    \n\
    # API Backend - Rediriger /api/* et routes API vers backend/index.php\n\
    RewriteEngine On\n\
    RewriteCond %{REQUEST_URI} ^/(health|salles|api)\n\
    RewriteRule ^(.*)$ /index.php [L,QSA]\n\
    \n\
    # Backend PHP\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Copier backend
WORKDIR /var/www/html
COPY backend/ .

# Copier les fichiers statiques du frontend dans le dossier web Apache
# Pas besoin de Node.js au runtime, juste les fichiers HTML/CSS/JS
COPY frontend/public/ ./public/

# Retour dans backend
WORKDIR /var/www/html

# Copier le script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Exposer le port Render
EXPOSE 10000

# Utiliser le script de démarrage
CMD ["/start.sh"]