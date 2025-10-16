# 📘 Guide d'Exécution - Déploiement Ansible

## 🎯 Objectif

Ce guide vous accompagne pas à pas dans l'exécution du playbook Ansible pour déployer DockeZR sur votre serveur.

---

## 📝 Checklist Pré-Déploiement

Avant de commencer, assurez-vous d'avoir:

- [ ] Un serveur Linux accessible (Ubuntu 20.04+ recommandé)
- [ ] L'adresse IP de votre serveur
- [ ] Un accès SSH avec la clé privée `ssh-key-2025-10-16.key`
- [ ] Un utilisateur avec droits sudo sur le serveur
- [ ] Ansible installé sur votre machine locale
- [ ] Modifié le fichier `inventory.ini` avec vos informations
- [ ] Configuré les variables dans `group_vars/all.yml`
- [ ] Changé les mots de passe par défaut

---

## 🔧 Configuration Étape par Étape

### Étape 1: Installer Ansible (sur Windows via WSL)

```bash
# Ouvrir PowerShell en administrateur
wsl --install

# Redémarrer l'ordinateur si nécessaire

# Ouvrir Ubuntu WSL
# Mettre à jour et installer Ansible
sudo apt update
sudo apt install ansible git -y

# Vérifier l'installation
ansible --version
```

### Étape 2: Naviguer vers le dossier Ansible

```bash
# Dans WSL, aller dans le projet
cd /mnt/c/Users/lou/Documents/Projet/dockeer/dockezr/ansible
```

### Étape 3: Configurer l'inventaire

```bash
# Éditer le fichier inventory.ini
nano inventory.ini
```

Remplacez les valeurs:
```ini
[production]
server ansible_host=192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key
```

**Exemple avec vos valeurs:**
- `ansible_host`: L'IP de votre serveur (ex: 192.168.1.100)
- `ansible_user`: Votre utilisateur SSH (ex: ubuntu, debian, root)
- `ansible_ssh_private_key_file`: Chemin vers votre clé SSH

### Étape 4: Configurer les variables

```bash
# Éditer les variables
nano group_vars/all.yml
```

Modifiez au minimum:
```yaml
# URL de votre repository GitHub (si vous avez pushé le code)
project_repo: "https://github.com/VOTRE_USERNAME/dockezr.git"

# Mots de passe IMPORTANTS à changer!
postgres_password: "VotreMotDePasse2024!"
grafana_admin_password: "AdminGrafana2024!"
```

### Étape 5: Configurer les permissions SSH

```bash
# Donner les bonnes permissions à la clé SSH
chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key
```

---

## 🚀 Exécution du Déploiement

### Test de Connexion (OBLIGATOIRE)

Avant de déployer, testez la connexion:

```bash
ansible all -i inventory.ini -m ping
```

**Résultat attendu:**
```
server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

✅ **Si vous voyez "SUCCESS"**, continuez!

❌ **Si vous voyez une erreur**, vérifiez:
- L'adresse IP est correcte
- Le serveur est allumé et accessible
- La clé SSH est valide
- Les permissions de la clé: `ls -la ../../sskdockerz/`

### Déploiement Complet

**Option A: Via le script automatique (recommandé)**

```bash
# Rendre le script exécutable
chmod +x deploy.sh

# Lancer le script
./deploy.sh
```

Le script vous guidera avec un menu interactif.

**Option B: Commande directe**

```bash
# Déploiement complet
ansible-playbook -i inventory.ini deploy.yml

# Avec affichage détaillé (utile pour le debug)
ansible-playbook -i inventory.ini deploy.yml -v
```

### Sortie Attendue

Vous verrez 10 étapes s'exécuter:

```
PLAY [Déploiement automatisé de DockeZR sur serveur Linux] ******************

TASK [Gathering Facts] *******************************************************
ok: [server]

TASK [[1/10] 🔄 Mise à jour du cache APT] ***********************************
ok: [server]

TASK [[2/10] 🐳 Vérification si Docker est déjà installé] *******************
ok: [server]

...

TASK [✅ Déploiement terminé avec succès!] ***********************************
ok: [server] => {
    "msg": [
        "🎉 L'application DockeZR a été déployée avec succès!",
        "",
        "🌐 Accès aux services:",
        "   - Frontend:    http://192.168.1.100:3000",
        "   - Backend API: http://192.168.1.100:8001",
        ...
    ]
}

PLAY RECAP *******************************************************************
server : ok=25   changed=8    unreachable=0    failed=0    skipped=3
```

---

## 🌐 Vérification du Déploiement

### 1. Vérifier les Services Web

Ouvrez votre navigateur et testez:

- **Frontend**: http://VOTRE_IP:3000
  - Vous devriez voir l'interface de réservation
  
- **API Swagger**: http://VOTRE_IP:8001/docs
  - Documentation interactive de l'API
  
- **Grafana**: http://VOTRE_IP:3001
  - Login: admin / votre_mot_de_passe_grafana

### 2. Vérifier sur le Serveur

Connectez-vous en SSH:

```bash
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP
```

Puis vérifiez:

```bash
# Vérifier que Docker est installé
docker --version

# Voir les conteneurs en cours d'exécution
docker ps

# Aller dans le répertoire du projet
cd /opt/dockezr

# Voir l'état détaillé
docker compose -f docker-compose.prod.yml ps

# Voir les logs
docker compose -f docker-compose.prod.yml logs -f
```

### 3. Tester l'API

```bash
# Test simple depuis votre machine
curl http://VOTRE_IP:8001/

# Lister les salles
curl http://VOTRE_IP:8001/rooms

# Lister les réservations
curl http://VOTRE_IP:8001/reservations
```

---

## 📸 Captures d'Écran

### Pour le Livrable TP7

Prenez des captures d'écran de:

1. **Exécution du playbook**:
   ```bash
   ansible-playbook -i inventory.ini deploy.yml
   ```
   Capturez le terminal montrant "PLAY RECAP" avec succès

2. **Conteneurs Docker en cours d'exécution**:
   ```bash
   ssh VOTRE_USER@VOTRE_IP
   docker ps
   ```

3. **L'application dans le navigateur**:
   - Frontend: http://VOTRE_IP:3000
   - API Docs: http://VOTRE_IP:8001/docs

4. **Logs du déploiement**:
   ```bash
   docker compose -f docker-compose.prod.yml logs
   ```

---

## 🐛 Dépannage Courant

### Erreur: "Permission denied (publickey)"

**Cause**: Problème avec la clé SSH

**Solution**:
```bash
# Vérifier les permissions
ls -la ../../sskdockerz/ssh-key-2025-10-16.key

# Corriger si nécessaire
chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key

# Tester la connexion SSH manuellement
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP
```

### Erreur: "UNREACHABLE! => Host is unreachable"

**Cause**: Impossible de joindre le serveur

**Solution**:
```bash
# Tester la connexion réseau
ping VOTRE_IP

# Vérifier que le serveur est allumé
# Vérifier l'adresse IP dans inventory.ini
```

### Erreur: "sudo: a password is required"

**Cause**: L'utilisateur n'est pas dans le groupe sudoers

**Solution**:
```bash
# Ajouter --ask-become-pass à la commande
ansible-playbook -i inventory.ini deploy.yml --ask-become-pass
```

### Les conteneurs ne démarrent pas

**Solution**:
```bash
# SSH sur le serveur
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP

# Voir les logs détaillés
cd /opt/dockezr
docker compose -f docker-compose.prod.yml logs backend
docker compose -f docker-compose.prod.yml logs frontend

# Reconstruire si nécessaire
docker compose -f docker-compose.prod.yml up -d --build
```

### Port déjà utilisé

**Solution**:
```bash
# Sur le serveur, voir ce qui utilise le port
sudo lsof -i :3000
sudo lsof -i :8001

# Arrêter le processus ou changer les ports dans group_vars/all.yml
```

---

## 🔄 Commandes de Gestion

### Mise à Jour de l'Application

```bash
# Re-exécuter le playbook
ansible-playbook -i inventory.ini deploy.yml
```

### Redémarrer les Services

```bash
# Sur le serveur
cd /opt/dockezr
docker compose -f docker-compose.prod.yml restart
```

### Arrêter l'Application

```bash
# Via Ansible
ansible-playbook -i inventory.ini deploy.yml --tags stop

# Ou sur le serveur
cd /opt/dockezr
docker compose -f docker-compose.prod.yml down
```

### Voir les Logs en Temps Réel

```bash
# Sur le serveur
cd /opt/dockezr
docker compose -f docker-compose.prod.yml logs -f

# Logs d'un service spécifique
docker compose -f docker-compose.prod.yml logs -f backend
```

---

## 📦 Livrable TP7

Pour valider le TP7, vous devez fournir:

### 1. Fichier deploy.yml

✅ Déjà créé et commenté dans `ansible/deploy.yml`

### 2. Captures d'Écran

Montrant:
- ✅ Exécution réussie du playbook (PLAY RECAP sans erreurs)
- ✅ Conteneurs Docker en cours d'exécution (docker ps)
- ✅ Application accessible dans le navigateur
- ✅ Logs montrant que tout fonctionne

### 3. Fichiers de Configuration

- ✅ `inventory.ini` - configuration des hôtes
- ✅ `group_vars/all.yml` - variables
- ✅ `templates/env.prod.j2` - template environnement

---

## 🎉 Félicitations!

Si vous êtes arrivé jusqu'ici et que tout fonctionne, bravo! 🚀

Votre application DockeZR est maintenant déployée automatiquement via Ansible.

**Prochaines étapes possibles:**
- Configurer un nom de domaine
- Mettre en place HTTPS avec Let's Encrypt
- Configurer des sauvegardes automatiques
- Ajouter plus de monitoring

---

**Besoin d'aide?** Consultez le fichier `README.md` dans le dossier ansible.

