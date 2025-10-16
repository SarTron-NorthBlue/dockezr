# 🚀 Déploiement Ansible - DockeZR

Ce dossier contient les playbooks Ansible pour automatiser le déploiement de l'application DockeZR sur un serveur Linux distant.

## 📋 Prérequis

### Sur votre machine locale (Windows)

1. **Installer Ansible** via WSL2 ou utiliser un container Docker:

```bash
# Option 1: WSL2 (Ubuntu)
wsl --install
# Puis dans WSL:
sudo apt update
sudo apt install ansible -y

# Option 2: Via Docker
docker run -it --rm -v ${PWD}:/ansible ansible/ansible:latest
```

2. **Vérifier l'installation**:
```bash
ansible --version
```

### Sur le serveur distant

- Système Linux (Ubuntu 20.04/22.04 recommandé)
- Accès SSH avec clé privée
- Utilisateur avec droits sudo
- Ports ouverts: 22 (SSH), 3000, 8001, 9090, 3001

## 📁 Structure des fichiers

```
ansible/
├── deploy.yml              # Playbook principal de déploiement
├── inventory.ini           # Inventaire des serveurs
├── README.md              # Ce fichier
├── group_vars/
│   └── all.yml            # Variables globales
└── templates/
    └── env.prod.j2        # Template du fichier .env.prod
```

## ⚙️ Configuration

### 1. Modifier l'inventaire

Éditez `inventory.ini` et remplacez les valeurs:

```ini
[production]
server ansible_host=VOTRE_IP_SERVEUR ansible_user=VOTRE_USER ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key
```

**Exemple:**
```ini
[production]
server ansible_host=192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=../../sskdockerz/ssh-key-2025-10-16.key
```

### 2. Configurer les variables

Éditez `group_vars/all.yml` et modifiez:

```yaml
# URL de votre repository GitHub
project_repo: "https://github.com/VOTRE_USERNAME/dockezr.git"

# Mots de passe (IMPORTANT: changez-les!)
postgres_password: "votre_mot_de_passe_securise"
grafana_admin_password: "votre_mot_de_passe_grafana"
```

### 3. Vérifier les permissions de la clé SSH

```bash
# Sur Windows (WSL)
chmod 600 ../../sskdockerz/ssh-key-2025-10-16.key

# Ou sur PowerShell
icacls "..\..\sskdockerz\ssh-key-2025-10-16.key" /inheritance:r /grant:r "%USERNAME%:R"
```

## 🚀 Exécution du Playbook

### Test de connexion

Avant de déployer, testez la connexion SSH:

```bash
# Depuis le dossier ansible/
ansible all -i inventory.ini -m ping
```

Vous devriez voir:
```
server | SUCCESS => {
    "ping": "pong"
}
```

### Déploiement complet

```bash
# Exécution du playbook complet
ansible-playbook -i inventory.ini deploy.yml

# Avec affichage verbeux (pour debug)
ansible-playbook -i inventory.ini deploy.yml -v

# Demander le mot de passe sudo si nécessaire
ansible-playbook -i inventory.ini deploy.yml --ask-become-pass
```

### Exécution par étapes (tags)

```bash
# Arrêter uniquement les conteneurs
ansible-playbook -i inventory.ini deploy.yml --tags stop

# Reconstruire les images
ansible-playbook -i inventory.ini deploy.yml --tags build

# Démarrer les conteneurs
ansible-playbook -i inventory.ini deploy.yml --tags start
```

## 📊 Étapes du Déploiement

Le playbook `deploy.yml` effectue les opérations suivantes:

1. **[1/10]** 🔄 Mise à jour du système et installation des prérequis
2. **[2/10]** 🐳 Installation de Docker Engine
3. **[3/10]** 🔍 Vérification de Docker Compose
4. **[4/10]** 📁 Création des répertoires de déploiement
5. **[5/10]** 📥 Clonage du repository GitHub
6. **[6/10]** ⚙️ Configuration des variables d'environnement
7. **[7/10]** 🛑 Arrêt des conteneurs existants
8. **[8/10]** 🏗️ Construction des images Docker
9. **[9/10]** 🚀 Démarrage des conteneurs
10. **[10/10]** ✅ Vérification et affichage des logs

## 🌐 Accès aux Services

Après le déploiement réussi, accédez aux services via:

- **Frontend**: http://VOTRE_IP:3000
- **Backend API**: http://VOTRE_IP:8001
- **Documentation API**: http://VOTRE_IP:8001/docs
- **Prometheus**: http://VOTRE_IP:9090
- **Grafana**: http://VOTRE_IP:3001 (admin/votre_mot_de_passe)

## 🐛 Dépannage

### Problème de connexion SSH

```bash
# Tester la connexion manuelle
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP

# Vérifier les permissions de la clé
ls -la ../../sskdockerz/ssh-key-2025-10-16.key
```

### Erreur "Permission denied"

```bash
# Ajouter --ask-become-pass
ansible-playbook -i inventory.ini deploy.yml --ask-become-pass
```

### Vérifier l'état sur le serveur

```bash
# SSH sur le serveur
ssh -i ../../sskdockerz/ssh-key-2025-10-16.key VOTRE_USER@VOTRE_IP

# Vérifier Docker
docker --version
docker ps

# Vérifier les conteneurs DockeZR
cd /opt/dockezr
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs
```

### Les conteneurs ne démarrent pas

```bash
# Sur le serveur, vérifier les logs
cd /opt/dockezr
docker compose -f docker-compose.prod.yml logs -f

# Reconstruire les images
docker compose -f docker-compose.prod.yml up -d --build
```

## 🔄 Mise à jour de l'application

Pour mettre à jour l'application après des modifications:

```bash
# Re-exécuter le playbook
ansible-playbook -i inventory.ini deploy.yml

# Ou uniquement reconstruire et redémarrer
ansible-playbook -i inventory.ini deploy.yml --tags build,start
```

## 📝 Notes

- Le playbook est idempotent: vous pouvez l'exécuter plusieurs fois sans problème
- Les données PostgreSQL sont persistées dans des volumes Docker
- Les logs sont accessibles via `docker compose logs`
- Le déploiement prend environ 5-10 minutes selon la connexion

## 🔐 Sécurité

**⚠️ IMPORTANT:**

1. **Changez tous les mots de passe** dans `group_vars/all.yml`
2. **Ne commitez JAMAIS** les mots de passe réels sur Git
3. Utilisez **Ansible Vault** pour chiffrer les secrets:

```bash
# Chiffrer le fichier de variables
ansible-vault encrypt group_vars/all.yml

# Exécuter avec vault
ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass
```

4. **Configurez un pare-feu** sur le serveur:
```bash
sudo ufw allow 22/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 8001/tcp
sudo ufw enable
```

## 📞 Support

Pour toute question ou problème:
- Vérifiez les logs Ansible avec `-vvv`
- Consultez la documentation Ansible: https://docs.ansible.com
- Vérifiez les logs Docker sur le serveur

---

**Bon déploiement! 🚀**

