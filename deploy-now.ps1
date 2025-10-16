# Deploiement immediat sur le serveur

$ServerIP = "141.253.118.141"

Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT DOCKEZR SUR LE SERVEUR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Serveur: $ServerIP`n" -ForegroundColor White

# Etape 1: Copie des fichiers
Write-Host "[1/3] Copie des fichiers sur le serveur..." -ForegroundColor Yellow
Write-Host "Cela peut prendre 1-2 minutes...`n" -ForegroundColor Gray

docker run --rm `
    -v "${PWD}:/project" `
    -v "${PWD}\..\sskdockerz:/ssh" `
    -w / `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && tar czf - -C /project . | ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@$ServerIP 'mkdir -p /opt/dockezr && cd /opt/dockezr && tar xzf -'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK - Fichiers copies`n" -ForegroundColor Green
} else {
    Write-Host "ERREUR lors de la copie`n" -ForegroundColor Red
    exit 1
}

# Etape 2: Lancement de docker-compose
Write-Host "[2/3] Lancement de docker-compose..." -ForegroundColor Yellow
Write-Host "Construction et demarrage des conteneurs...`n" -ForegroundColor Gray

docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@$ServerIP 'cd /opt/dockezr && docker-compose up -d --build'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK - Conteneurs lances`n" -ForegroundColor Green
} else {
    Write-Host "ERREUR lors du lancement`n" -ForegroundColor Red
}

# Etape 3: Verification
Write-Host "[3/3] Verification des conteneurs en cours...`n" -ForegroundColor Yellow

Start-Sleep -Seconds 5

docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@$ServerIP 'docker ps --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\"'"

Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host " DEPLOIEMENT TERMINE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Vos services sont accessibles a:`n" -ForegroundColor Cyan
Write-Host "  Frontend:     http://$ServerIP`:3000" -ForegroundColor White
Write-Host "  Backend API:  http://$ServerIP`:8001" -ForegroundColor White
Write-Host "  Swagger:      http://$ServerIP`:8001/docs" -ForegroundColor White
Write-Host "  Prometheus:   http://$ServerIP`:9090" -ForegroundColor White
Write-Host "  Grafana:      http://$ServerIP`:3001`n" -ForegroundColor White

Write-Host "Attendez 30-60 secondes que tout demarre completement...`n" -ForegroundColor Yellow

Write-Host "Ouverture du frontend..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
Start-Process "http://$ServerIP`:3000"

Write-Host "`nDeploiement termine! Les conteneurs sont en cours de demarrage." -ForegroundColor Green

