# Backend PHP avec Apache
FROM php:8.2-apache

# Installer les dépendances pour PostgreSQL et PDO
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ➕ Activer mod_rewrite pour que les routes /salles fonctionnent
RUN a2enmod rewrite

# ➕ Autoriser les fichiers .htaccess dans /var/www/html
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# Copier le code de ton projet
WORKDIR /var/www/html
COPY . .

# Donner les bons droits (optionnel mais recommandé)
RUN chown -R www-data:www-data /var/www/html

# Exposer le port 80
EXPOSE 80

# Démarrer Apache
CMD ["apache2-foreground"]
