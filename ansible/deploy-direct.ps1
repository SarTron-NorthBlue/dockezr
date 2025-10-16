# Deploiement direct via Docker avec inventaire cree dans le conteneur

$ServerIP = "141.253.118.141"
$ServerUser = "root"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT DOCKEZR - Methode Directe" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host "Utilisateur: $ServerUser" -ForegroundColor White
Write-Host ""
Write-Host "DEPLOIEMENT EN COURS..." -ForegroundColor Green
Write-Host "Duree estimee: 5-10 minutes" -ForegroundColor Yellow
Write-Host ""

# Script bash qui sera execute dans le conteneur
$bashScript = @"
#!/bin/sh
set -e

echo '=== Preparation de l inventaire ==='
cat > /tmp/hosts << 'EOF'
[production]
$ServerIP ansible_user=$ServerUser ansible_python_interpreter=/usr/bin/python3

[production:vars]
ansible_ssh_private_key_file=/ssh/ssh-key-2025-10-16.key
ansible_host_key_checking=False
EOF

echo '=== Configuration de la cle SSH ==='
chmod 600 /ssh/ssh-key-2025-10-16.key

echo '=== Test de connexion ==='
ansible -i /tmp/hosts all -m ping

echo '=== Execution du playbook ==='
ansible-playbook -i /tmp/hosts /ansible/deploy.yml -v
"@

# Sauvegarder le script bash
$bashScript | Out-File -FilePath "deploy-script.sh" -Encoding ASCII -NoNewline

Write-Host "Execution du deploiement Ansible..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -v "${PWD}\deploy-script.sh:/tmp/deploy.sh" `
    -w /ansible `
    -e ANSIBLE_HOST_KEY_CHECKING=False `
    cytopia/ansible:latest `
    sh /tmp/deploy.sh

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
    Write-Host "Patience: Les services prennent 30-60 secondes" -ForegroundColor Yellow
    Write-Host "          pour demarrer completement." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Ouverture du frontend dans le navigateur..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Start-Process "http://$ServerIP`:3000"
    
    Write-Host ""
    Write-Host "CAPTURES D'ECRAN POUR LE TP7:" -ForegroundColor Yellow
    Write-Host "  1. Cette fenetre PowerShell (deploiement reussi)" -ForegroundColor White
    Write-Host "  2. http://$ServerIP`:3000 (application web)" -ForegroundColor White
    Write-Host "  3. http://$ServerIP`:8001/docs (API Swagger)" -ForegroundColor White
    Write-Host "  4. SSH au serveur puis: docker ps" -ForegroundColor White
    Write-Host ""
    
    # Nettoyage
    Remove-Item "deploy-script.sh" -ErrorAction SilentlyContinue
    
} else {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " ERREUR PENDANT LE DEPLOIEMENT" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les messages d'erreur ci-dessus." -ForegroundColor Yellow
    Remove-Item "deploy-script.sh" -ErrorAction SilentlyContinue
}

