# 🚀 Quick Start - Déploiement en 5 Minutes

Guide rapide pour déployer DockeZR sur votre serveur en 5 minutes chrono.

---

## ⚡ Déploiement Rapide

### 1️⃣ Prérequis (2 min)

```bash
# Sur Windows, installer WSL + Ansible
wsl --install
# Redémarrer Windows, puis dans WSL:
sudo apt update && sudo apt install ansible -y
```

### 2️⃣ Configuration (2 min)

```bash
# Naviguer vers le dossier
cd /mnt/c/Users/lou/Documents/Projet/dockeer/dockezr/ansible

# Éditer l'inventaire
nano inventory.ini
# Remplacer: VOTRE_IP_SERVEUR, VOTRE_USER

# Éditer les variables
nano group_vars/all.yml
# Modifier: project_repo, mots de passe

# Permissions SSH
chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key
```

### 3️⃣ Test de Connexion (30 sec)

```bash
ansible all -i inventory.ini -m ping
```

✅ Devrait afficher: `"ping": "pong"`

### 4️⃣ Déploiement (5-10 min)

```bash
ansible-playbook -i inventory.ini deploy.yml
```

### 5️⃣ Vérification (30 sec)

```bash
# Ouvrir dans le navigateur:
# http://VOTRE_IP:3000
# http://VOTRE_IP:8001/docs
```

---

## 📋 Commandes Essentielles

### Déploiement

```bash
# Déploiement complet
ansible-playbook -i inventory.ini deploy.yml

# Avec mode verbeux
ansible-playbook -i inventory.ini deploy.yml -v

# Test en local d'abord
ansible-playbook -i inventory.local.ini deploy.yml
```

### Gestion

```bash
# Arrêter
ansible-playbook -i inventory.ini deploy.yml --tags stop

# Reconstruire
ansible-playbook -i inventory.ini deploy.yml --tags build,start

# Test connexion
ansible all -i inventory.ini -m ping
```

### Sur le Serveur

```bash
# Connexion SSH
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key USER@IP

# Voir les conteneurs
docker ps

# Voir les logs
cd /opt/dockezr
docker compose -f docker-compose.prod.yml logs -f

# Redémarrer
docker compose -f docker-compose.prod.yml restart
```

---

## 🎯 URLs des Services

Remplacez `VOTRE_IP` par l'adresse IP de votre serveur:

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Frontend** | http://VOTRE_IP:3000 | - |
| **API** | http://VOTRE_IP:8001 | - |
| **Swagger** | http://VOTRE_IP:8001/docs | - |
| **Prometheus** | http://VOTRE_IP:9090 | - |
| **Grafana** | http://VOTRE_IP:3001 | admin / [votre_mdp] |

---

## 🐛 Dépannage Express

| Problème | Solution |
|----------|----------|
| ❌ Permission denied | `chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key` |
| ❌ Host unreachable | Vérifier IP dans `inventory.ini` et `ping VOTRE_IP` |
| ❌ sudo password | Ajouter `--ask-become-pass` |
| ❌ Conteneurs ne démarrent pas | SSH au serveur + `cd /opt/dockezr` + `docker compose logs` |

---

## 📸 Captures pour le Livrable

```bash
# 1. Exécution du playbook
ansible-playbook -i inventory.ini deploy.yml
# 📸 Capturer le terminal avec "PLAY RECAP" SUCCESS

# 2. Sur le serveur
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key USER@IP
docker ps
# 📸 Capturer la liste des conteneurs running

# 3. Dans le navigateur
# 📸 http://VOTRE_IP:3000
# 📸 http://VOTRE_IP:8001/docs
```

---

## ✅ Checklist Livrable TP7

- [ ] `deploy.yml` commenté (✅ déjà fait)
- [ ] `inventory.ini` configuré
- [ ] `group_vars/all.yml` configuré
- [ ] Test connexion SSH réussi
- [ ] Playbook exécuté avec succès
- [ ] Capture: terminal avec PLAY RECAP
- [ ] Capture: docker ps sur le serveur
- [ ] Capture: application dans le navigateur
- [ ] Documentation: README.md dans ansible/

---

## 🎓 Ce que fait le Playbook

1. ✅ Mise à jour du système
2. ✅ Installation de Docker + Docker Compose
3. ✅ Configuration des permissions
4. ✅ Clonage du repository GitHub
5. ✅ Configuration des variables d'environnement
6. ✅ Build des images Docker
7. ✅ Lancement de l'application
8. ✅ Vérification et affichage des logs

**Tout est automatisé! 🎉**

---

## 🚀 Aller Plus Loin

### Sécuriser les Secrets

```bash
# Chiffrer les variables sensibles
ansible-vault encrypt group_vars/all.yml

# Exécuter avec vault
ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass
```

### Configurer un Pare-feu

```bash
# Sur le serveur
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8001/tcp
sudo ufw enable
```

### Sauvegardes Automatiques

```bash
# Ajouter un cron sur le serveur
0 2 * * * docker exec dockezr_db pg_dump -U user dockezr > /backup/dockezr_$(date +\%Y\%m\%d).sql
```

---

**Bon déploiement! 🎉**

Pour plus de détails, consultez:
- 📖 `GUIDE_EXECUTION.md` - Guide détaillé pas à pas
- 📘 `README.md` - Documentation complète
- 🔧 `deploy.sh` - Script interactif

