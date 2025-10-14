# TP4 - Tests automatisés avec Docker

## Objectif
Implémentation d'un système de tests automatisés intégré dans la CI/CD avec Docker.

## Consignes réalisées

### 1. Fichier `test_api.py` créé
- Framework Pytest configuré pour les tests d'API
- Validation des endpoints retournant `status_code == 200`
- Couverture complète des endpoints de l'API

### 2. Workflow GitHub Actions implémenté
- Pipeline automatisé dans `.github/workflows/test.yml`
- Exécution des tests via Docker Compose
- Configuration de l'intégration continue

### 3. Simulation d'erreur et validation
- Tests de simulation d'erreur pour validation de la détection automatique
- Détection d'erreur par la CI (pipeline rouge)
- Correction des tests pour validation du pipeline vert

## Architecture des tests

```
dockezr/
├── .github/workflows/
│   ├── test.yml                  # Pipeline CI/CD principal
│   └── test-connectivity.yml     # Pipeline simulation d'erreur
├── backend/
│   ├── test_api.py               # Tests Pytest principaux
│   ├── test_connectivity.py      # Tests de connectivité
│   ├── test_error_simulation.py  # Tests de simulation d'erreur
│   ├── requirements-test.txt     # Dépendances tests
│   └── Dockerfile.test           # Image Docker pour tests
├── docker-compose.yml            # Configuration avec service test
├── test.sh                       # Script de test (Linux/Mac)
├── test.bat                      # Script de test (Windows)
├── test-connectivity.sh          # Script simulation d'erreur (Linux/Mac)
└── test-connectivity.bat         # Script simulation d'erreur (Windows)
```

## Tests implémentés

| Test | Description | Status |
|------|-------------|--------|
| `test_health_endpoint` | Validation `/health` retourne 200 | Pass |
| `test_rooms_endpoint` | Validation `/rooms` retourne 200 | Pass |
| `test_reservations_endpoint` | Validation `/reservations` retourne 200 | Pass |
| `test_root_endpoint` | Validation `/` retourne 200 | Pass |
| `test_room_by_id` | Test récupération salle par ID | Pass |
| `test_room_not_found` | Test ID inexistant (404) | Pass |
| `test_reservations_by_date` | Test réservations par date | Pass |
| `test_simulated_error` | Test simulé (corrigé) | Pass |
| `test_api_response_time` | Test performance API | Pass |
| `test_backend_connection_timeout` | Simulation erreur connectivité | Fail (intentionnel) |
| `test_misconfigured_endpoint` | Simulation erreur configuration | Fail (intentionnel) |

## Commandes d'exécution

### Tests locaux avec Docker
```bash
# Démarrage des services
docker-compose up -d db backend

# Exécution des tests
docker-compose --profile test up --build --abort-on-container-exit test

# Scripts d'automatisation
./test.sh                    # Linux/Mac
test.bat                     # Windows
./test-connectivity.sh       # Simulation d'erreur (Linux/Mac)
test-connectivity.bat        # Simulation d'erreur (Windows)
```

### Tests avec couverture de code
```bash
docker-compose run --rm test pytest test_api.py --cov=. --cov-report=html
```

### Tests de simulation d'erreur
```bash
# Tests de connectivité avec erreurs intentionnelles
docker-compose run --rm test python -c "
import requests
try:
    response = requests.get('http://backend:9999/health', timeout=2)
except Exception as e:
    print('Erreur de connectivité simulée:', e)
"
```

## Résultats des tests

### Tests principaux (Pipeline vert)
```
============================= test session starts ==============================
platform linux -- Python 3.11.14, pytest-7.4.3, pluggy-1.6.0
collected 9 items

test_api.py::TestAPI::test_health_endpoint PASSED                        [ 11%]
test_api.py::TestAPI::test_rooms_endpoint PASSED                         [ 22%]
test_api.py::TestAPI::test_reservations_endpoint PASSED                  [ 33%]
test_api.py::TestAPI::test_root_endpoint PASSED                          [ 44%]
test_api.py::TestAPI::test_room_by_id PASSED                             [ 55%]
test_api.py::TestAPI::test_room_not_found PASSED                         [ 66%]
test_api.py::TestAPI::test_reservations_by_date PASSED                   [ 77%]
test_api.py::test_simulated_error PASSED                                 [ 88%]
test_api.py::test_api_response_time PASSED                               [100%]

============================== 9 passed in 0.06s ===============================
```

### Tests de simulation d'erreur (Pipeline rouge)
```
❌ Erreur de connectivité simulée détectée: HTTPConnectionPool(host='backend', port=9999): Max retries exceeded...
✅ La détection automatique d'erreur fonctionne!
```

## Livrables

- **Fichier `test_api.py`** - Tests Pytest complets
- **Pipeline vert** - Validation des tests normaux
- **Pipeline rouge** - Détection automatique d'erreur
- **Workflow GitHub Actions** - CI/CD automatisée
- **Configuration Docker** - Tests intégrés dans Docker

## Configuration technique

### Variables d'environnement
- `API_BASE_URL`: URL de l'API (défaut: http://localhost:8000)
- `DATABASE_URL`: URL de la base de données PostgreSQL

### Dépendances de test
- `pytest==7.4.3` - Framework de test
- `requests==2.31.0` - Client HTTP
- `pytest-cov==4.1.0` - Couverture de code
- `pytest-timeout==2.1.0` - Timeout des tests

## Validation TP4

Le système de tests automatisés est opérationnel avec validation de la détection automatique d'erreur.
