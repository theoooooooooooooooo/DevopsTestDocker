<?php
header('Content-Type: application/json');

// Infos de connexion DB
$dbInfo = [
    'DB_HOST' => getenv('DB_HOST') ?: '127.0.0.1',
    'DB_NAME' => getenv('DB_NAME') ?: 'mydb',
    'DB_USER' => getenv('DB_USER') ?: 'myuser',
    'DB_PASSWORD' => getenv('DB_PASSWORD') ? '***' : 'mypassword (défaut)',
];

// Test connexion DB
try {
    $host = $dbInfo['DB_HOST'];
    $dbname = $dbInfo['DB_NAME'];
    $username = $dbInfo['DB_USER'];
    $password = getenv('DB_PASSWORD') ?: 'mypassword';
    
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->query('SELECT COUNT(*) as count FROM salles');
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $dbStatus = [
        'connected' => true,
        'salles_count' => $result['count']
    ];
} catch (PDOException $e) {
    $dbStatus = [
        'connected' => false,
        'error' => $e->getMessage()
    ];
}

echo json_encode([
    'status' => 'debug_info',
    'request_uri' => $_SERVER['REQUEST_URI'],
    'php_version' => PHP_VERSION,
    'database' => $dbInfo,
    'database_connection' => $dbStatus,
], JSON_PRETTY_PRINT);
?>