-- Script d'initialisation de la base de données PostgreSQL
-- La base de données 'gestion_salles' est déjà créée par Docker

-- Création de la table salles
CREATE TABLE IF NOT EXISTS salles (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    capacite INTEGER NOT NULL,
    equipement TEXT,
    disponible BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Données de test
INSERT INTO salles (nom, capacite, equipement, disponible) VALUES
    ('Salle A101', 30, 'Projecteur, Tableau blanc', true),
    ('Salle B202', 50, 'Projecteur, Ordinateurs', true),
    ('Amphithéâtre C', 200, 'Projecteur, Sonorisation, Vidéo', false),
    ('Salle de réunion D1', 10, 'Tableau blanc, Visio-conférence', true)
ON CONFLICT DO NOTHING;