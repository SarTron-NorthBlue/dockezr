# Deploiement automatique SANS confirmation
# Lance directement le deploiement

$ServerIP = "141.253.118.141"
$ServerUser = "root"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT AUTOMATIQUE - DockeZR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host "Utilisateur: $ServerUser" -ForegroundColor White
Write-Host ""
Write-Host "DEPLOIEMENT EN COURS..." -ForegroundColor Green
Write-Host "Cela peut prendre 5-10 minutes" -ForegroundColor Yellow
Write-Host ""

# Configurer l'inventaire
$inventoryContent = @"
[production]
server ansible_host=$ServerIP ansible_user=$ServerUser ansible_ssh_private_key_file=/ssh/ssh-key-2025-10-16.key

[production:vars]
ansible_python_interpreter=/usr/bin/python3
"@

Set-Content -Path "inventory.ini" -Value $inventoryContent -Encoding UTF8

# Lancer le deploiement avec Docker
Write-Host "Execution du playbook Ansible..." -ForegroundColor Cyan
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
    Write-Host "Vos services sont maintenant accessibles:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Frontend:     http://$ServerIP`:3000" -ForegroundColor White
    Write-Host "  Backend API:  http://$ServerIP`:8001" -ForegroundColor White
    Write-Host "  Swagger:      http://$ServerIP`:8001/docs" -ForegroundColor White
    Write-Host "  Prometheus:   http://$ServerIP`:9090" -ForegroundColor White
    Write-Host "  Grafana:      http://$ServerIP`:3001" -ForegroundColor White
    Write-Host ""
    Write-Host "Attendez 30-60 secondes que tous les services demarrent" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ouverture du frontend dans le navigateur..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Start-Process "http://$ServerIP`:3000"
} else {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " ERREUR DE DEPLOIEMENT" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les logs ci-dessus" -ForegroundColor Yellow
}

