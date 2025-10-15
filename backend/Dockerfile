# Backend PHP avec Apache
FROM php:8.2-apache

# Installer les dépendances pour PostgreSQL et PDO
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copier le code de ton projet
WORKDIR /var/www/html
COPY . .

# Optionnel : exposer le port 80
EXPOSE 80

# Lancer Apache en premier plan (par défaut avec l'image php:apache)
CMD ["apache2-foreground"]
