# 🔧 Guide de Dépannage - Expernet

## Problème : Les onglets "Réserver une salle" et "Mes réservations" ne fonctionnent pas

### Solution 1 : Vider le cache du navigateur (Recommandé)

1. **Ouvrez votre navigateur** sur http://localhost:3000
2. **Appuyez sur** `Ctrl + Shift + R` (Windows/Linux) ou `Cmd + Shift + R` (Mac)
   - Cela force le rechargement de la page sans cache
3. **Ou utilisez le mode navigation privée** :
   - Chrome/Edge : `Ctrl + Shift + N`
   - Firefox : `Ctrl + Shift + P`

### Solution 2 : Vider complètement le cache

#### Chrome / Edge
1. `Ctrl + Shift + Delete`
2. Sélectionnez "Images et fichiers en cache"
3. Cliquez sur "Effacer les données"
4. Rechargez http://localhost:3000

#### Firefox
1. `Ctrl + Shift + Delete`
2. Sélectionnez "Cache"
3. Cliquez sur "Effacer maintenant"
4. Rechargez http://localhost:3000

### Solution 3 : Reconstruire complètement le frontend

Si le problème persiste :

```bash
# Arrêter tous les services
docker-compose down

# Reconstruire uniquement le frontend
docker-compose up -d --build frontend

# Ou reconstruire tout
docker-compose up -d --build
```

### Solution 4 : Vérifier la console du navigateur

1. Appuyez sur `F12` pour ouvrir les outils de développement
2. Allez dans l'onglet **Console**
3. Recherchez des erreurs en rouge
4. Si vous voyez des erreurs, notez-les et contactez le support

### Solution 5 : Vérifier que les services fonctionnent

```bash
# Vérifier l'état des conteneurs
docker-compose ps

# Tous doivent afficher "Up" dans la colonne STATUS

# Vérifier les logs du frontend
docker-compose logs frontend --tail=20

# Vérifier les logs du backend
docker-compose logs backend --tail=20
```

## Vérification Rapide

### Test 1 : API Backend
Ouvrez dans votre navigateur : http://localhost:8000/rooms
- ✅ Vous devez voir un JSON avec la liste des salles

### Test 2 : Frontend
Ouvrez dans votre navigateur : http://localhost:3000
- ✅ Vous devez voir la page avec 3 onglets

### Test 3 : Planning
Sur http://localhost:3000 :
- ✅ L'onglet "Planning des salles" doit être actif par défaut
- ✅ Vous devez voir une grille avec les 5 salles

## Problèmes Courants

### Les onglets sont visibles mais ne répondent pas aux clics
➡️ **Solution** : Videz le cache (`Ctrl + Shift + R`)

### La page est blanche
➡️ **Solution** : 
```bash
docker-compose restart frontend
```

### Erreur "Cannot connect to server"
➡️ **Solution** :
```bash
# Vérifier que tous les services sont up
docker-compose ps

# Redémarrer si nécessaire
docker-compose restart
```

### Les données ne se chargent pas
➡️ **Solution** :
1. Vérifiez que le backend fonctionne : http://localhost:8000/docs
2. Ouvrez F12 > Network pour voir les requêtes
3. Vérifiez qu'il n'y a pas d'erreurs CORS

## Redémarrage Complet (Solution ultime)

Si rien ne fonctionne :

```bash
# 1. Tout arrêter et nettoyer
docker-compose down -v

# 2. Reconstruire tout
docker-compose up -d --build

# 3. Attendre 30 secondes que tout démarre

# 4. Ouvrir en mode privé
# Chrome: Ctrl + Shift + N
# Puis aller sur http://localhost:3000
```

## Accès Direct aux Fonctionnalités

- **Planning** : http://localhost:3000 (onglet par défaut)
- **API Salles** : http://localhost:8000/rooms
- **API Réservations** : http://localhost:8000/reservations
- **Documentation API** : http://localhost:8000/docs

## Contact Support

Si le problème persiste après toutes ces étapes :
1. Notez le message d'erreur exact
2. Faites une capture d'écran de la console (F12)
3. Exécutez : `docker-compose logs > logs.txt`
4. Envoyez ces informations au support

