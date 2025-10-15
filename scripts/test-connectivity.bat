@echo off
chcp 65001 >nul
echo Test de connectivite - Simulation d'erreurs
echo ==========================================

echo Verification de l'etat des services...
docker compose ps

echo.
echo Demarrage des tests de connectivite...
echo (Ces tests vont simuler des erreurs pour valider la detection automatique)

echo.
echo Test 1: Backend accessible
docker compose run --rm test python -c "
import requests
try:
    response = requests.get('http://backend:8000/health', timeout=5)
    print('✅ Backend accessible')
except Exception as e:
    print('❌ Backend inaccessible:', e)
"

echo.
echo Test 2: Simulation d'erreur de connectivite
docker compose run --rm test python -c "
import requests
try:
    response = requests.get('http://backend:8000/nonexistent', timeout=5)
    print('❌ Erreur attendue: endpoint inexistant')
except Exception as e:
    print('❌ Erreur de connectivite simulee:', e)
"

echo.
echo Test 3: Test avec pytest (avec erreurs intentionnelles)
docker compose run --rm test pytest test_connectivity.py -v

echo.
echo Tests de connectivite termines !
echo Les erreurs ci-dessus sont intentionnelles pour valider la detection automatique.
