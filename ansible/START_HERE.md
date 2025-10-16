# 🚀 COMMENCEZ ICI - Déploiement Ansible DockeZR

## ✅ Résultat du Diagnostic

Voici ce qui a été créé pour vous:

### 📁 Fichiers Créés

✓ **deploy.yml** - Playbook Ansible principal (commenté)
✓ **inventory.ini** - Configuration des serveurs  
✓ **group_vars/all.yml** - Variables de configuration
✓ **templates/env.prod.j2** - Template d'environnement
✓ **ansible.cfg** - Configuration Ansible
✓ **deploy-interactive.ps1** - Script de déploiement automatique
✓ **test-prereqs.ps1** - Script de vérification
✓ **README.md** - Documentation complète
✓ **GUIDE_EXECUTION.md** - Guide détaillé
✓ **QUICK_START.md** - Guide rapide

---

## 🎯 Actions Requises (5 ÉTAPES)

### Étape 1: Installer WSL avec Ubuntu (SI PAS DÉJÀ FAIT)

```powershell
# Dans PowerShell en administrateur:
wsl --install -d Ubuntu

# Redémarrer Windows après installation
# Au redémarrage, Ubuntu s'ouvrira et vous demandera de créer un utilisateur
```

### Étape 2: Installer Ansible dans WSL

```powershell
# Dans PowerShell normal:
wsl

# Une fois dans WSL Ubuntu:
sudo apt update
sudo apt install ansible git -y
ansible --version

# Pour sortir de WSL:
exit
```

### Étape 3: Configurer l'Inventaire

Vous devez modifier `inventory.ini` avec les informations de votre serveur:

```ini
[production]
server ansible_host=VOTRE_IP_SERVEUR ansible_user=VOTRE_USER ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key
```

**Remplacez:**
- `VOTRE_IP_SERVEUR` → L'adresse IP de votre serveur (ex: 192.168.1.100)
- `VOTRE_USER` → Votre utilisateur SSH (ex: ubuntu, root, debian)

**Exemple:**
```ini
[production]
server ansible_host=192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key
```

### Étape 4: Configurer les Variables

Éditez `group_vars\all.yml`:

```yaml
# Ligne 4: URL de votre repository
project_repo: "https://github.com/VOTRE_USERNAME/dockezr.git"

# Ligne 18: Mot de passe PostgreSQL (IMPORTANT!)
postgres_password: "VotreMotDePasseSecurise2024!"

# Ligne 24: Mot de passe Grafana (IMPORTANT!)
grafana_admin_password: "AdminGrafana2024!"
```

### Étape 5: Lancer le Déploiement

```powershell
# Option A: Script interactif (RECOMMANDÉ)
.\deploy-interactive.ps1

# Le script vous demandera l'IP et l'utilisateur
# Puis déploiera automatiquement
```

---

## 🎬 Commandes Rapides

### Vérifier les Prérequis

```powershell
.\test-prereqs.ps1
```

### Déployer avec Configuration Interactive

```powershell
.\deploy-interactive.ps1
```

### Déployer Directement (après configuration manuelle)

```powershell
# Dans PowerShell, depuis le dossier ansible/
$wslPath = wsl wslpath -a "$PWD"
wsl bash -c "cd '$wslPath'; ansible-playbook -i inventory.ini deploy.yml"
```

### Tester la Connexion SSH

```powershell
$wslPath = wsl wslpath -a "$PWD"
wsl bash -c "cd '$wslPath'; ansible all -i inventory.ini -m ping"
```

---

## 📊 Ce que le Playbook Fait

1. ✅ **Mise à jour du système** Linux
2. ✅ **Installation de Docker** + Docker Compose
3. ✅ **Configuration des permissions** utilisateur
4. ✅ **Clonage du repository** GitHub
5. ✅ **Configuration** des variables d'environnement
6. ✅ **Construction** des images Docker
7. ✅ **Lancement** de tous les services
8. ✅ **Vérification** et affichage des logs

**Durée totale: 5-10 minutes**

---

## 🌐 Accès aux Services

Après déploiement réussi, accédez à:

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://VOTRE_IP:3000 | Interface de réservation |
| **Backend** | http://VOTRE_IP:8001 | API REST |
| **Swagger** | http://VOTRE_IP:8001/docs | Documentation API interactive |
| **Prometheus** | http://VOTRE_IP:9090 | Monitoring |
| **Grafana** | http://VOTRE_IP:3001 | Tableaux de bord (admin/votre_mdp) |

---

## 📸 Captures d'Écran pour le Livrable TP7

### 1. Exécution du Playbook

```powershell
.\deploy-interactive.ps1
```

📸 **Capturez** le terminal montrant "DEPLOIEMENT REUSSI!"

### 2. État des Conteneurs

```powershell
# Se connecter au serveur
ssh -i ..\..\sskdockerz\ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP

# Sur le serveur
docker ps
```

📸 **Capturez** la liste des conteneurs running

### 3. Application Web

Ouvrez dans votre navigateur:
- http://VOTRE_IP:3000
- http://VOTRE_IP:8001/docs

📸 **Capturez** les pages web

---

## 🐛 Problèmes Courants

### Problème: "Ansible non installé"

**Solution:**
```powershell
wsl
sudo apt update && sudo apt install ansible -y
exit
```

### Problème: "Permission denied (publickey)"

**Solution:**
```powershell
# Configurer les permissions de la clé
$wslKeyPath = wsl wslpath -a "$PWD\..\..\sskdockerz\ssh-key-2025-10-16.key"
wsl chmod 600 "$wslKeyPath"

# Tester la connexion manuelle
wsl ssh -i $wslKeyPath VOTRE_USER@VOTRE_IP
```

### Problème: "bash: not found"

**Solution:** WSL Ubuntu n'est pas installé correctement

```powershell
# Réinstaller Ubuntu
wsl --unregister Ubuntu
wsl --install -d Ubuntu
```

### Problème: "Host unreachable"

**Solution:**
1. Vérifiez que le serveur est allumé
2. Vérifiez l'adresse IP dans `inventory.ini`
3. Testez: `ping VOTRE_IP`
4. Vérifiez que le port SSH (22) est ouvert

---

## 📚 Documentation Complète

- **QUICK_START.md** - Guide rapide 5 minutes
- **GUIDE_EXECUTION.md** - Guide détaillé pas à pas
- **README.md** - Documentation complète Ansible
- **deploy.yml** - Playbook commenté (pour le livrable)

---

## ✅ Checklist Livrable TP7

Pour valider le TP7, vous devez fournir:

- [x] **deploy.yml** commenté (✅ déjà fait)
- [ ] **inventory.ini** configuré avec votre serveur
- [ ] **group_vars/all.yml** configuré
- [ ] **Capture d'écran**: Exécution réussie du playbook
- [ ] **Capture d'écran**: docker ps sur le serveur
- [ ] **Capture d'écran**: Application web accessible
- [ ] **Documentation**: Ce dossier ansible/ complet

---

## 🎓 Résumé de l'Architecture

```
┌─────────────────────────────────────────────┐
│  Votre Machine (Windows)                    │
│  ├── WSL (Ubuntu)                           │
│  │   └── Ansible                            │
│  └── Scripts PowerShell                     │
└──────────────┬──────────────────────────────┘
               │ SSH
               ▼
┌─────────────────────────────────────────────┐
│  Serveur Linux                              │
│  ├── Docker Engine                          │
│  ├── DockeZR Repository (cloné)             │
│  └── Conteneurs:                            │
│      ├── PostgreSQL (db)                    │
│      ├── FastAPI (backend)                  │
│      ├── Next.js (frontend)                 │
│      ├── Prometheus                         │
│      └── Grafana                            │
└─────────────────────────────────────────────┘
```

---

## 💡 Prochaines Étapes Après Déploiement

1. **Tester l'application** - http://VOTRE_IP:3000
2. **Créer quelques réservations** de test
3. **Vérifier les logs** - `docker compose logs -f`
4. **Configurer Grafana** - Créer des dashboards
5. **Sauvegardes** - Mettre en place des backups DB
6. **Sécurité** - Configurer un pare-feu
7. **HTTPS** - Configurer SSL/TLS avec Let's Encrypt

---

## 🆘 Besoin d'Aide ?

Si vous rencontrez des problèmes:

1. **Lancez le diagnostic**: `.\test-prereqs.ps1`
2. **Lisez les logs**: Les messages d'erreur sont explicites
3. **Consultez GUIDE_EXECUTION.md**: Guide détaillé
4. **Vérifiez la connectivité**: `ping VOTRE_IP`

---

**Vous êtes prêt ! Bonne chance avec votre déploiement ! 🚀**

*Créé automatiquement pour le TP7 - OPERATE*

