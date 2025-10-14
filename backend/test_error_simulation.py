import pytest
import requests
import os

# Configuration
BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

def test_backend_accessible():
    """Test que le backend est accessible - devrait passer"""
    response = requests.get(f"{BASE_URL}/health", timeout=5)
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    print("✅ Backend accessible")

def test_simulated_connectivity_error():
    """Test qui simule une erreur de connectivité - va échouer intentionnellement"""
    # Ce test va échouer pour démontrer la détection automatique d'erreur
    try:
        # Tentative de connexion à un port inexistant
        response = requests.get("http://backend:9999/health", timeout=2)
        assert False, "Cette connexion ne devrait pas réussir"
    except requests.exceptions.ConnectionError as e:
        print("❌ Erreur de connectivité simulée détectée")
        # On force l'échec pour démontrer la détection automatique
        raise Exception("Erreur de connectivité simulée pour valider la détection automatique")

def test_nonexistent_endpoint():
    """Test d'un endpoint inexistant - va échouer intentionnellement"""
    try:
        response = requests.get(f"{BASE_URL}/nonexistent-endpoint", timeout=5)
        if response.status_code == 404:
            print("❌ Endpoint inexistant détecté")
            # On force l'échec pour démontrer la détection automatique
            raise Exception("Endpoint inexistant détecté pour valider la détection automatique")
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur de requête: {e}")
        raise Exception("Erreur de requête détectée pour valider la détection automatique")
