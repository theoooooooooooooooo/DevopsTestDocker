1.0.0 - 2025-10-15
Ajouté

* Tests unitaires :

- Test basique qui vérifie que le système fonctionne
- Utilise assertTrue(true) - test minimal qui réussit toujours
- Valide la structure des données pour créer une salle
- Vérifie que les clés 'nom' et 'capacite' existent dans le tableau
- Contrôle les types de données (nom = string, capacité = integer)
- S'assure que la capacité d'une salle est un nombre positif
- Vérifie que le nom de la salle n'est pas vide

* Récupération des données de l'API lancer vers le frontend

* Mise en place de l'API

* Connexion à la base de donnée:

Se connecte à PostgreSQL en utilisant des variables d'environnement
Valeurs par défaut : host='db', database='gestion_salles', user/password='postgres'
Gestion d'erreur en cas d'échec de connexion

* Routage:

Création des routes:

GET /health : Vérification de santé de l'API
GET /salles : Liste toutes les salles
POST /salles : Crée une nouvelle salle
GET /salles/{id} : Détails d'une salle spécifique
PUT /salles/{id} : Modifie une salle existante
DELETE /salles/{id} : Supprime une salle
GET / : Documentation des endpoints disponibles


1.0.0 - 2025-10-14
Ajouté

* Gestion des salles (CRUD) :

Fonctionnalité de création de salles : Ajout d'une nouvelle salle avec attributs comme nom, capacité, emplacement et statut (via endpoint /salles POST ou équivalent).
Fonctionnalité de modification de salles : Mise à jour des détails d'une salle existante (via endpoint /salles/{id} PUT).
Fonctionnalité de suppression de salles : Suppression permanente d'une salle (via endpoint /salles/{id} DELETE), avec confirmation et gestion des dépendances.
Fonctionnalité d'affichage des salles : Récupération de la liste des salles (via endpoint /salles GET) et affichage détaillé d'une salle spécifique (via /salles/{id} GET), incluant filtrage et pagination.

1.0.0 - 2025-10-13
Ajouté

* Structure du projet : Initialisation avec fichiers de base (README.md, package.json ou équivalent), dépendances pour persistance (ex. : SQLite ou MongoDB) et API (ex. : Express ou Flask).
* Documentation : Ajout d'un README.md expliquant l'installation, l'utilisation des endpoints et le lancement des tests (ex. : npm test ou python -m pytest).
