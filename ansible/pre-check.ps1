# Script de pré-vérification avant déploiement
# Vérifie que tout est prêt pour le déploiement Ansible

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Pré-vérification du Déploiement Ansible         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# 1. Vérifier WSL
Write-Host "[1/7] Vérification de WSL..." -ForegroundColor Yellow
try {
    $wslCheck = wsl --list --verbose 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ WSL installé" -ForegroundColor Green
    } else {
        Write-Host "  ✗ WSL non installé" -ForegroundColor Red
        Write-Host "    Installer avec: wsl --install" -ForegroundColor Yellow
        $allGood = $false
    }
} catch {
    Write-Host "  ✗ WSL non disponible" -ForegroundColor Red
    $allGood = $false
}

# 2. Vérifier Ansible
Write-Host "[2/7] Vérification d'Ansible..." -ForegroundColor Yellow
$ansibleCheck = wsl bash -c "which ansible" 2>&1
if ($LASTEXITCODE -eq 0) {
    $version = wsl bash -c "ansible --version | head -n1"
    Write-Host "  ✓ Ansible installé: $version" -ForegroundColor Green
} else {
    Write-Host "  ✗ Ansible non installé dans WSL" -ForegroundColor Red
    Write-Host "    Installer avec: wsl bash -c 'sudo apt update && sudo apt install ansible -y'" -ForegroundColor Yellow
    $allGood = $false
}

# 3. Vérifier les fichiers
Write-Host "[3/7] Vérification des fichiers..." -ForegroundColor Yellow
$files = @(
    "deploy.yml",
    "inventory.ini",
    "group_vars\all.yml",
    "templates\env.prod.j2",
    "..\..\sskdockerz\ssh-key-2025-10-16.key"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file manquant" -ForegroundColor Red
        $allGood = $false
    }
}

# 4. Vérifier la configuration de l'inventaire
Write-Host "[4/7] Vérification de l'inventaire..." -ForegroundColor Yellow
$inventoryContent = Get-Content "inventory.ini" -Raw
if ($inventoryContent -match "VOTRE_IP_SERVEUR") {
    Write-Host "  ⚠ L'inventaire n'est pas configuré (contient VOTRE_IP_SERVEUR)" -ForegroundColor Yellow
    Write-Host "    Éditez inventory.ini et remplacez les valeurs" -ForegroundColor Yellow
    $allGood = $false
} else {
    Write-Host "  ✓ Inventaire configuré" -ForegroundColor Green
}

# 5. Vérifier la configuration des variables
Write-Host "[5/7] Vérification des variables..." -ForegroundColor Yellow
$varsContent = Get-Content "group_vars\all.yml" -Raw
if ($varsContent -match "VOTRE_USERNAME") {
    Write-Host "  ⚠ Les variables ne sont pas configurées (contient VOTRE_USERNAME)" -ForegroundColor Yellow
    Write-Host "    Éditez group_vars/all.yml et remplacez project_repo" -ForegroundColor Yellow
    $allGood = $false
} else {
    Write-Host "  ✓ Variables configurées" -ForegroundColor Green
}

if ($varsContent -match "changez_ce_mot_de_passe") {
    Write-Host "  ⚠ Les mots de passe par défaut sont toujours présents" -ForegroundColor Yellow
    Write-Host "    Changez-les dans group_vars/all.yml pour la production" -ForegroundColor Yellow
}

# 6. Vérifier la syntaxe YAML
Write-Host "[6/7] Vérification de la syntaxe YAML..." -ForegroundColor Yellow
$wslPath = wsl wslpath -a "$PWD"
$syntaxCheck = wsl bash -c "cd '$wslPath' && ansible-playbook deploy.yml --syntax-check" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Syntaxe du playbook valide" -ForegroundColor Green
} else {
    Write-Host "  ✗ Erreur de syntaxe dans le playbook" -ForegroundColor Red
    Write-Host $syntaxCheck
    $allGood = $false
}

# 7. Test de connexion (optionnel)
Write-Host "[7/7] Test de connexion SSH..." -ForegroundColor Yellow
if ($inventoryContent -notmatch "VOTRE_IP_SERVEUR") {
    $pingResult = wsl bash -c "cd '$wslPath'; timeout 10 ansible all -i inventory.ini -m ping" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Connexion SSH réussie!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Impossible de se connecter au serveur" -ForegroundColor Red
        Write-Host "    Vérifiez l'IP, le user et la clé SSH" -ForegroundColor Yellow
        $allGood = $false
    }
} else {
    Write-Host "  - Test ignoré (inventaire non configuré)" -ForegroundColor Gray
}

# Résumé
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✓ TOUTES LES VÉRIFICATIONS SONT PASSÉES!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous êtes prêt à déployer!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Lancez le déploiement avec:" -ForegroundColor Yellow
    Write-Host "  .\deploy-auto.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou en mode test:" -ForegroundColor Yellow
    Write-Host "  .\deploy-auto.ps1 -TestMode" -ForegroundColor White
} else {
    Write-Host "✗ CERTAINES VÉRIFICATIONS ONT ÉCHOUÉ" -ForegroundColor Red
    Write-Host ""
    Write-Host "Corrigez les problèmes ci-dessus avant de déployer." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Besoin d'aide ? Consultez:" -ForegroundColor Yellow
    Write-Host "  - QUICK_START.md" -ForegroundColor White
    Write-Host "  - GUIDE_EXECUTION.md" -ForegroundColor White
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

