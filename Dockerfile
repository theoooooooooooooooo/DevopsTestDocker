# Étape 1 : Build du frontend (Node.js)
FROM node:18 AS frontend
WORKDIR /app

# Copier et installer les dépendances du frontend
COPY frontend/package*.json ./
RUN npm install

# Copier le reste du code du frontend
COPY frontend/ .

# Construire ou simplement garder les fichiers statiques
# (si ton front n’a pas de build step, cette ligne n’est pas bloquante)
RUN npm run build || echo "Aucun build à exécuter — fichiers statiques conservés"

# Étape 2 : Backend PHP + Apache
FROM php:8.2-apache

# Installer les dépendances PostgreSQL + activer mod_rewrite
RUN apt-get update && apt-get install -y \ 
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite

# ➕ Autoriser les fichiers .htaccess
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# Copier le backend
WORKDIR /var/www/html
COPY backend/ .

# Copier les fichiers du frontend dans le dossier public du backend
# (ainsi Apache les servira directement depuis /)
COPY --from=frontend /app/public ./public

# Donner les bons droits
RUN chown -R www-data:www-data /var/www/html

# Variables d'environnement de la BD
ENV DB_HOST=db \
    DB_PORT=5432 \
    DB_NAME=mydb \
    DB_USER=myuser \
    DB_PASSWORD=mypassword

# Exposer le port web
EXPOSE 80

# Démarrer Apache
CMD ["apache2-foreground"]
