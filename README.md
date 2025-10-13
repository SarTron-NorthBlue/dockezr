# 🏢 Expernet - Système de Réservation de Salles

Système complet de réservation de salles pour le centre de formation **Expernet**, développé avec **FastAPI** (Backend), **Next.js** (Frontend) et **PostgreSQL** (Base de données), orchestré avec Docker Compose.

## 📋 Stack Technique

- **Backend**: FastAPI (Python) avec AsyncPG
- **Frontend**: Next.js 14 + TypeScript + Tailwind CSS
- **Base de données**: PostgreSQL 16
- **Containerisation**: Docker & Docker Compose

## ✨ Fonctionnalités

### 🏛️ Gestion des Salles
- 5 salles pré-configurées (Atlas, Horizon, Innovation, Connect, Digital)
- Affichage des capacités et équipements
- Interface intuitive de sélection

### 📅 Réservations
- Formulaire de réservation complet
- Champ email optionnel
- Sélection de date et horaires
- **Vérification en temps réel** de la disponibilité
- Détection automatique des conflits d'horaires
- **Bouton désactivé** si créneau occupé
- Validation des créneaux disponibles
- Annulation de réservations

### 📊 Planning Visuel
- **Grille de planning par jour** (8h-22h)
- Vue d'ensemble de toutes les salles
- Code couleur : ✅ Disponible / ❌ Réservé
- Nom de l'utilisateur affiché sur les créneaux réservés
- Navigation par date
- Liste détaillée des réservations du jour

### 📋 Suivi
- Vue d'ensemble de toutes les réservations
- Filtrage par salle et par date
- Historique complet

## 🚀 Démarrage Rapide

### Prérequis

- Docker et Docker Compose installés sur votre machine
- Ports 3000, 8000 et 5432 disponibles

### Installation et lancement

1. **Cloner le projet** (si applicable)
```bash
git clone <votre-repo>
cd dockezr
```

2. **Lancer tous les services avec Docker Compose**
```bash
docker-compose up -d
```

ou utilisez le script Windows :
```bash
start.bat
```

Cette commande va :
- Créer le réseau Docker `dockezr_network`
- Démarrer PostgreSQL sur le port 5432
- Créer automatiquement les tables et les 5 salles par défaut
- Démarrer le backend FastAPI sur le port 8000
- Démarrer le frontend Next.js sur le port 3000

3. **Accéder à l'application**
- **Frontend (Interface de réservation)**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Documentation API (Swagger)**: http://localhost:8000/docs
- **Documentation API (ReDoc)**: http://localhost:8000/redoc

## 📁 Structure du Projet

```
dockezr/
├── backend/                  # API FastAPI
│   ├── main.py              # Point d'entrée de l'API
│   ├── requirements.txt     # Dépendances Python
│   └── Dockerfile           # Configuration Docker
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
├── docker-compose.yml       # Orchestration des services
├── .dockerignore           # Fichiers ignorés par Docker
├── .gitignore              # Fichiers ignorés par Git
└── README.md               # Ce fichier
```

## 🔧 Commandes Utiles

### Démarrer les services
```bash
docker-compose up -d
```

### Arrêter les services
```bash
docker-compose down
```

### Voir les logs
```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Reconstruire les images
```bash
docker-compose up -d --build
```

### Arrêter et supprimer les volumes (⚠️ supprime les données)
```bash
docker-compose down -v
```

### Accéder à un conteneur
```bash
# Backend
docker exec -it dockezr_backend sh

# Frontend
docker exec -it dockezr_frontend sh

# Base de données
docker exec -it dockezr_db psql -U user -d dockezr
```

## 🏛️ Salles Pré-configurées

Le système est livré avec 5 salles de formation :

| Salle | Capacité | Équipements |
|-------|----------|-------------|
| **Salle Atlas** | 30 personnes | Vidéoprojecteur, Tableau blanc, WiFi |
| **Salle Horizon** | 15 personnes | Écran TV, Tableau blanc, WiFi |
| **Salle Innovation** | 50 personnes | Vidéoprojecteur, Sono, WiFi, Climatisation |
| **Salle Connect** | 8 personnes | Écran TV, Visioconférence, WiFi |
| **Salle Digital** | 20 personnes | 20 postes informatiques, Vidéoprojecteur, WiFi |

## 🌐 API Endpoints

### Routes des Salles

- `GET /rooms` - Liste toutes les salles
- `GET /rooms/{room_id}` - Récupère une salle spécifique
- `POST /rooms` - Crée une nouvelle salle
- `DELETE /rooms/{room_id}` - Supprime une salle

### Routes des Réservations

- `GET /reservations` - Liste toutes les réservations
- `GET /reservations/room/{room_id}` - Réservations d'une salle spécifique
- `GET /reservations/date/{date}` - Réservations pour une date donnée
- `POST /reservations` - Crée une nouvelle réservation
- `DELETE /reservations/{reservation_id}` - Annule une réservation

### Validation automatique

L'API vérifie automatiquement :
- ✅ La disponibilité de la salle
- ✅ Les conflits d'horaires
- ✅ La cohérence des horaires (début < fin)
- ✅ L'existence de la salle

### Documentation interactive
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🗄️ Base de Données

### Configuration
- **Host**: localhost (ou `db` depuis les conteneurs)
- **Port**: 5432
- **Utilisateur**: user
- **Mot de passe**: password
- **Base de données**: dockezr

### Structure des tables

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

### Connexion à PostgreSQL
```bash
docker exec -it dockezr_db psql -U user -d dockezr
```

## 🎨 Frontend

L'interface utilise :
- **Next.js 14** avec App Router
- **TypeScript** pour le typage statique
- **Tailwind CSS** pour le styling moderne et responsive
- **Axios** pour les requêtes HTTP vers l'API

### Fonctionnalités de l'interface

**Onglet Planning (par défaut)**
- 📊 Grille de planning visuelle (8h-22h)
- 🎨 Code couleur : vert (disponible) / rouge (réservé)
- 📅 Sélecteur de date
- 👤 Affichage du nom de l'utilisateur sur les créneaux
- 📋 Liste détaillée des réservations du jour sélectionné
- 🖱️ Info-bulle au survol des créneaux réservés

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

## 🔄 Développement

### Mode développement avec hot-reload

Les deux services (backend et frontend) sont configurés en mode développement avec rechargement automatique :

- **Backend**: Uvicorn avec `--reload`
- **Frontend**: Next.js avec `npm run dev`

Les modifications de code sont automatiquement détectées et appliquées.

### Variables d'environnement

#### Backend
- `DATABASE_URL`: URL de connexion PostgreSQL

#### Frontend
- `NEXT_PUBLIC_API_URL`: URL de l'API backend

## 🐛 Dépannage

### Les conteneurs ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs

# Reconstruire les images
docker-compose up -d --build
```

### La base de données n'est pas prête
Le backend attend que PostgreSQL soit complètement démarré grâce au healthcheck.

### Erreurs de connexion à l'API
Vérifiez que :
- Le backend est démarré : `docker-compose ps`
- L'URL de l'API est correcte dans le frontend
- Le réseau Docker fonctionne : `docker network ls`

## 📝 Personnalisation

### Ajouter de nouvelles salles

Via l'API :
```bash
curl -X POST http://localhost:8000/rooms \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salle Formation",
    "capacity": 25,
    "equipment": "Vidéoprojecteur, WiFi",
    "description": "Salle de formation polyvalente"
  }'
```

Ou directement dans la base de données :
```sql
INSERT INTO rooms (name, capacity, equipment, description) 
VALUES ('Ma Salle', 40, 'Équipements', 'Description');
```

### Modifier les ports
Éditez le fichier `docker-compose.yml` et changez les mappings de ports :
```yaml
ports:
  - "VOTRE_PORT:PORT_INTERNE"
```

### Ajouter des dépendances

**Backend (Python)**:
1. Ajoutez la dépendance dans `backend/requirements.txt`
2. Reconstruisez : `docker-compose up -d --build backend`

**Frontend (Node.js)**:
1. Ajoutez la dépendance dans `frontend/package.json`
2. Reconstruisez : `docker-compose up -d --build frontend`

## 🎯 Cas d'Usage

Ce système est idéal pour :
- ✅ Centres de formation
- ✅ Espaces de coworking
- ✅ Entreprises avec salles de réunion
- ✅ Universités et écoles
- ✅ Bibliothèques avec salles d'étude

## 📦 Production

Pour un déploiement en production, modifiez :

1. Les mots de passe et secrets dans `docker-compose.yml`
2. Désactivez le mode debug/reload
3. Utilisez des variables d'environnement sécurisées
4. Configurez HTTPS/SSL
5. Ajoutez un reverse proxy (Nginx, Traefik)
6. Mettez en place des sauvegardes de la base de données

## 🔐 Sécurité

⚠️ **Important pour la production** :
- Changez les identifiants PostgreSQL par défaut
- Utilisez des secrets Docker pour les mots de passe
- Activez l'authentification utilisateur
- Configurez CORS correctement
- Utilisez HTTPS

## 📄 Licence

Ce projet est développé pour **Expernet** - Centre de Formation.

---

**🏢 Système de réservation Expernet - Simplifions la gestion des salles ! 🚀**

