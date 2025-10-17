<?php
require_once 'db.php';
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Gérer les requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Configuration de la base de données
$host = getenv('DB_HOST') ?: 'db';
$dbname = getenv('DB_NAME') ?: 'gestion_salles';
$username = getenv('DB_USER') ?: 'postgres';
$password = getenv('DB_PASSWORD') ?: 'postgres';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Erreur de connexion à la base de données: ' . $e->getMessage()]);
    exit;
}

// Router simple
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api', '', $path);

// Routes pour les salles
if (preg_match('/^\/salles\/?$/', $path)) {
    if ($method === 'GET') {
        getSalles($pdo);
    } elseif ($method === 'POST') {
        createSalle($pdo);
    }
} elseif (preg_match('/^\/salles\/(\d+)$/', $path, $matches)) {
    $id = $matches[1];
    if ($method === 'GET') {
        getSalle($pdo, $id);
    } elseif ($method === 'PUT') {
        updateSalle($pdo, $id);
    } elseif ($method === 'DELETE') {
        deleteSalle($pdo, $id);
    }
} elseif ($path === '/health') {
    echo json_encode(['status' => 'OK', 'message' => 'API de gestion des salles']);
} elseif ($path === '/' || $path === '') {
    echo json_encode([
        'message' => 'API de gestion des salles',
        'version' => '1.0',
        'endpoints' => [
            'GET /health' => 'Vérification de santé',
            'GET /salles' => 'Liste des salles',
            'POST /salles' => 'Créer une salle',
            'GET /salles/{id}' => 'Détails d\'une salle',
            'PUT /salles/{id}' => 'Modifier une salle',
            'DELETE /salles/{id}' => 'Supprimer une salle'
        ]
    ]);
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Route non trouvée']);
}

// Fonctions CRUD

function getSalles($pdo) {
    $stmt = $pdo->query('SELECT * FROM salles ORDER BY id');
    $salles = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($salles);
}

function getSalle($pdo, $id) {
    $stmt = $pdo->prepare('SELECT * FROM salles WHERE id = ?');
    $stmt->execute([$id]);
    $salle = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($salle) {
        echo json_encode($salle);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Salle non trouvée']);
    }
}

function createSalle($pdo) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['nom']) || !isset($data['capacite'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Données manquantes']);
        return;
    }
    
    $stmt = $pdo->prepare('INSERT INTO salles (nom, capacite, equipement, disponible) VALUES (?, ?, ?, ?)');
    $stmt->execute([
        $data['nom'],
        $data['capacite'],
        $data['equipement'] ?? '',
        $data['disponible'] ?? true
    ]);
    
    $id = $pdo->lastInsertId();
    http_response_code(201);
    echo json_encode(['id' => $id, 'message' => 'Salle créée avec succès']);
}

function updateSalle($pdo, $id) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $stmt = $pdo->prepare('UPDATE salles SET nom = ?, capacite = ?, equipement = ?, disponible = ? WHERE id = ?');
    $stmt->execute([
        $data['nom'],
        $data['capacite'],
        $data['equipement'] ?? '',
        $data['disponible'] ?? true,
        $id
    ]);
    
    echo json_encode(['message' => 'Salle mise à jour avec succès']);
}

function deleteSalle($pdo, $id) {
    $stmt = $pdo->prepare('DELETE FROM salles WHERE id = ?');
    $stmt->execute([$id]);
    
    echo json_encode(['message' => 'Salle supprimée avec succès']);
}