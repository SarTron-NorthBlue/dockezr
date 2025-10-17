# 🏢 Dockezr - Système de Réservation de Salles

[![Release](https://img.shields.io/badge/release-v1.1.0-blue.svg)](https://github.com/SarTron-NorthBlue/dockezr/releases/tag/v1.1.0)
[![Docker](https://img.shields.io/badge/docker-compose-blue.svg)](https://docs.docker.com/compose/)
[![Monitoring](https://img.shields.io/badge/monitoring-prometheus%20%2B%20grafana-orange.svg)](https://prometheus.io/)
[![Production](https://img.shields.io/badge/production-ready-green.svg)](http://141.253.118.141:3000)

Système complet de réservation de salles pour le centre de formation **Expernet**, développé avec **FastAPI** (Backend), **Next.js** (Frontend), **PostgreSQL** (Base de données) et **Prometheus + Grafana** (Monitoring), orchestré avec Docker Compose.

## 🌐 **Application en Production**

**🚀 Accès direct à l'application :**
- **Frontend (Interface utilisateur)** : http://141.253.118.141:3000
- **Backend API** : http://141.253.118.141:8001
- **Documentation API** : http://141.253.118.141:8001/docs
- **Monitoring Grafana** : http://141.253.118.141:3001 (admin/Grafana2025!Secure)
- **Prometheus** : http://141.253.118.141:9090

## 🛠️ **Stack Technique**

- **Backend** : FastAPI (Python 3.11) avec AsyncPG
- **Frontend** : Next.js 14 + TypeScript + Tailwind CSS
- **Base de données** : PostgreSQL 16
- **Monitoring** : Prometheus + Grafana + Node Exporter
- **Containerisation** : Docker & Docker Compose
- **Tests** : Pytest avec GitHub Actions CI/CD
- **Déploiement** : Production sur serveur Oracle Cloud

## ✨ **Fonctionnalités**

### 🏛️ **Gestion des Salles**
- 5 salles pré-configurées (Atlas, Horizon, Innovation, Connect, Digital)
- Affichage des capacités et équipements
- Interface intuitive de sélection

### 📅 **Réservations**
- Formulaire de réservation complet
- Champ email optionnel
- Sélection de date et horaires
- **Vérification en temps réel** de la disponibilité
- Détection automatique des conflits d'horaires
- **Bouton désactivé** si créneau occupé
- Validation des créneaux disponibles
- Annulation de réservations

### 📊 **Planning Visuel**
- **Grille de planning par jour** (8h-22h)
- Vue d'ensemble de toutes les salles
- Code couleur : ✅ Disponible / ❌ Réservé
- Nom de l'utilisateur affiché sur les créneaux réservés
- Navigation par date
- Liste détaillée des réservations du jour

### 📈 **Monitoring et Observabilité**
- **Dashboard Grafana** complet avec métriques en temps réel
- **Métriques Prometheus** : CPU, mémoire, requêtes HTTP
- **Surveillance des performances** : temps de réponse, taux d'erreur
- **Métriques personnalisées** : réservations, accès aux salles
- **Alertes automatiques** en cas de problème

## 🚀 **Démarrage Rapide**

### **Prérequis**
- Docker et Docker Compose installés
- Ports 3000, 8001, 5432, 9090, 3001 disponibles

### **Installation et lancement**

1. **Cloner le projet**
```bash
git clone https://github.com/SarTron-NorthBlue/dockezr.git
cd dockezr
```

2. **Lancer tous les services**
```bash
docker-compose up -d
```

ou utilisez le script Windows :
```bash
scripts/start.bat
```

3. **Accéder à l'application**
- **Frontend** : http://localhost:3000
- **Backend API** : http://localhost:8001
- **Documentation API** : http://localhost:8001/docs
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3001 (admin/Grafana2025!Secure)

## 📁 **Structure du Projet**

```
dockezr/
├── backend/                  # API FastAPI
│   ├── main.py              # Point d'entrée avec métriques Prometheus
│   ├── requirements.txt     # Dépendances Python
│   ├── Dockerfile           # Configuration Docker
│   └── test_*.py           # Tests automatisés
│
├── frontend/                # Application Next.js
│   ├── app/                 # Pages et composants Next.js 14
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   ├── package.json         # Dépendances Node.js
│   ├── tsconfig.json        # Configuration TypeScript
│   ├── tailwind.config.ts   # Configuration Tailwind
│   └── Dockerfile           # Configuration Docker
│
├── monitoring/              # Configuration monitoring
│   ├── prometheus.yml       # Configuration Prometheus
│   └── grafana/             # Configuration Grafana
│       ├── provisioning/    # Datasources et dashboards
│       └── dashboards/      # Tableaux de bord
│
├── ansible/                 # Déploiement automatisé
│   ├── deploy.yml          # Playbook Ansible
│   ├── inventory.ini       # Inventaire des serveurs
│   └── group_vars/         # Variables de configuration
│
├── scripts/                 # Scripts d'administration
│   ├── start.bat           # Démarrage
│   ├── stop.bat            # Arrêt
│   └── test.bat            # Tests
│
├── docker-compose.yml       # Orchestration des services
├── docker-compose.prod.yml  # Configuration production
├── CHANGELOG.md            # Historique des versions
└── README.md               # Ce fichier
```

## 🏛️ **Salles Pré-configurées**

| Salle | Capacité | Équipements |
|-------|----------|-------------|
| **Salle Atlas** | 30 personnes | Vidéoprojecteur, Tableau blanc, WiFi |
| **Salle Horizon** | 15 personnes | Écran TV, Tableau blanc, WiFi |
| **Salle Innovation** | 50 personnes | Vidéoprojecteur, Sono, WiFi, Climatisation |
| **Salle Connect** | 8 personnes | Écran TV, Visioconférence, WiFi |
| **Salle Digital** | 20 personnes | 20 postes informatiques, Vidéoprojecteur, WiFi |

## 🌐 **API Endpoints**

### **Routes des Salles**
- `GET /rooms` - Liste toutes les salles
- `GET /rooms/{room_id}` - Récupère une salle spécifique
- `POST /rooms` - Crée une nouvelle salle
- `DELETE /rooms/{room_id}` - Supprime une salle

### **Routes des Réservations**
- `GET /reservations` - Liste toutes les réservations
- `GET /reservations/room/{room_id}` - Réservations d'une salle spécifique
- `GET /reservations/date/{date}` - Réservations pour une date donnée
- `POST /reservations` - Crée une nouvelle réservation
- `DELETE /reservations/{reservation_id}` - Annule une réservation

### **Monitoring**
- `GET /health` - Vérification de l'état de l'API
- `GET /metrics` - Métriques Prometheus

### **Documentation interactive**
- **Swagger UI** : http://localhost:8001/docs
- **ReDoc** : http://localhost:8001/redoc

## 📊 **Monitoring et Observabilité**

### **Dashboard Grafana**
Le système inclut un dashboard Grafana complet avec :

- **Status des Services** : Backend, Prometheus, Node Exporter
- **Métriques CPU** : Utilisation CPU du processus backend
- **Métriques Mémoire** : Utilisation mémoire en temps réel
- **Performance HTTP** : Requêtes par seconde, temps de réponse
- **Métriques Métier** : Nombre de réservations, accès aux salles

### **Métriques Prometheus**
- `http_requests_total` : Nombre total de requêtes HTTP
- `http_request_duration_seconds` : Durée des requêtes
- `reservations_total` : Nombre de réservations créées
- `room_access_total` : Nombre d'accès aux salles
- `process_cpu_seconds_total` : Utilisation CPU
- `process_resident_memory_bytes` : Utilisation mémoire

### **Accès au Monitoring**
- **Grafana** : http://141.253.118.141:3001
- **Identifiants** : `admin` / `Grafana2025!Secure`
- **Dashboard** : "Dockezr - Monitoring Complet"

## 🔧 **Commandes Utiles**

### **Démarrer les services**
```bash
docker-compose up -d
```

### **Arrêter les services**
```bash
docker-compose down
```

### **Voir les logs**
```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### **Reconstruire les images**
```bash
docker-compose up -d --build
```

### **Tests automatisés**
```bash
scripts/test.bat
```

## 🚀 **Déploiement en Production**

### **Déploiement Automatisé avec Ansible**

Le projet inclut une configuration Ansible complète pour le déploiement automatisé :

```bash
# Déploiement automatique
cd ansible
./deploy-auto.ps1

# Déploiement manuel
./deploy-manuel.ps1
```

### **Configuration de Production**

Le fichier `docker-compose.prod.yml` est configuré pour la production avec :
- Variables d'environnement sécurisées
- Health checks pour tous les services
- Volumes persistants pour les données
- Réseaux Docker dédiés
- Configuration monitoring complète

### **Variables d'environnement de production**

```bash
# Base de données
POSTGRES_USER=dockezr_user
POSTGRES_PASSWORD=Dockezr2025!Secure
POSTGRES_DB=dockezr_prod

# Frontend
NEXT_PUBLIC_API_URL=http://141.253.118.141:8001

# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=Grafana2025!Secure
```

## 🗄️ **Base de Données**

### **Configuration**
- **Host** : localhost (ou `db` depuis les conteneurs)
- **Port** : 5432
- **Utilisateur** : `dockezr_user`
- **Mot de passe** : `Dockezr2025!Secure`
- **Base de données** : `dockezr_prod`

### **Structure des tables**

**Table `rooms`**
- id (SERIAL PRIMARY KEY)
- name (VARCHAR UNIQUE)
- capacity (INTEGER)
- equipment (TEXT)
- description (TEXT)

**Table `reservations`**
- id (SERIAL PRIMARY KEY)
- room_id (INTEGER FOREIGN KEY)
- user_name (VARCHAR)
- user_email (VARCHAR)
- reservation_date (DATE)
- start_time (TIME)
- end_time (TIME)
- purpose (TEXT)
- created_at (TIMESTAMP)

## 🎨 **Frontend**

L'interface utilise :
- **Next.js 14** avec App Router
- **TypeScript** pour le typage statique
- **Tailwind CSS** pour le styling moderne et responsive
- **Axios** pour les requêtes HTTP vers l'API

### **Fonctionnalités de l'interface**

**Onglet Planning (par défaut)**
- 📊 Grille de planning visuelle (8h-22h)
- 🎨 Code couleur : vert (disponible) / rouge (réservé)
- 📅 Sélecteur de date
- 👤 Affichage du nom de l'utilisateur sur les créneaux
- 📋 Liste détaillée des réservations du jour sélectionné

**Onglet Réservation**
- Liste visuelle des salles disponibles avec détails
- Sélection interactive de salle
- Formulaire de réservation complet
- **Email optionnel** (pas obligatoire)
- ⚡ **Vérification en temps réel** de la disponibilité
- ✅/❌ Indicateur visuel de disponibilité du créneau
- 🔒 Bouton désactivé automatiquement si créneau occupé

**Onglet Mes Réservations**
- Affichage de toutes les réservations
- Informations détaillées (salle, date, horaire, objet)
- Possibilité d'annuler une réservation

## 🧪 **Tests et Qualité**

### **Tests automatisés**
- **Tests API** : Validation des endpoints avec Pytest
- **Tests de connectivité** : Simulation d'erreurs pour validation
- **CI/CD** : GitHub Actions avec tests automatiques
- **Couverture** : Tests de performance et de régression

### **Exécution des tests**
```bash
# Tests complets
scripts/test.bat

# Tests de simulation d'erreur
scripts/test-connectivity.bat
```

## 🔒 **Sécurité**

### **Configuration de production**
- Mots de passe sécurisés pour tous les services
- Configuration CORS appropriée
- Health checks pour la surveillance
- Volumes persistants pour les données
- Réseaux Docker isolés

### **Recommandations de sécurité**
- Changez les mots de passe par défaut en production
- Configurez HTTPS/SSL avec un reverse proxy
- Activez l'authentification utilisateur
- Configurez les sauvegardes de la base de données
- Limitez l'accès aux ports de monitoring

## 📝 **Personnalisation**

### **Ajouter de nouvelles salles**

Via l'API :
```bash
curl -X POST http://141.253.118.141:8001/rooms \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salle Formation",
    "capacity": 25,
    "equipment": "Vidéoprojecteur, WiFi",
    "description": "Salle de formation polyvalente"
  }'
```

### **Modifier les ports**
Éditez le fichier `docker-compose.prod.yml` et changez les mappings de ports :
```yaml
ports:
  - "VOTRE_PORT:PORT_INTERNE"
```

## 🎯 **Cas d'Usage**

Ce système est idéal pour :
- ✅ Centres de formation
- ✅ Espaces de coworking
- ✅ Entreprises avec salles de réunion
- ✅ Universités et écoles
- ✅ Bibliothèques avec salles d'étude

## 📋 **Versions et Releases**

### **Version actuelle : v1.1.0**
- **Date de release** : 16 octobre 2025
- **Type** : Release avec monitoring
- **Statut** : Stable, déployé en production
- **Compatibilité** : Windows, Linux, macOS
- **Dépendances** : Docker, Docker Compose

### **Changelog**
Voir [CHANGELOG.md](CHANGELOG.md) pour l'historique complet des versions.

### **Releases GitHub**
- [v1.1.0](https://github.com/SarTron-NorthBlue/dockezr/releases/tag/v1.1.0) - Version avec monitoring
- [v1.0.0](https://github.com/SarTron-NorthBlue/dockezr/releases/tag/v1.0.0) - Version initiale

## 📞 **Support et Documentation**

### **Documentation**
- **Guide d'utilisation** : [GUIDE_UTILISATION.md](GUIDE_UTILISATION.md)
- **Guide de déploiement** : [DEPLOYMENT.md](DEPLOYMENT.md)
- **Dépannage** : [DEPANNAGE.md](DEPANNAGE.md)
- **API** : Documentation interactive sur http://141.253.118.141:8001/docs

### **Monitoring**
- **Grafana** : http://141.253.118.141:3001
- **Prometheus** : http://141.253.118.141:9090
- **Dashboard** : "Dockezr - Monitoring Complet"

## 📄 **Licence**

Ce projet est développé pour **Expernet** - Centre de Formation.

---

**🏢 Système de réservation Expernet - Simplifions la gestion des salles !**

**🌐 Application en ligne :** http://141.253.118.141:3000