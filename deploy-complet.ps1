# Script de deploiement complet sur le serveur

$ServerIP = "141.253.118.141"
$ServerUser = "root"
$KeyPath = "..\sskdockerz\ssh-key-2025-10-16.key"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT COMPLET DOCKEZR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host ""

Write-Host "[1/5] Copie des fichiers du projet..." -ForegroundColor Cyan

# Utiliser scp pour copier les fichiers
docker run --rm `
    -v "${PWD}:/project" `
    -v "${PWD}\..\sskdockerz:/ssh" `
    -w /project `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && scp -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key -r /project root@141.253.118.141:/opt/dockezr"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Fichiers copies" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors de la copie" -ForegroundColor Red
}

Write-Host "[2/5] Verification des fichiers sur le serveur..." -ForegroundColor Cyan
docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 'ls -la /opt/dockezr/'"

Write-Host "[3/5] Configuration de l'environnement..." -ForegroundColor Cyan
docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c @"
chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 'cat > /opt/dockezr/.env << EOF
DATABASE_URL=postgresql://user:password@db:5432/dockezr
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=dockezr
NEXT_PUBLIC_API_URL=http://141.253.118.141:8001
EOF'
"@

Write-Host "  OK - Environnement configure" -ForegroundColor Green

Write-Host "[4/5] Lancement de docker-compose..." -ForegroundColor Cyan
Write-Host "  Cela peut prendre 2-3 minutes..." -ForegroundColor Yellow
docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 'cd /opt/dockezr && docker-compose up -d'"

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Conteneurs lances" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors du lancement" -ForegroundColor Red
}

Write-Host ""
Write-Host "[5/5] Verification des conteneurs..." -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 5

docker run --rm `
    -v "${PWD}\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 'docker ps'"

Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " DEPLOIEMENT TERMINE!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acces aux services:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Frontend:     http://$ServerIP`:3000" -ForegroundColor White
    Write-Host "  Backend API:  http://$ServerIP`:8001" -ForegroundColor White
    Write-Host "  Swagger:      http://$ServerIP`:8001/docs" -ForegroundColor White
    Write-Host "  Prometheus:   http://$ServerIP`:9090" -ForegroundColor White
    Write-Host "  Grafana:      http://$ServerIP`:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Les services vont demarrer dans 30-60 secondes..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Ouverture du frontend dans le navigateur..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    Start-Process "http://$ServerIP`:3000"
}

