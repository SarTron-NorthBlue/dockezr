# Deploiement manuel sur le serveur via SSH

$ServerIP = "141.253.118.141"
$ServerUser = "root"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT MANUEL DOCKEZR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host ""

# Fonction pour executer des commandes SSH
function Invoke-SSHCommand {
    param([string]$Command)
    docker run --rm -v "${PWD}\..\..\sskdockerz:/ssh" willhallonline/ansible:latest sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key $ServerUser@$ServerIP '$Command'"
}

Write-Host "[1/8] Installation de Docker..." -ForegroundColor Cyan
Invoke-SSHCommand "apt update && apt install -y docker.io docker-compose git curl"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Docker installe" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors de l'installation" -ForegroundColor Red
}

Write-Host "[2/8] Demarrage du service Docker..." -ForegroundColor Cyan
Invoke-SSHCommand "systemctl start docker && systemctl enable docker"
Write-Host "  OK" -ForegroundColor Green

Write-Host "[3/8] Verification de Docker..." -ForegroundColor Cyan
Invoke-SSHCommand "docker --version"
Write-Host "  OK" -ForegroundColor Green

Write-Host "[4/8] Creation du repertoire de deploiement..." -ForegroundColor Cyan
Invoke-SSHCommand "mkdir -p /opt/dockezr"
Write-Host "  OK" -ForegroundColor Green

Write-Host "[5/8] Clonage du repository (depuis votre machine)..." -ForegroundColor Cyan
Write-Host "  Copie des fichiers vers le serveur..." -ForegroundColor Yellow
# On va copier les fichiers necessaires via SSH
docker run --rm `
    -v "${PWD}\..:/project" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /project `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && tar czf - dockezr | ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key $ServerUser@$ServerIP 'cd /opt && tar xzf -'"

Write-Host "  OK - Fichiers copies" -ForegroundColor Green

Write-Host "[6/8] Creation du fichier .env..." -ForegroundColor Cyan
$envContent = @"
POSTGRES_USER=dockezr_user
POSTGRES_PASSWORD=dockezr_password_2024
POSTGRES_DB=dockezr
DB_PORT=5432
BACKEND_PORT=8001
FRONTEND_PORT=3000
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
NEXT_PUBLIC_API_URL=http://$ServerIP:8001
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123
NODE_ENV=production
"@

$envContent | Out-File -FilePath "temp.env" -Encoding ASCII -NoNewline
docker run --rm `
    -v "${PWD}\temp.env:/tmp/env" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    willhallonline/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && cat /tmp/env | ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key $ServerUser@$ServerIP 'cat > /opt/dockezr/.env'"

Remove-Item "temp.env" -ErrorAction SilentlyContinue
Write-Host "  OK - Environnement configure" -ForegroundColor Green

Write-Host "[7/8] Lancement des conteneurs Docker..." -ForegroundColor Cyan
Write-Host "  Cela peut prendre quelques minutes..." -ForegroundColor Yellow
Invoke-SSHCommand "cd /opt/dockezr && docker-compose up -d --build"
Write-Host "  OK - Conteneurs lances" -ForegroundColor Green

Start-Sleep -Seconds 5

Write-Host "[8/8] Verification des conteneurs..." -ForegroundColor Cyan
Write-Host ""
Invoke-SSHCommand "docker ps"
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " DEPLOIEMENT REUSSI!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vos services DockeZR sont maintenant en ligne:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Frontend:     http://$ServerIP`:3000" -ForegroundColor White
    Write-Host "  Backend API:  http://$ServerIP`:8001" -ForegroundColor White
    Write-Host "  Swagger Docs: http://$ServerIP`:8001/docs" -ForegroundColor White
    Write-Host "  Prometheus:   http://$ServerIP`:9090" -ForegroundColor White
    Write-Host "  Grafana:      http://$ServerIP`:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Attendez 30-60 secondes que tout demarre..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Ouverture du frontend..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    Start-Process "http://$ServerIP`:3000"
    
    Write-Host ""
    Write-Host "CAPTURES D'ECRAN POUR LE TP7:" -ForegroundColor Yellow
    Write-Host "  1. Cette fenetre PowerShell" -ForegroundColor White
    Write-Host "  2. http://$ServerIP`:3000" -ForegroundColor White
    Write-Host "  3. http://$ServerIP`:8001/docs" -ForegroundColor White
    Write-Host ""
}

