@echo off
echo ========================================
echo   Demarrage de Dockezr
echo ========================================
echo.

echo Verification de Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Docker n'est pas installe ou n'est pas dans le PATH
    pause
    exit /b 1
)

echo Docker est installe !
echo.

echo Demarrage des conteneurs...
docker-compose up -d

echo.
echo ========================================
echo   Services demarres avec succes !
echo ========================================
echo.
echo Frontend: http://localhost:3000
echo Backend API: http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
echo Pour voir les logs: docker-compose logs -f
echo Pour arreter: docker-compose down
echo.
pause

