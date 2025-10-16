# Script de deploiement via Docker (sans WSL Ubuntu)
# Utilise un conteneur Ansible pour deployer

param(
    [string]$ServerIP = "",
    [string]$ServerUser = ""
)

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " Deploiement Ansible via Docker - DockeZR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Verifier que Docker est en cours d'execution
Write-Host "[1/7] Verification de Docker..." -ForegroundColor Cyan
$dockerCheck = docker version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERREUR - Docker n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "  Demarrez Docker Desktop puis reessayez" -ForegroundColor Yellow
    exit 1
}
Write-Host "  OK - Docker est actif" -ForegroundColor Green

# Demander les informations du serveur
if ($ServerIP -eq "") {
    Write-Host ""
    $ServerIP = Read-Host "Entrez l'adresse IP de votre serveur Linux"
}

if ($ServerUser -eq "") {
    $ServerUser = Read-Host "Entrez le nom d'utilisateur SSH (ex: ubuntu, root)"
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Serveur: $ServerIP" -ForegroundColor White
Write-Host "  Utilisateur: $ServerUser" -ForegroundColor White
Write-Host ""

# Creer l'inventaire
Write-Host "[2/7] Configuration de l'inventaire..." -ForegroundColor Cyan
$inventoryContent = @"
[production]
server ansible_host=$ServerIP ansible_user=$ServerUser ansible_ssh_private_key_file=/ansible/ssh-key

[production:vars]
ansible_python_interpreter=/usr/bin/python3
"@

Set-Content -Path "inventory.ini" -Value $inventoryContent -Encoding UTF8
Write-Host "  OK - Inventaire configure" -ForegroundColor Green

# Verifier la cle SSH
Write-Host "[3/7] Verification de la cle SSH..." -ForegroundColor Cyan
$sshKeyPath = "..\..\sskdockerz\ssh-key-2025-10-16.key"
if (-not (Test-Path $sshKeyPath)) {
    Write-Host "  ERREUR - Cle SSH introuvable: $sshKeyPath" -ForegroundColor Red
    exit 1
}
Write-Host "  OK - Cle SSH trouvee" -ForegroundColor Green

# Test de connexion avec Docker
Write-Host "[4/7] Test de connexion SSH..." -ForegroundColor Cyan
$testResult = docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible all -i inventory.ini --private-key=/ssh/ssh-key-2025-10-16.key -m ping" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Connexion SSH reussie!" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Connexion SSH echouee" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifiez:" -ForegroundColor Yellow
    Write-Host "  1. L'adresse IP: $ServerIP" -ForegroundColor White
    Write-Host "  2. L'utilisateur: $ServerUser" -ForegroundColor White
    Write-Host "  3. La cle SSH est autorisee sur le serveur" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Voulez-vous continuer quand meme? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Host "Deploiement annule" -ForegroundColor Yellow
        exit 1
    }
}

# Verification syntaxe
Write-Host "[5/7] Verification de la syntaxe du playbook..." -ForegroundColor Cyan
$syntaxCheck = docker run --rm `
    -v "${PWD}:/ansible" `
    -w /ansible `
    cytopia/ansible:latest `
    ansible-playbook deploy.yml --syntax-check 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Syntaxe validee" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Probleme de syntaxe" -ForegroundColor Red
    Write-Host $syntaxCheck
    exit 1
}

# Confirmation
Write-Host ""
Write-Host "[6/7] Pret pour le deploiement" -ForegroundColor Cyan
Write-Host ""
Write-Host "Le deploiement va:" -ForegroundColor Yellow
Write-Host "  - Installer Docker sur le serveur" -ForegroundColor White
Write-Host "  - Cloner le repository GitHub" -ForegroundColor White
Write-Host "  - Construire et lancer l'application" -ForegroundColor White
Write-Host ""
Write-Host "Duree estimee: 5-10 minutes" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Confirmer le deploiement? (o/N)"
if ($confirm -ne "o" -and $confirm -ne "O") {
    Write-Host "Deploiement annule" -ForegroundColor Yellow
    exit 0
}

# Deploiement
Write-Host ""
Write-Host "[7/7] Deploiement en cours via conteneur Ansible..." -ForegroundColor Green
Write-Host ""
Write-Host "Cela peut prendre 5-10 minutes..." -ForegroundColor Yellow
Write-Host ""

docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible-playbook -i inventory.ini deploy.yml --private-key=/ssh/ssh-key-2025-10-16.key -v"

# Resultat
Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host " DEPLOIEMENT REUSSI!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acces aux services:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Frontend:     http://$ServerIP:3000" -ForegroundColor White
    Write-Host "  Backend API:  http://$ServerIP:8001" -ForegroundColor White
    Write-Host "  Swagger:      http://$ServerIP:8001/docs" -ForegroundColor White
    Write-Host "  Prometheus:   http://$ServerIP:9090" -ForegroundColor White
    Write-Host "  Grafana:      http://$ServerIP:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Attendez 30-60 secondes que tout demarre..." -ForegroundColor Yellow
    Write-Host ""
    
    $openBrowser = Read-Host "Voulez-vous ouvrir le frontend dans le navigateur? (o/N)"
    if ($openBrowser -eq "o" -or $openBrowser -eq "O") {
        Start-Process "http://$ServerIP:3000"
    }
    
} else {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " ERREUR DE DEPLOIEMENT" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les logs ci-dessus pour plus de details." -ForegroundColor Yellow
    exit 1
}

