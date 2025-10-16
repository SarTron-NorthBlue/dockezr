# Script de pre-verification simplifie
param()

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " Pre-verification du Deploiement Ansible" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 1. Verifier WSL
Write-Host "[1/6] Verification de WSL..." -ForegroundColor Yellow
try {
    $wslCheck = wsl --list --verbose 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK - WSL installe" -ForegroundColor Green
    } else {
        Write-Host "  ERREUR - WSL non installe" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "  ERREUR - WSL non disponible" -ForegroundColor Red
    $allGood = $false
}

# 2. Verifier Ansible
Write-Host "[2/6] Verification d'Ansible..." -ForegroundColor Yellow
$ansibleCheck = wsl bash -c "which ansible" 2>&1
if ($LASTEXITCODE -eq 0) {
    $version = wsl bash -c "ansible --version | head -n1"
    Write-Host "  OK - Ansible installe: $version" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Ansible non installe dans WSL" -ForegroundColor Red
    Write-Host "    Commande: wsl bash -c 'sudo apt update && sudo apt install ansible -y'" -ForegroundColor Yellow
    $allGood = $false
}

# 3. Verifier les fichiers
Write-Host "[3/6] Verification des fichiers..." -ForegroundColor Yellow
$filesMissing = $false

if (Test-Path "deploy.yml") {
    Write-Host "  OK - deploy.yml" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - deploy.yml manquant" -ForegroundColor Red
    $filesMissing = $true
}

if (Test-Path "inventory.ini") {
    Write-Host "  OK - inventory.ini" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - inventory.ini manquant" -ForegroundColor Red
    $filesMissing = $true
}

if (Test-Path "group_vars\all.yml") {
    Write-Host "  OK - group_vars\all.yml" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - group_vars\all.yml manquant" -ForegroundColor Red
    $filesMissing = $true
}

if (Test-Path "..\..\sskdockerz\ssh-key-2025-10-16.key") {
    Write-Host "  OK - cle SSH trouvee" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - cle SSH manquante" -ForegroundColor Red
    $filesMissing = $true
}

if ($filesMissing) {
    $allGood = $false
}

# 4. Verifier l'inventaire
Write-Host "[4/6] Verification de l'inventaire..." -ForegroundColor Yellow
$inventoryContent = Get-Content "inventory.ini" -Raw
if ($inventoryContent -match "VOTRE_IP_SERVEUR") {
    Write-Host "  ATTENTION - L'inventaire n'est pas configure" -ForegroundColor Yellow
    Write-Host "    Editez inventory.ini et remplacez les valeurs" -ForegroundColor Yellow
    $allGood = $false
} else {
    Write-Host "  OK - Inventaire configure" -ForegroundColor Green
}

# 5. Verifier les variables
Write-Host "[5/6] Verification des variables..." -ForegroundColor Yellow
$varsContent = Get-Content "group_vars\all.yml" -Raw
if ($varsContent -match "VOTRE_USERNAME") {
    Write-Host "  ATTENTION - Variables non configurees" -ForegroundColor Yellow
    Write-Host "    Editez group_vars/all.yml" -ForegroundColor Yellow
    $allGood = $false
} else {
    Write-Host "  OK - Variables configurees" -ForegroundColor Green
}

# 6. Test de syntaxe
Write-Host "[6/6] Verification de la syntaxe YAML..." -ForegroundColor Yellow
$wslPath = wsl wslpath -a "$PWD"
$syntaxCheck = wsl bash -c "cd '$wslPath'; ansible-playbook deploy.yml --syntax-check" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Syntaxe du playbook valide" -ForegroundColor Green
} else {
    Write-Host "  ERREUR - Erreur de syntaxe dans le playbook" -ForegroundColor Red
    Write-Host $syntaxCheck
    $allGood = $false
}

# Resultat
Write-Host ""
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($allGood) {
    Write-Host " TOUTES LES VERIFICATIONS SONT PASSEES!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous etes pret a deployer!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Pour deployer avec configuration interactive:" -ForegroundColor Yellow
    Write-Host "  .\deploy-interactive.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host " CERTAINES VERIFICATIONS ONT ECHOUE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Corrigez les problemes ci-dessus avant de deployer." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

