# 🧪 TP4 - Tests automatisés avec Docker

## 📋 Objectif
Automatiser les tests de l'application dans la CI avec Docker.

## ✅ Consignes réalisées

### 1. ✅ Fichier `test_api.py` créé
- **Pytest** configuré pour tester l'API
- Tests pour vérifier que les endpoints retournent `status_code == 200`
- Tests complets pour tous les endpoints de l'API

### 2. ✅ Workflow GitHub Actions ajouté
- Pipeline automatisé dans `.github/workflows/test.yml`
- Tests exécutés avec Docker Compose
- Intégration continue configurée

### 3. ✅ Simulation d'erreur et correction
- Test simulé créé pour valider la détection automatique
- Erreur détectée par la CI (pipeline rouge)
- Test corrigé pour obtenir un pipeline vert

## 🏗️ Architecture des tests

```
dockezr/
├── .github/workflows/test.yml     # Pipeline CI/CD
├── backend/
│   ├── test_api.py               # Tests Pytest
│   ├── requirements-test.txt     # Dépendances tests
│   └── Dockerfile.test           # Image Docker pour tests
├── docker-compose.yml            # Configuration avec service test
├── test.sh                       # Script de test (Linux/Mac)
└── test.bat                      # Script de test (Windows)
```

## 🧪 Tests implémentés

| Test | Description | Status |
|------|-------------|--------|
| `test_health_endpoint` | Vérifie `/health` retourne 200 | ✅ |
| `test_rooms_endpoint` | Vérifie `/rooms` retourne 200 | ✅ |
| `test_reservations_endpoint` | Vérifie `/reservations` retourne 200 | ✅ |
| `test_root_endpoint` | Vérifie `/` retourne 200 | ✅ |
| `test_room_by_id` | Test récupération salle par ID | ✅ |
| `test_room_not_found` | Test ID inexistant (404) | ✅ |
| `test_reservations_by_date` | Test réservations par date | ✅ |
| `test_simulated_error` | Test simulé (corrigé) | ✅ |
| `test_api_response_time` | Test performance API | ✅ |

## 🚀 Commandes pour lancer les tests

### Tests locaux avec Docker
```bash
# Démarrer les services
docker-compose up -d db backend

# Lancer les tests
docker-compose --profile test up --build --abort-on-container-exit test

# Ou utiliser le script
./test.sh        # Linux/Mac
test.bat         # Windows
```

### Tests avec couverture
```bash
docker-compose run --rm test pytest test_api.py --cov=. --cov-report=html
```

## 📊 Résultats des tests

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

## 🎯 Livrables

- ✅ **Fichier `test_api.py`** - Tests Pytest complets
- ✅ **Pipeline "vert"** - Tous les tests passent
- ✅ **Workflow GitHub Actions** - CI/CD automatisée
- ✅ **Configuration Docker** - Tests intégrés dans Docker

## 🔧 Configuration technique

### Variables d'environnement
- `API_BASE_URL`: URL de l'API (défaut: http://localhost:8000)
- `DATABASE_URL`: URL de la base de données PostgreSQL

### Dépendances de test
- `pytest==7.4.3` - Framework de test
- `requests==2.31.0` - Client HTTP
- `pytest-cov==4.1.0` - Couverture de code
- `pytest-timeout==2.1.0` - Timeout des tests

## 🎉 TP4 terminé avec succès !

Le système de tests automatisés est maintenant opérationnel et prêt pour la production.
