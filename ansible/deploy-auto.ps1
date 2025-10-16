# Script PowerShell d'automatisation complète du déploiement Ansible
# Exécute toutes les étapes automatiquement

param(
    [string]$ServerIP = "",
    [string]$ServerUser = "",
    [switch]$TestMode = $false
)

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Déploiement Automatisé DockeZR via Ansible         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Fonction pour afficher les messages colorés
function Write-Step {
    param([string]$Message, [string]$Color = "Green")
    Write-Host "→ $Message" -ForegroundColor $Color
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

# Étape 1: Vérifier WSL
Write-Step "Étape 1/8: Vérification de WSL..." "Cyan"
try {
    $wslCheck = wsl --list --verbose 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "WSL est installé"
    } else {
        Write-Error-Custom "WSL n'est pas installé. Installation requise..."
        Write-Host "Commande: wsl --install" -ForegroundColor Yellow
        Write-Host "Redémarrage requis après installation" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Error-Custom "Impossible de vérifier WSL"
    exit 1
}

# Étape 2: Vérifier Ansible dans WSL
Write-Step "Étape 2/8: Vérification d'Ansible dans WSL..." "Cyan"
$ansibleCheck = wsl bash -c "which ansible" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Step "Installation d'Ansible dans WSL..." "Yellow"
    wsl bash -c "sudo apt update && sudo apt install -y ansible"
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Ansible installé avec succès"
    } else {
        Write-Error-Custom "Échec de l'installation d'Ansible"
        exit 1
    }
} else {
    $ansibleVersion = wsl bash -c "ansible --version | head -n1"
    Write-Success "Ansible est installé: $ansibleVersion"
}

# Étape 3: Configuration de l'inventaire
Write-Step "Étape 3/8: Configuration de l'inventaire..." "Cyan"

if ($ServerIP -eq "" -or $ServerUser -eq "") {
    Write-Host ""
    Write-Host "Configuration du serveur:" -ForegroundColor Yellow
    if ($ServerIP -eq "") {
        $ServerIP = Read-Host "Entrez l'adresse IP du serveur"
    }
    if ($ServerUser -eq "") {
        $ServerUser = Read-Host "Entrez le nom d'utilisateur SSH"
    }
}

# Créer l'inventaire configuré
$inventoryContent = @"
# Inventaire Ansible pour le déploiement DockeZR - Configuré automatiquement

[production]
server ansible_host=$ServerIP ansible_user=$ServerUser ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key

[production:vars]
ansible_python_interpreter=/usr/bin/python3
"@

Set-Content -Path "inventory.ini" -Value $inventoryContent -Encoding UTF8
Write-Success "Inventaire configuré avec IP: $ServerIP et User: $ServerUser"

# Étape 4: Vérifier la clé SSH
Write-Step "Étape 4/8: Vérification de la clé SSH..." "Cyan"
$sshKeyPath = "..\..\sskdockerz\ssh-key-2025-10-16.key"
if (Test-Path $sshKeyPath) {
    Write-Success "Clé SSH trouvée"
    # Configurer les permissions dans WSL
    $wslKeyPath = wsl wslpath -a "$PWD\..\..\sskdockerz\ssh-key-2025-10-16.key"
    wsl chmod 600 "$wslKeyPath"
    Write-Success "Permissions de la clé SSH configurées"
} else {
    Write-Error-Custom "Clé SSH introuvable: $sshKeyPath"
    exit 1
}

# Étape 5: Test de connexion SSH
Write-Step "Étape 5/8: Test de connexion au serveur..." "Cyan"
$wslPath = wsl wslpath -a "$PWD"
$pingResult = wsl bash -c "cd '$wslPath'; ansible all -i inventory.ini -m ping" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Connexion SSH réussie!"
} else {
    Write-Error-Custom "Échec de la connexion SSH"
    Write-Host "Résultat:" -ForegroundColor Yellow
    Write-Host $pingResult
    Write-Host ""
    Write-Host "Vérifiez:" -ForegroundColor Yellow
    Write-Host "  1. L'adresse IP est correcte: $ServerIP" -ForegroundColor Yellow
    Write-Host "  2. Le serveur est accessible" -ForegroundColor Yellow
    Write-Host "  3. La clé SSH est valide" -ForegroundColor Yellow
    Write-Host "  4. L'utilisateur '$ServerUser' existe sur le serveur" -ForegroundColor Yellow
    
    $continue = Read-Host "Voulez-vous continuer quand même? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        exit 1
    }
}

# Étape 6: Vérification de la syntaxe du playbook
Write-Step "Étape 6/8: Vérification de la syntaxe du playbook..." "Cyan"
$syntaxCheck = wsl bash -c "cd '$wslPath'; ansible-playbook deploy.yml --syntax-check" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Syntaxe du playbook validée"
} else {
    Write-Error-Custom "Erreur de syntaxe dans le playbook"
    Write-Host $syntaxCheck
    exit 1
}

# Étape 7: Mode test ou déploiement réel
if ($TestMode) {
    Write-Step "Étape 7/8: Mode TEST - Simulation du déploiement..." "Yellow"
    Write-Host ""
    Write-Host "Mode test activé. Exécution avec --check (dry-run)" -ForegroundColor Yellow
    wsl bash -c "cd '$wslPath'; ansible-playbook -i inventory.ini deploy.yml --check -v"
} else {
    Write-Step "Étape 7/8: Lancement du déploiement RÉEL..." "Cyan"
    Write-Host ""
    Write-Host "⚠️  ATTENTION: Le déploiement va maintenant commencer!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Cela va:" -ForegroundColor White
    Write-Host "  - Installer Docker sur le serveur" -ForegroundColor White
    Write-Host "  - Cloner le repository" -ForegroundColor White
    Write-Host "  - Construire et démarrer les conteneurs" -ForegroundColor White
    Write-Host ""
    
    $confirm = Read-Host "Confirmer le déploiement? (o/N)"
    if ($confirm -ne "o" -and $confirm -ne "O") {
        Write-Host "Déploiement annulé" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "🚀 Déploiement en cours... (cela peut prendre 5-10 minutes)" -ForegroundColor Green
    Write-Host ""
    
    wsl bash -c "cd '$wslPath'; ansible-playbook -i inventory.ini deploy.yml -v"
}

# Étape 8: Résultats et vérifications
Write-Host ""
Write-Step "Étape 8/8: Vérifications finales..." "Cyan"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║          ✓ DÉPLOIEMENT RÉUSSI !                     ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Accès aux services:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Frontend:     http://$ServerIP:3000" -ForegroundColor White
    Write-Host "   Backend API:  http://$ServerIP:8001" -ForegroundColor White
    Write-Host "   Swagger Docs: http://$ServerIP:8001/docs" -ForegroundColor White
    Write-Host "   Prometheus:   http://$ServerIP:9090" -ForegroundColor White
    Write-Host "   Grafana:      http://$ServerIP:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "📝 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. Ouvrir http://$ServerIP:3000 dans votre navigateur" -ForegroundColor White
    Write-Host "   2. Tester l'API: http://$ServerIP:8001/docs" -ForegroundColor White
    Write-Host "   3. Prendre des captures d'écran pour le livrable" -ForegroundColor White
    Write-Host ""
    
    # Test rapide des URLs
    Write-Step "Test de connectivité aux services..." "Cyan"
    try {
        $frontendTest = Invoke-WebRequest -Uri "http://$ServerIP:3000" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($frontendTest.StatusCode -eq 200) {
            Write-Success "Frontend accessible ✓"
        }
    } catch {
        Write-Host "  Frontend: En attente de démarrage..." -ForegroundColor Yellow
    }
    
    try {
        $backendTest = Invoke-WebRequest -Uri "http://$ServerIP:8001/docs" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($backendTest.StatusCode -eq 200) {
            Write-Success "Backend API accessible ✓"
        }
    } catch {
        Write-Host "  Backend: En attente de démarrage..." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Attendez 30-60 secondes que tous les services démarrent complètement." -ForegroundColor Yellow
    
} else {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║          ✗ ERREUR DE DÉPLOIEMENT                    ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les logs ci-dessus pour plus de détails." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commandes de diagnostic:" -ForegroundColor Yellow
    Write-Host "  - Voir les logs Ansible: cat ansible.log" -ForegroundColor White
    Write-Host "  - SSH au serveur: ssh -i ../../sskdockerz/ssh-key-2025-10-16.key $ServerUser@$ServerIP" -ForegroundColor White
    Write-Host "  - Voir les conteneurs: docker ps" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Script terminé!" -ForegroundColor Cyan

