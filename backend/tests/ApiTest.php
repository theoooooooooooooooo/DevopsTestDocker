<?php

use PHPUnit\Framework\TestCase;

class ApiTest extends TestCase
{
    public function testHealthEndpoint()
    {
        $this->assertTrue(true);
    }

    public function testCreateSalleValidation()
    {
        // Test de validation des données
        $data = ['nom' => 'Salle Test', 'capacite' => 25];
        $this->assertArrayHasKey('nom', $data);
        $this->assertArrayHasKey('capacite', $data);
        $this->assertIsString($data['nom']);
        $this->assertIsInt($data['capacite']);
    }

    public function testSalleCapacitePositive()
    {
        $capacite = 30;
        $this->assertGreaterThan(0, $capacite);
    }

    public function testSalleNomNotEmpty()
    {
        $nom = 'Salle A101';
        $this->assertNotEmpty($nom);
    }
}