@echo off
chcp 65001 >nul
echo TP4 - Tests automatises avec Docker
echo ======================================

echo Demarrage des tests...

echo Demarrage des services (DB + Backend)...
docker-compose up -d db backend

echo Attente des services (15 secondes)...
timeout /t 15 /nobreak > nul

echo Verification du backend...
curl -s http://localhost:8000/health > nul
if %errorlevel% equ 0 (
    echo [OK] Backend operationnel
) else (
    echo [ERREUR] Backend non accessible
    exit /b 1
)

echo Lancement des tests...
docker-compose --profile test up --build --abort-on-container-exit test

echo Resultats des tests:
docker-compose --profile test logs test

echo Nettoyage...
docker-compose --profile test down -v

echo [OK] Tests termines !
echo TP4 termine avec succes !
