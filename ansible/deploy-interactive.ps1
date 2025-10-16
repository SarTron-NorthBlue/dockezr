# Script de deploiement interactif simplifie
param(
    [string]$ServerIP = "",
    [string]$ServerUser = ""
)

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " Deploiement Ansible - DockeZR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Demander les informations si non fournies
if ($ServerIP -eq "") {
    $ServerIP = Read-Host "Entrez l'adresse IP du serveur"
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
Write-Host "[1/6] Configuration de l'inventaire..." -ForegroundColor Cyan
$inventoryContent = @"
# Inventaire Ansible - Configure automatiquement

[production]
server ansible_host=$ServerIP ansible_user=$ServerUser ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key

[production:vars]
ansible_python_interpreter=/usr/bin/python3
"@

Set-Content -Path "inventory.ini" -Value $inventoryContent -Encoding UTF8
Write-Host "  OK - Inventaire cree" -ForegroundColor Green

# Configurer les permissions SSH
Write-Host "[2/6] Configuration de la cle SSH..." -ForegroundColor Cyan
$wslKeyPath = wsl wslpath -a "$PWD\..\..\sskdockerz\ssh-key-2025-10-16.key"
wsl chmod 600 "$wslKeyPath"
Write-Host "  OK - Permissions configurees" -ForegroundColor Green

# Test de connexion
Write-Host "[3/6] Test de connexion SSH..." -ForegroundColor Cyan
$wslPath = wsl wslpath -a "$PWD"
$pingResult = wsl bash -c "cd '$wslPath'; ansible all -i inventory.ini -m ping" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Connexion SSH reussie!" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Connexion SSH echouee" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifiez:" -ForegroundColor Yellow
    Write-Host "  1. L'adresse IP: $ServerIP" -ForegroundColor White
    Write-Host "  2. L'utilisateur: $ServerUser" -ForegroundColor White
    Write-Host "  3. La cle SSH est valide" -ForegroundColor White
    Write-Host "  4. Le serveur est accessible" -ForegroundColor White
    Write-Host ""
    
    $continue = Read-Host "Voulez-vous continuer quand meme? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Host "Deploiement annule" -ForegroundColor Yellow
        exit 1
    }
}

# Verification syntaxe
Write-Host "[4/6] Verification de la syntaxe..." -ForegroundColor Cyan
$syntaxCheck = wsl bash -c "cd '$wslPath'; ansible-playbook deploy.yml --syntax-check" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Syntaxe validee" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Probleme de syntaxe" -ForegroundColor Red
    Write-Host $syntaxCheck
    exit 1
}

# Confirmation
Write-Host ""
Write-Host "[5/6] Pret pour le deploiement" -ForegroundColor Cyan
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
Write-Host "[6/6] Deploiement en cours..." -ForegroundColor Green
Write-Host ""

wsl bash -c "cd '$wslPath'; ansible-playbook -i inventory.ini deploy.yml"

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
    
    # Ouvrir le navigateur
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

