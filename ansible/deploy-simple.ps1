# Deploiement simplifie - directement en ligne de commande

$ServerIP = "141.253.118.141"
$ServerUser = "root"

Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " DEPLOIEMENT DOCKEZR - Version Simplifiee" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Serveur: $ServerIP" -ForegroundColor White
Write-Host "Utilisateur: $ServerUser" -ForegroundColor White
Write-Host ""

Write-Host "[1/2] Test de connexion SSH..." -ForegroundColor Cyan
docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    -e ANSIBLE_HOST_KEY_CHECKING=False `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible all -i '$ServerIP,' -u $ServerUser --private-key=/ssh/ssh-key-2025-10-16.key -m ping"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERREUR: Impossible de se connecter au serveur" -ForegroundColor Red
    Write-Host "Verifiez que le serveur $ServerIP est accessible" -ForegroundColor Yellow
    exit 1
}

Write-Host "  OK - Connexion reussie!" -ForegroundColor Green
Write-Host ""
Write-Host "[2/2] Lancement du deploiement Ansible..." -ForegroundColor Cyan
Write-Host ""
Write-Host "DEPLOIEMENT EN COURS..." -ForegroundColor Green
Write-Host "Cela va prendre 5-10 minutes" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

docker run --rm `
    -v "${PWD}:/ansible" `
    -v "${PWD}\..\..\sskdockerz:/ssh" `
    -w /ansible `
    -e ANSIBLE_HOST_KEY_CHECKING=False `
    cytopia/ansible:latest `
    sh -c "chmod 600 /ssh/ssh-key-2025-10-16.key && ansible-playbook deploy.yml -i '$ServerIP,' -u $ServerUser --private-key=/ssh/ssh-key-2025-10-16.key"

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
    Write-Host "NOTE: Les services prennent 30-60 secondes" -ForegroundColor Yellow
    Write-Host "      pour demarrer completement." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Ouverture du frontend dans le navigateur..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Start-Process "http://$ServerIP`:3000"
    
    Write-Host ""
    Write-Host "CAPTURES D'ECRAN POUR LE TP7:" -ForegroundColor Yellow
    Write-Host "  1. Cette fenetre PowerShell" -ForegroundColor White
    Write-Host "  2. http://$ServerIP`:3000" -ForegroundColor White
    Write-Host "  3. http://$ServerIP`:8001/docs" -ForegroundColor White
    Write-Host "  4. Connectez-vous en SSH et faites: docker ps" -ForegroundColor White
    Write-Host ""
    Write-Host "Commande SSH:" -ForegroundColor Cyan
    Write-Host "  ssh -i ..\..\sskdockerz\ssh-key-2025-10-16.key $ServerUser@$ServerIP" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host " ERREUR PENDANT LE DEPLOIEMENT" -ForegroundColor Red
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les messages d'erreur ci-dessus." -ForegroundColor Yellow
}

