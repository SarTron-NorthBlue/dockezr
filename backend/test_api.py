import pytest
import requests
import os
import time

# Configuration
BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

class TestAPI:
    """Tests pour l'API de réservation de salles Expernet"""
    
    def test_health_endpoint(self):
        """Test que l'endpoint /health retourne 200"""
        response = requests.get(f"{BASE_URL}/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"
    
    def test_rooms_endpoint(self):
        """Test que l'endpoint /rooms retourne 200"""
        response = requests.get(f"{BASE_URL}/rooms")
        assert response.status_code == 200
        assert isinstance(response.json(), list)
        # Vérifier qu'il y a au moins une salle
        rooms = response.json()
        assert len(rooms) > 0
        # Vérifier la structure d'une salle
        if rooms:
            room = rooms[0]
            assert "id" in room
            assert "name" in room
            assert "capacity" in room
    
    def test_reservations_endpoint(self):
        """Test que l'endpoint /reservations retourne 200"""
        response = requests.get(f"{BASE_URL}/reservations")
        assert response.status_code == 200
        assert isinstance(response.json(), list)
    
    def test_root_endpoint(self):
        """Test que l'endpoint racine retourne 200"""
        response = requests.get(f"{BASE_URL}/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "status" in data
    
    def test_room_by_id(self):
        """Test récupération d'une salle par ID"""
        # D'abord récupérer la liste des salles
        rooms_response = requests.get(f"{BASE_URL}/rooms")
        assert rooms_response.status_code == 200
        rooms = rooms_response.json()
        
        if rooms:
            room_id = rooms[0]["id"]
            response = requests.get(f"{BASE_URL}/rooms/{room_id}")
            assert response.status_code == 200
            room = response.json()
            assert "id" in room
            assert "name" in room
            assert "capacity" in room
            assert room["id"] == room_id
    
    def test_room_not_found(self):
        """Test qu'un ID de salle inexistant retourne 404"""
        response = requests.get(f"{BASE_URL}/rooms/99999")
        assert response.status_code == 404
    
    def test_reservations_by_date(self):
        """Test récupération des réservations par date"""
        # Utiliser une date future
        test_date = "2025-12-31"
        response = requests.get(f"{BASE_URL}/reservations/date/{test_date}")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

# Test pour simuler une erreur (maintenant corrigé)
def test_simulated_error():
    """Test qui était simulé pour valider la détection automatique - maintenant corrigé"""
    # Test corrigé pour valider que la CI fonctionne
    assert 1 == 1, "Test corrigé - la CI fonctionne correctement"

# Test de performance basique
def test_api_response_time():
    """Test que l'API répond dans un temps raisonnable"""
    start_time = time.time()
    response = requests.get(f"{BASE_URL}/health")
    end_time = time.time()
    
    assert response.status_code == 200
    assert (end_time - start_time) < 5.0  # Moins de 5 secondes
