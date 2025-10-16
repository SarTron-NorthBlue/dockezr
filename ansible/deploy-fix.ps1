# Deploiement corrige avec inventaire simplifie

$ServerIP = "141.253.118.141"
$ServerUser = "root"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT DOCKEZR - Version Corrigee" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host "Utilisateur: $ServerUser" -ForegroundColor White
Write-Host ""
Write-Host "DEPLOIEMENT EN COURS..." -ForegroundColor Green
Write-Host "Cela va prendre 5-10 minutes" -ForegroundColor Yellow
Write-Host ""

# Verifier que la cle existe
if (-not (Test-Path "..\..\sskdockerz\ssh-key-2025-10-16.key")) {
    Write-Host "ERREUR: Cle SSH introuvable!" -ForegroundColor Red
    exit 1
}

Write-Host "[1/3] Preparation de l'inventaire..." -ForegroundColor Cyan
$inventoryContent = "[production]`n$ServerIP ansible_user=$ServerUser ansible_ssh_private_key_file=/ssh/ssh-key-2025-10-16.key ansible_python_interpreter=/usr/bin/python3 ansible_host_key_checking=false"
Set-Content -Path "inventory.ini" -Value $inventoryContent -Encoding UTF8 -NoNewline
Write-Host "  OK" -ForegroundColor Green

Write-Host "[2/3] Test de connexion..." -ForegroundColor Cyan
$testCmd = docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    -e ANSIBLE_HOST_KEY_CHECKING=False `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible -i inventory.ini all -m ping --private-key=/ssh/ssh-key-2025-10-16.key" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Connexion reussie" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION - Probleme de connexion mais on continue..." -ForegroundColor Yellow
}

Write-Host "[3/3] Execution du playbook Ansible..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Cela peut prendre plusieurs minutes..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    -e ANSIBLE_HOST_KEY_CHECKING=False `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible-playbook -i inventory.ini deploy.yml --private-key=/ssh/ssh-key-2025-10-16.key"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " DEPLOIEMENT TERMINE AVEC SUCCES!" -ForegroundColor Green
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
    Write-Host "Patience: Les services peuvent prendre 30-60 secondes" -ForegroundColor Yellow
    Write-Host "          pour demarrer completement." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Ouverture du frontend..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    Start-Process "http://$ServerIP`:3000"
    
    Write-Host ""
    Write-Host "Pour les captures d'ecran du TP7:" -ForegroundColor Yellow
    Write-Host "  1. Cette fenetre (deploiement reussi)" -ForegroundColor White
    Write-Host "  2. http://$ServerIP`:3000 (application web)" -ForegroundColor White
    Write-Host "  3. http://$ServerIP`:8001/docs (API Swagger)" -ForegroundColor White
    Write-Host "  4. SSH au serveur: docker ps" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " ERREUR PENDANT LE DEPLOIEMENT" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les messages d'erreur ci-dessus." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solutions possibles:" -ForegroundColor Yellow
    Write-Host "  - Verifier que le serveur est accessible" -ForegroundColor White
    Write-Host "  - Verifier les permissions SSH" -ForegroundColor White
    Write-Host "  - Verifier que root peut faire sudo" -ForegroundColor White
    Write-Host ""
}

