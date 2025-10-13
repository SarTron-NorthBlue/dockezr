# 📖 Guide d'Utilisation - Expernet Réservation de Salles

## 🚀 Démarrage Rapide

### 1. Lancer l'application

**Windows :**
```bash
start.bat
```

**Linux/Mac :**
```bash
docker-compose up -d
```

### 2. Accéder à l'interface

Ouvrez votre navigateur : **http://localhost:3000**

## 📊 Consulter le Planning

### Vue d'ensemble

1. Cliquez sur l'onglet **"📊 Planning des salles"** (onglet par défaut)
2. Sélectionnez une date avec le sélecteur de date
3. Le planning affiche :
   - ✅ **Cases vertes** : Créneaux disponibles
   - ❌ **Cases rouges** : Créneaux réservés (avec le nom de l'utilisateur)
4. Passez la souris sur une case réservée pour voir les détails
5. En bas du planning, la liste détaillée des réservations du jour

### Avantages du Planning

- 🔍 Vision globale de toutes les salles
- ⏰ Horaires de 8h à 22h
- 📅 Navigation par date
- 👤 Identification rapide de qui a réservé

## 📅 Comment Réserver une Salle

### Étape 1 : Consulter le planning (recommandé)

1. Allez dans **"📊 Planning des salles"**
2. Vérifiez les disponibilités pour votre date
3. Notez les créneaux libres

### Étape 2 : Sélectionner une salle

1. Cliquez sur l'onglet **"📅 Réserver une salle"**
2. Vous verrez la liste des 5 salles disponibles à gauche
3. Chaque salle affiche :
   - 👥 Sa capacité
   - 🔧 Ses équipements
   - 📝 Sa description
4. Cliquez sur la salle souhaitée (elle sera surlignée en bleu)

### Étape 3 : Remplir le formulaire

1. **Nom** : Votre nom complet *(obligatoire)*
2. **Email** : Votre adresse email *(optionnel)*
3. **Date** : Sélectionnez la date de réservation *(obligatoire)*
4. **Heure de début** : Heure de début souhaitée *(obligatoire)*
5. **Heure de fin** : Heure de fin souhaitée *(obligatoire)*
6. **Objet** : Décrivez le but de la réservation *(obligatoire)*

### Étape 4 : Vérification automatique

⚡ **Nouveau !** Le système vérifie automatiquement la disponibilité :
- ✅ **Message vert** : "Ce créneau est disponible !"
- ❌ **Message rouge** : "Ce créneau est déjà réservé. Choisissez un autre horaire."

Le bouton de confirmation est **automatiquement désactivé** si le créneau est occupé !

### Étape 5 : Confirmer

Cliquez sur **"✅ Confirmer la réservation"** (uniquement si le créneau est disponible)

### ⚠️ Gestion des Conflits

Le système empêche **automatiquement** les doubles réservations :
- ❌ Le bouton de réservation est désactivé si le créneau est occupé
- 🔒 Impossible de réserver sur un créneau déjà pris
- ✅ Vérification en temps réel pendant la saisie

## 📋 Consulter vos Réservations

1. Cliquez sur l'onglet **"📋 Mes réservations"**
2. Vous verrez toutes les réservations actuelles avec :
   - 🏛️ Le nom de la salle
   - 👤 Le nom de l'utilisateur
   - 📅 La date
   - ⏰ Les horaires
   - 📧 L'email de contact
   - 📝 L'objet de la réservation

## ❌ Annuler une Réservation

1. Dans l'onglet **"Mes réservations"**
2. Cliquez sur **"❌ Annuler"** à côté de la réservation
3. Confirmez l'annulation

## 🏛️ Les 5 Salles Expernet

### 🎓 Salle Atlas (30 personnes)
- Vidéoprojecteur, Tableau blanc, WiFi
- **Usage** : Grande formation, séminaire

### 🤝 Salle Horizon (15 personnes)
- Écran TV, Tableau blanc, WiFi
- **Usage** : Réunion, petit groupe

### 🎤 Salle Innovation (50 personnes)
- Vidéoprojecteur, Sono, WiFi, Climatisation
- **Usage** : Conférence, grand événement

### 💼 Salle Connect (8 personnes)
- Écran TV, Visioconférence, WiFi
- **Usage** : Réunion d'équipe, visio

### 💻 Salle Digital (20 personnes)
- 20 postes informatiques, Vidéoprojecteur, WiFi
- **Usage** : Formation pratique, TP informatique

## 🔧 Administration

### Ajouter une nouvelle salle

Accédez à la documentation API : **http://localhost:8000/docs**

1. Trouvez l'endpoint `POST /rooms`
2. Cliquez sur "Try it out"
3. Remplissez les informations :
```json
{
  "name": "Salle Créative",
  "capacity": 12,
  "equipment": "Tableau interactif, WiFi",
  "description": "Salle pour ateliers créatifs"
}
```
4. Cliquez sur "Execute"

### Consulter les statistiques

Via l'API :
- **Toutes les réservations** : http://localhost:8000/reservations
- **Réservations par salle** : http://localhost:8000/reservations/room/{id}
- **Réservations par date** : http://localhost:8000/reservations/date/2025-10-15

## 🛠️ Dépannage

### L'application ne se charge pas
```bash
# Vérifier l'état des conteneurs
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### Erreur de connexion à la base
```bash
# Redémarrer tous les services
docker-compose restart
```

### Réinitialiser complètement
```bash
# Arrêter et supprimer tout (⚠️ perd les données)
docker-compose down -v

# Relancer
docker-compose up -d
```

## 📞 Support

Pour toute question ou problème, consultez :
- 📖 **Documentation API** : http://localhost:8000/docs
- 📋 **README** : Voir le fichier README.md
- 🔧 **Logs** : `docker-compose logs`

---

**Bon usage du système de réservation Expernet ! 🎯**

