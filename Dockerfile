############################
# Étape 1 : Build du Frontend
############################
FROM node:18 AS frontend-build

WORKDIR /app
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
# Si tu as un script build, tu peux le garder :
# RUN npm run build
# Sinon, on garde le dossier public
RUN mkdir -p /app/dist && cp -r public/* /app/dist/ || echo "Pas de build, on garde public"

############################
# Étape 2 : Backend PHP + Apache
############################
FROM php:8.2-apache

# Installer PostgreSQL et extensions PDO
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite et autoriser les .htaccess
RUN a2enmod rewrite && \
    echo "<Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>" > /etc/apache2/conf-available/allow-override.conf && \
    a2enconf allow-override

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier le backend
COPY backend/ .

# Copier le frontend compilé (ou public) dans un sous-dossier /frontend
COPY --from=frontend-build /app/dist ./frontend

# Donner les bons droits
RUN chown -R www-data:www-data /var/www/html

# Variables d’environnement par défaut (Render va les écraser)
ENV DB_HOST=mydb
ENV DB_PORT=5432
ENV DB_NAME=mydb
ENV DB_USER=myuser
ENV DB_PASSWORD=mypassword

# Exposer le port 80
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
