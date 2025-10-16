# Verifier les conteneurs sur le serveur

$ServerIP = "141.253.118.141"

Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " VERIFICATION DES CONTENEURS SUR LE SERVEUR" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════`n" -ForegroundColor Cyan

docker run --rm -v "${PWD}\..\sskdockerz:/ssh" willhallonline/ansible:latest sh -c 'chmod 600 /ssh/ssh-key-2025-10-16.key && ssh -o StrictHostKeyChecking=no -i /ssh/ssh-key-2025-10-16.key root@141.253.118.141 "docker ps"'

Write-Host "`n════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Vos services sont accessibles a:`n" -ForegroundColor Green
Write-Host "  Frontend:     http://$ServerIP`:3000" -ForegroundColor White
Write-Host "  Backend API:  http://$ServerIP`:8001" -ForegroundColor White
Write-Host "  Swagger:      http://$ServerIP`:8001/docs" -ForegroundColor White
Write-Host "  Prometheus:   http://$ServerIP`:9090" -ForegroundColor White
Write-Host "  Grafana:      http://$ServerIP`:3001`n" -ForegroundColor White

