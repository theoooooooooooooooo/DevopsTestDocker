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

# Créer l'utilisateur et la base de données
echo "👤 Création de l'utilisateur et de la base de données..."
su postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" || echo "  Utilisateur déjà existant"
su postgres -c "psql -c \"CREATE DATABASE mydb OWNER myuser;\"" || echo "  Base de données déjà existante"

# Initialiser le schéma de la base de données
echo "📊 Initialisation du schéma de la base de données..."
su postgres -c "PGPASSWORD=mypassword psql -U myuser -d mydb -f /var/www/html/Ini.sql" 2>/dev/null || echo "  Schéma déjà initialisé"

# Vérifier que la table existe
echo "🔍 Vérification de la table 'salles'..."
TABLE_EXISTS=$(su postgres -c "PGPASSWORD=mypassword psql -U myuser -d mydb -t -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_name='salles';\"" | tr -d ' ')
if [ "$TABLE_EXISTS" = "1" ]; then
    echo "✅ Table 'salles' trouvée"
    SALLE_COUNT=$(su postgres -c "PGPASSWORD=mypassword psql -U myuser -d mydb -t -c 'SELECT COUNT(*) FROM salles;'" | tr -d ' ')
    echo "  📈 Nombre de salles : $SALLE_COUNT"
else
    echo "❌ Erreur: La table 'salles' n'existe pas!"
    exit 1
fi

echo "🎨 Démarrage du frontend..."
cd /var/www/html/frontend && PORT=${PORT:-10000} npm start &

echo "🌐 Démarrage d'Apache..."
exec apache2-foreground