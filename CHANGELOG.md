# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-10-15

### Ajouté
- **TP1 - Architecture** : Système de réservation de salles avec Docker
  - Backend FastAPI avec endpoints complets
  - Frontend Next.js avec interface moderne
  - Base de données PostgreSQL
  - Configuration Docker Compose multi-services
  - 5 salles pré-configurées (Atlas, Horizon, Innovation, Connect, Digital)

- **TP2 - Développement** : Fonctionnalités avancées
  - Interface de planning visuel avec grille horaire
  - Système de réservation avec validation automatique
  - Gestion des conflits de réservation
  - Interface responsive avec Tailwind CSS
  - Validation en temps réel de la disponibilité

- **TP3 - Déploiement** : Configuration de production
  - Scripts de démarrage automatisés (start.bat, stop.bat)
  - Configuration CORS pour la communication frontend/backend
  - Variables d'environnement configurées
  - Documentation utilisateur complète

- **TP4 - Tests** : Système de tests automatisés
  - Tests Pytest pour validation des endpoints API
  - Intégration GitHub Actions pour CI/CD
  - Tests de simulation d'erreur pour validation de la détection automatique
  - Configuration Docker pour l'exécution des tests
  - Scripts de test automatisés

- **TP5 - Release** : Préparation à la mise en production
  - Gestion des versions avec Git tags
  - Release GitHub avec documentation
  - Changelog complet des modifications
  - Configuration CI pour les releases

### Fonctionnalités principales
- **Planning des salles** : Vue d'ensemble avec grille horaire 8h-22h
- **Réservation** : Interface intuitive avec validation automatique
- **Gestion des réservations** : Consultation et annulation des réservations
- **API REST** : Endpoints complets pour salles et réservations
- **Base de données** : Stockage PostgreSQL avec relations
- **Interface moderne** : Design responsive avec Tailwind CSS

### Endpoints API
- `GET /health` - Vérification de l'état de l'API
- `GET /rooms` - Liste des salles disponibles
- `GET /rooms/{id}` - Détails d'une salle spécifique
- `GET /reservations` - Liste des réservations
- `GET /reservations/date/{date}` - Réservations par date
- `POST /reservations` - Création d'une nouvelle réservation
- `DELETE /reservations/{id}` - Annulation d'une réservation

### Configuration technique
- **Backend** : FastAPI avec Python 3.11
- **Frontend** : Next.js 14 avec TypeScript
- **Base de données** : PostgreSQL 16
- **Conteneurisation** : Docker et Docker Compose
- **Tests** : Pytest avec couverture de code
- **CI/CD** : GitHub Actions

### Salles disponibles
1. **Salle Atlas** (30 personnes) - Vidéoprojecteur, Tableau blanc, WiFi
2. **Salle Horizon** (15 personnes) - Écran TV, Tableau blanc, WiFi
3. **Salle Innovation** (50 personnes) - Vidéoprojecteur, Sono, WiFi, Climatisation
4. **Salle Connect** (8 personnes) - Écran TV, Visioconférence, WiFi
5. **Salle Digital** (20 personnes) - 20 postes informatiques, Vidéoprojecteur, WiFi

### Scripts d'administration
- `scripts/start.bat` - Démarrage de l'application
- `scripts/stop.bat` - Arrêt de l'application
- `scripts/test.bat` - Exécution des tests automatisés
- `scripts/test-connectivity.bat` - Tests de simulation d'erreur

### Documentation
- Guide d'utilisation complet
- Documentation API interactive (Swagger UI)
- README avec instructions d'installation
- Changelog des versions

---

## Notes de version

### Version 1.0.0
- **Date de release** : 15 octobre 2025
- **Type** : Release initiale
- **Statut** : Stable, prêt pour la production
- **Compatibilité** : Windows, Linux, macOS
- **Dépendances** : Docker, Docker Compose

### Migration
Cette version est la première release stable. Aucune migration n'est nécessaire.

### Support
- **Documentation** : Disponible dans le README.md
- **API** : Documentation interactive sur http://localhost:8000/docs
- **Tests** : Suite de tests complète avec validation automatique
