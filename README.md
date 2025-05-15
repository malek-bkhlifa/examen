# Devine Le Nombre – Application Flutter

Une application mobile Flutter pour deviner un nombre aléatoire entre 0 et 100 en 5 tentatives, avec gestion du score, persistance locale et intégration API.

## Fonctionnalités

- Génération aléatoire d’un nombre
- 5 tentatives pour deviner le bon nombre
- Calcul du score en fonction du nombre d’essais
- Intégration d’une API pour enregistrer les scores
- Persistance locale du score avec `shared_preferences`

## API

L’application utilise une API pour :
- Envoyer et récupérer les scores
- Gérer l’historique du joueur

### Exemple d’API avec json-server

Démarrer un serveur local :

```bash
json-server --watch db.json --port 3000
````

Endpoints disponibles :

* `GET http://localhost:3000/games` 
* `POST http://localhost:3000/scores` 

## Arborescence du projet

```
lib/
├── main.dart
├── screens/
│   └── game_screen.dart
├── services/
│   └── api_service.dart
├── widgets/
│   └── guess_input.dart
```

## Lancer l'application

### Prérequis

* Flutter SDK installé
* Android Studio ou VS Code avec les extensions Flutter & Dart
* Un émulateur Android fonctionnel ou un appareil physique
* json-server installé si vous voulez simuler une API REST

### Commandes

```bash
git clone https://github.com/votre-utilisateur/tpflutter.git
cd tpflutter
flutter pub get
flutter run
```

### API locale

Démarrer l'API avec json-server :

```bash
json-server --watch db.json --port 3000
```

Accès à l’API :
`http://localhost:3000/scores`

## Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.6
  shared_preferences: ^2.2.2
```

## Résolution des erreurs

En cas de bugs liés au build ou à l’émulateur :

```bash
flutter clean
flutter pub get
flutter run
```

Assurez-vous aussi que l’émulateur dispose d’au moins 4 Go de RAM et assez d’espace disque (> 8 Go).

## Licence

Ce projet est distribué sous licence MIT.

