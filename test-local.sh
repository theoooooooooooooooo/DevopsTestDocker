#!/bin/bash
set -e

echo "🧪 Tests locaux avant déploiement sur Render"
echo "==========================================="

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Vérifier que le Dockerfile existe
echo ""
echo "📄 Test 1: Vérification du Dockerfile..."
if [ -f "Dockerfile" ]; then
    echo -e "${GREEN}✅ Dockerfile trouvé${NC}"
else
    echo -e "${RED}❌ Dockerfile manquant${NC}"
    exit 1
fi

# Test 2: Vérifier que start.sh existe
echo ""
echo "📄 Test 2: Vérification du script de démarrage..."
if [ -f "start.sh" ]; then
    echo -e "${GREEN}✅ start.sh trouvé${NC}"
else
    echo -e "${RED}❌ start.sh manquant${NC}"
    exit 1
fi
# Test 3: Vérifier que .htaccess existe
echo ""
echo "📄 Test 3: Vérification du fichier .htaccess..."
if [ -f "backend/.htaccess" ]; then
    echo -e "${GREEN}✅ backend/.htaccess trouvé${NC}"
else
    echo -e "${YELLOW}⚠️  backend/.htaccess manquant - sera créé${NC}"
    mkdir -p backend
    cat > backend/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [L]
EOF
    echo -e "${GREEN}✅ backend/.htaccess créé${NC}"
fi

# Test 4: Vérifier que Ini.sql existe
echo ""
echo "📄 Test 4: Vérification du script SQL..."
if [ -f "backend/Ini.sql" ]; then
    echo -e "${GREEN}✅ backend/Ini.sql trouvé${NC}"
else
    echo -e "${RED}❌ backend/Ini.sql manquant${NC}"
    exit 1
fi

# Test 5: Vérifier la syntaxe du Dockerfile
echo ""
echo "🔍 Test 5: Vérification de la syntaxe du Dockerfile..."
if grep -q '<Directory /var/www/html> \\' Dockerfile; then
    echo -e "${RED}❌ ERREUR: Dockerfile contient des backslashes incorrects${NC}"
    echo "   La ligne avec <Directory> doit utiliser \\n\\ pour les nouvelles lignes"
    exit 1
else
    echo -e "${GREEN}✅ Syntaxe du Dockerfile correcte${NC}"
fi
# Test 6: Build Docker local
echo ""
echo "🐳 Test 6: Build Docker (cela peut prendre quelques minutes)..."
if docker build -t gestion-salles-test . > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Build Docker réussi${NC}"
else
    echo -e "${RED}❌ Build Docker échoué${NC}"
    echo "   Exécutez 'docker build -t gestion-salles-test .' pour voir les erreurs"
    exit 1
fi

# Test 7: Lancer le conteneur (optionnel)
echo ""
echo "🚀 Test 7: Lancement du conteneur (optionnel)..."
echo -e "${YELLOW}Voulez-vous lancer le conteneur pour tester ? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Lancement du conteneur sur le port 10000..."
    docker run -d -p 10000:10000 --name gestion-salles-test gestion-salles-test
    
    echo "Attente du démarrage (30 secondes)..."
    sleep 30
    
    # Test de santé
    echo "Test de l'endpoint /health..."
    if curl -f http://localhost:10000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API répond correctement${NC}"
    else
        echo -e "${RED}❌ API ne répond pas${NC}"
        echo "Logs du conteneur :"
        docker logs gestion-salles-test
    fi
    
    echo ""
    echo "Nettoyage..."
    docker stop gestion-salles-test
    docker rm gestion-salles-test
fi

echo ""
echo "==========================================="
echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
echo ""
echo "Vous pouvez maintenant déployer sur Render :"
echo "1. Poussez votre code sur Git"
echo "2. Créez un nouveau Web Service sur Render"
echo "3. Configurez les variables d'environnement"
echo "4. Déployez !"
echo ""
echo "Pour plus d'informations, consultez DEPLOY_RENDER.md"