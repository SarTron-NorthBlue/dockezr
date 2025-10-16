# 🚀 Guide de Déploiement - Dockezr

## Vue d'ensemble

Ce guide vous explique comment déployer Dockezr en production sur un serveur Linux avec Docker Compose.

## 📋 Prérequis

- Serveur Linux (Ubuntu/Debian recommandé)
- Docker et Docker Compose installés
- Accès SSH au serveur de production
- Ports 3000, 8001, 9090, 3001 ouverts

## 🔧 Configuration Initiale

### 1. **Préparation du serveur**

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de Docker
sudo apt install docker.io docker-compose git curl -y

# Démarrage et activation de Docker
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter l'utilisateur au groupe docker (optionnel)
sudo usermod -aG docker $USER
```

### 2. **Cloner le projet**

```bash
# Cloner le repository
git clone https://github.com/votre-username/dockezr.git
cd dockezr

# Copier la configuration de production
cp env.prod.example .env.prod

# Modifier les variables d'environnement
nano .env.prod
```

## 🚀 Déploiement Manuel

### Déploiement complet

```bash
# Démarrer tous les services
docker-compose -f docker-compose.prod.yml up -d

# Vérifier l'état des services
docker-compose -f docker-compose.prod.yml ps

# Voir les logs en temps réel
docker-compose -f docker-compose.prod.yml logs -f
```

### Déploiement par étapes

```bash
# 1. Démarrer la base de données
docker-compose -f docker-compose.prod.yml up -d db

# 2. Attendre que la DB soit prête
sleep 10

# 3. Démarrer le backend
docker-compose -f docker-compose.prod.yml up -d backend

# 4. Démarrer le frontend
docker-compose -f docker-compose.prod.yml up -d frontend

# 5. Démarrer les services de monitoring
docker-compose -f docker-compose.prod.yml up -d prometheus grafana
```

## 📊 Monitoring du Déploiement

### Vérification des services

```bash
# État des conteneurs
docker-compose -f docker-compose.prod.yml ps

# Logs des services
docker-compose -f docker-compose.prod.yml logs -f

# Test de santé
curl http://localhost:8001/health
curl http://localhost:3000
```

### Accès aux services

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://votre-serveur:3000 | Interface utilisateur |
| **Backend** | http://votre-serveur:8001 | API REST |
| **Prometheus** | http://votre-serveur:9090 | Métriques |
| **Grafana** | http://votre-serveur:3001 | Tableaux de bord |

## 🔒 Sécurité

### Variables d'environnement critiques

```bash
# Mots de passe sécurisés
POSTGRES_PASSWORD=password-très-sécurisé
GRAFANA_PASSWORD=password-grafana-sécurisé

# URLs publiques
NEXT_PUBLIC_API_URL=http://votre-domaine.com:8001
```

### Recommandations

1. **Changez tous les mots de passe par défaut**
2. **Utilisez HTTPS** avec un reverse proxy (Nginx/Traefik)
3. **Limitez l'accès** aux ports de monitoring
4. **Configurez un firewall** approprié
5. **Sauvegardez régulièrement** la base de données

## 🛠️ Dépannage

### Problèmes courants

#### Images non trouvées
```bash
# Vérifier que les images existent sur DockerHub
docker pull votre-username/dockezr-backend:latest
docker pull votre-username/dockezr-frontend:latest
```

#### Services non accessibles
```bash
# Vérifier les logs
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs frontend

# Redémarrer les services
docker-compose -f docker-compose.prod.yml restart
```

#### Problèmes de base de données
```bash
# Vérifier la connexion
docker-compose -f docker-compose.prod.yml exec db psql -U user -d dockezr

# Redémarrer la base de données
docker-compose -f docker-compose.prod.yml restart db
```

## 📈 Monitoring et Métriques

### Prometheus

- **URL** : http://votre-serveur:9090
- **Métriques** : Automatiquement collectées depuis le backend
- **Rétention** : 200 heures par défaut

### Grafana

- **URL** : http://votre-serveur:3001
- **Identifiants** : admin / (mot de passe configuré)
- **Dashboard** : "Dockezr - Vue d'ensemble" pré-configuré

## 🔄 Mise à jour

### Mise à jour automatique

```bash
# Créer une nouvelle version
git tag v1.2.0
git push origin v1.2.0
```

### Mise à jour manuelle

```bash
# Déployer la nouvelle version
./scripts/deploy.sh v1.2.0
```

## 📞 Support

En cas de problème :

1. Vérifiez les logs : `docker-compose -f docker-compose.prod.yml logs`
2. Consultez la documentation : [README.md](README.md)
3. Vérifiez les issues GitHub
4. Contactez l'équipe de développement

---

**Dockezr - Déploiement automatisé et monitoring complet ! 🎯**
