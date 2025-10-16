# Script pour ouvrir les ports du pare-feu sur la VM Oracle

$ServerIP = "141.253.118.141"

Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " OUVERTURE DES PORTS DU PARE-FEU" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Configuration du pare-feu sur le serveur...`n" -ForegroundColor Yellow

docker run --rm -v "${PWD}\..\sskdockerz:/ssh" willhallonline/ansible:latest sh -c 'chmod 600 /ssh/ssh-key-2025-10-16.key; ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 "iptables -I INPUT 6 -m state --state NEW -p tcp --dport 3000 -j ACCEPT && iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8001 -j ACCEPT && iptables -I INPUT 6 -m state --state NEW -p tcp --dport 9090 -j ACCEPT && iptables -I INPUT 6 -m state --state NEW -p tcp --dport 3001 -j ACCEPT && netfilter-persistent save"'

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nOK - Ports ouverts dans le pare-feu de la VM`n" -ForegroundColor Green
} else {
    Write-Host "`nERREUR - Probleme avec le pare-feu`n" -ForegroundColor Red
}

Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "Ports ouverts:" -ForegroundColor Green
Write-Host "  - 3000 (Frontend)" -ForegroundColor White
Write-Host "  - 8001 (Backend API)" -ForegroundColor White
Write-Host "  - 9090 (Prometheus)" -ForegroundColor White
Write-Host "  - 3001 (Grafana)`n" -ForegroundColor White

Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "Vous devez AUSSI ouvrir ces ports dans Oracle Cloud:" -ForegroundColor Yellow
Write-Host "  1. Allez sur cloud.oracle.com" -ForegroundColor White
Write-Host "  2. Compute > Instances > Votre VM" -ForegroundColor White
Write-Host "  3. Subnet > Security List" -ForegroundColor White
Write-Host "  4. Add Ingress Rules pour les ports 3000, 8001, 9090, 3001`n" -ForegroundColor White

Write-Host "Apres avoir ouvert les ports Oracle Cloud, testez:" -ForegroundColor Cyan
Write-Host "  http://$ServerIP`:3000`n" -ForegroundColor White

