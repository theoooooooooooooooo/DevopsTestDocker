#!/bin/bash
set -e

echo "🚀 Démarrage des services..."

# Démarrer PostgreSQL
echo "📦 Démarrage de PostgreSQL..."
service postgresql start

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until pg_isready -h 127.0.0.1 -p 5432; do
  echo "  En attente..."
  sleep 2
done
echo "✅ PostgreSQL est prêt!"

# Configurer PostgreSQL pour accepter les connexions avec mot de passe
echo "🔧 Configuration de PostgreSQL..."
PG_HBA="/etc/postgresql/17/main/pg_hba.conf"
if [ -f "$PG_HBA" ]; then
    # Autoriser les connexions locales avec mot de passe
    echo "local   all             myuser                                  md5" >> "$PG_HBA"
    echo "host    all             myuser          127.0.0.1/32            md5" >> "$PG_HBA"
    echo "host    all             myuser          ::1/128                 md5" >> "$PG_HBA"
    # Recharger la configuration
    su postgres -c "psql -c 'SELECT pg_reload_conf();'" > /dev/null
    echo "  ✅ Configuration PostgreSQL mise à jour"
fi
# Créer l'utilisateur et la base de données
echo "👤 Création de l'utilisateur et de la base de données..."
su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" 2>/dev/null || echo "  Utilisateur déjà existant"
su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\"" 2>/dev/null || echo "  Base de données déjà existante"

# Initialiser le schéma de la base de données
echo "📊 Initialisation du schéma de la base de données..."
PGPASSWORD=mypassword psql -h 127.0.0.1 -U myuser -d mydb -f /var/www/html/Ini.sql 2>/dev/null || echo "  Schéma déjà initialisé"

# Vérifier que la table existe
echo "🔍 Vérification de la table 'salles'..."
TABLE_EXISTS=$(PGPASSWORD=mypassword psql -h 127.0.0.1 -U myuser -d mydb -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='salles';" | tr -d ' ')
if [ "$TABLE_EXISTS" = "1" ]; then
    echo "✅ Table 'salles' trouvée"
    SALLE_COUNT=$(PGPASSWORD=mypassword psql -h 127.0.0.1 -U myuser -d mydb -t -c 'SELECT COUNT(*) FROM salles;' | tr -d ' ')
    echo "  📈 Nombre de salles : $SALLE_COUNT"
else
    echo "❌ Erreur: La table 'salles' n'existe pas!"
    exit 1
fi

# Health statique (évite de passer par index.php)
echo "<?php http_response_code(200); echo 'OK';" > /var/www/html/health.php

# Adapter Apache au $PORT de Render
PORT="${PORT:-10000}"
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:10000>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "🌐 Apache écoute sur ${PORT}"
exec apache2-foreground