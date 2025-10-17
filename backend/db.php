<?php
try {
    // Connexion à PostgreSQL interne au conteneur
    $dsn = "pgsql:host=127.0.0.1;port=5432;dbname=mydb";
    $user = "myuser";
    $password = "mypassword";

    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    // Retour JSON pour le frontend en cas d'erreur
    echo json_encode([
        "error" => "Erreur de connexion à la base de données: " . $e->getMessage()
    ]);
    exit;
}
