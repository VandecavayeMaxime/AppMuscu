# AppMuscu — notes pour Claude

Application Android de suivi de musculation inspirée de Strong. Projet perso d'un **débutant en Flutter** : on travaille **en français**, on explique chaque notion nouvelle, et on garde l'interface minimaliste.

## Documents de référence (à tenir à jour)

- `docs/SPEC.md` : exigences (EX, WO, RT, TP, ST…), règles RG-xx, **journal des décisions §9** (D1…D12). Toute nouvelle décision de l'utilisateur y est notée.
- `docs/ARCHITECTURE.md` : stack, routes (§2), modèle de données et migrations (§3), points techniques (§4), stratégie et pièges de test (§5), **plan de développement §7** (jalons cochés ✅).
- `docs/INSTALLATION.md` : environnement Windows et dépannage (Avast, Android CLI, Xiaomi, débogage Wi-Fi).

## Conventions de code

- **Material : toujours `import 'package:material_ui/material_ui.dart'`**, jamais `package:flutter/material.dart` (Material est sorti du framework depuis Flutter 3.44 ; les deux copies ont des types incompatibles). Les helpers de `flutter_test` qui cherchent des widgets Material échouent (ex. `tester.pageBack()` → `tester.tap(find.byType(BackButton))`).
- **Riverpod 3** sans générateur (`Provider`, `StreamProvider`, `Notifier`, `.autoDispose.family`). `AsyncValue.value` (plus de `valueOrNull`). `when(skipLoadingOnReload: true)` pour éviter les clignotements.
- **Drift** : tables dans `lib/core/database/tables.dart`. Les `clientDefault` sont recopiés dans le code généré (tout ce qu'ils utilisent doit être public et importé dans `app_database.dart`). **Changer la structure** = incrémenter `schemaVersion`, `dart run build_runner build`, `dart run drift_dev make-migrations`, écrire `fromXToY` dans `app_database.dart`, compléter `test/drift/app_database/migration_test.dart`. Schéma actuel : **v4**.
- Architecture par fonctionnalité : `lib/features/<f>/{data,domain,presentation}`. Règles métier = fonctions pures dans `domain/` (testées sans Flutter). La base est la source de vérité ; l'UI observe des flux.
- Chaque écriture de séance met à jour `workouts.updated_at` (sync future). Suppressions douces sauf séance abandonnée.
- Chronomètres : `clockTickProvider` (toutes les 200 ms). Heure : `clock.now()` (package `clock`), jamais `DateTime.now()`.

## Commandes (PowerShell)

Le terminal de Claude doit d'abord recharger le PATH : `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::ExpandEnvironmentVariables([Environment]::GetEnvironmentVariable('Path','User'))`

- `dart format lib test` puis `flutter analyze` (doit afficher « No issues found! »)
- `flutter test --timeout 60s` (tous les tests doivent passer). Si `sqlite3.dll` est verrouillé : `Get-Process flutter_tester | Stop-Process -Force` (sans toucher aux processus `flutter_tools … daemon/debug_adapter` de VS Code).
- `dart run build_runner build` après modification des tables.
- `flutter build apk --debug --target-platform android-arm64`

## Tests

- Tests de widgets via `testApp(description, (tester) async {...}, setUp: (db) async {...})` dans `test/helpers/pump_app.dart` : app complète, base en mémoire, chronomètres figés, fausses notifications (`notificationsOf(tester)`) et fausse mise en veille (`screenAwakeOf(tester)`). L'app est démontée **dans** le test (minuteur Drift).
- Données de test : `test/helpers/test_database.dart` (`createTestDatabase()`, `addWorkout(db, day:, sets: [TestSet(80, 8)], …)`, `addTemplate(db, sets: [(80, 8)])`, `addEmptyTemplate(db)` (toute séance part d'un modèle : les tests de séance démarrent « Séance libre », un modèle vide), ids `benchPressId`, `squatId`, `pullUpId`).
- Sélecteur d'exercices : `checkExercise(tester, nom)` fait défiler la liste avant de cocher. Réorganiser : `dragUp(tester, nom)`.
- Pièges : un geste de balayage doit partir hors d'un champ texte ; attendre une écriture Drift avec `get()` plutôt que `watch().first` dans du code appelé depuis l'UI ; `pump()` après `enterText` avant un geste qui dépend de l'écran redessiné.

## Installation sur le téléphone (Redmi Note 13 Pro, Android 16, débogage **Wi-Fi**)

1. Compiler l'APK (commande ci-dessus).
2. Si `adb devices` ne montre pas le téléphone : `adb mdns services` → `adb connect <ip:port>` (port variable). S'il ne s'annonce pas, demander à l'utilisateur de réactiver « Débogage sans fil ». L'adresse courante est gardée dans `$env:TEMP\appmuscu\device.txt`.
3. `adb push <apk> /data/local/tmp/app-debug.apk` (depuis **PowerShell** : Git Bash déforme les chemins `/data/...`). Pour extraire `ip:port`, utiliser `[regex]::Match($line, '\S+$')` plutôt que `-split '\s+'` : combiné à `rm`, l'outil de sécurité le bloque.
4. **Attendre le « go » de l'utilisateur** : `pm install -r` déclenche une fenêtre Xiaomi « Installer » refusée au bout d'environ 10 s.
5. `adb shell am start -n com.maxime.app_muscu/.MainActivity`, puis `adb shell "rm -f /data/local/tmp/app-debug.apk"` et `logcat -c` pour pouvoir vérifier les erreurs après le test de l'utilisateur.

## Façon de travailler

Pour chaque jalon : écrire le code et les tests, vérifier (format, analyze, tests), compiler, copier l'APK, **demander le « go »**, installer, recueillir l'avis de l'utilisateur, ajuster, mettre à jour SPEC et ARCHITECTURE, puis **commit seulement quand l'utilisateur est d'accord** (messages en français, avec la ligne Co-Authored-By). Il n'y a pas de dépôt distant.
