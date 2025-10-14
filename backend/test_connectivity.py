import pytest
import requests
import os
import time

# Configuration
BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

class TestConnectivity:
    """Tests de connectivité pour valider la détection automatique d'erreurs"""
    
    def test_backend_health_with_retry(self):
        """Test de santé du backend avec retry - devrait passer"""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                response = requests.get(f"{BASE_URL}/health", timeout=5)
                assert response.status_code == 200
                assert response.json()["status"] == "healthy"
                print(f"✅ Backend accessible (tentative {attempt + 1})")
                return
            except requests.exceptions.RequestException as e:
                print(f"⚠️ Tentative {attempt + 1} échouée: {e}")
                if attempt < max_retries - 1:
                    time.sleep(2)
                else:
                    raise
    
    def test_backend_connection_timeout(self):
        """Test de timeout de connexion - simule une erreur de connectivité"""
        # Ce test va échouer intentionnellement pour démontrer la détection d'erreur
        try:
            # Tentative de connexion à un port inexistant pour simuler une erreur
            response = requests.get("http://localhost:9999/health", timeout=2)
            assert False, "Cette ligne ne devrait jamais être atteinte"
        except requests.exceptions.ConnectionError:
            # C'est l'erreur attendue - on la laisse passer pour démontrer la détection
            print("❌ Erreur de connectivité détectée (comportement attendu)")
            raise Exception("Erreur de connectivité simulée pour tester la CI")
    
    def test_database_connectivity(self):
        """Test de connectivité à la base de données via l'API"""
        try:
            response = requests.get(f"{BASE_URL}/rooms", timeout=5)
            assert response.status_code == 200
            assert isinstance(response.json(), list)
            print("✅ Base de données accessible via l'API")
        except requests.exceptions.RequestException as e:
            print(f"❌ Erreur de connectivité base de données: {e}")
            raise
    
    def test_api_response_time_under_load(self):
        """Test de performance sous charge - simule une surcharge"""
        start_time = time.time()
        
        # Faire plusieurs requêtes simultanées pour simuler une charge
        responses = []
        for i in range(5):
            try:
                response = requests.get(f"{BASE_URL}/health", timeout=10)
                responses.append(response)
            except requests.exceptions.RequestException as e:
                print(f"❌ Requête {i+1} échouée: {e}")
                raise
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # Si le temps de réponse est trop long, on considère cela comme une erreur
        if total_time > 10:
            print(f"❌ Temps de réponse trop long: {total_time:.2f}s")
            raise Exception(f"Performance dégradée détectée: {total_time:.2f}s")
        
        print(f"✅ Performance acceptable: {total_time:.2f}s")
        assert total_time < 10

# Test pour simuler une erreur de configuration
def test_misconfigured_endpoint():
    """Test d'un endpoint mal configuré - simule une erreur de configuration"""
    # Ce test va échouer pour démontrer la détection d'erreur
    try:
        response = requests.get(f"{BASE_URL}/nonexistent-endpoint", timeout=5)
        if response.status_code == 404:
            print("❌ Endpoint inexistant détecté (comportement attendu)")
            raise Exception("Endpoint mal configuré détecté pour tester la CI")
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur de requête: {e}")
        raise Exception("Erreur de configuration détectée pour tester la CI")

# Test de simulation d'erreur réseau
def test_network_simulation():
    """Test de simulation d'erreur réseau - démontre la détection automatique"""
    # Simulation d'une panne réseau temporaire
    print("🔍 Simulation d'une panne réseau...")
    
    # Ce test va échouer intentionnellement
    try:
        # Tentative de connexion à un serveur inexistant
        response = requests.get("http://192.168.999.999:8000/health", timeout=1)
        assert False, "Connexion impossible - erreur réseau simulée"
    except requests.exceptions.RequestException:
        print("❌ Panne réseau simulée détectée (comportement attendu)")
        raise Exception("Erreur réseau simulée pour valider la détection automatique")
