# Installation de l'environnement Flutter (Windows → Android)

> ✅ **Installation terminée le 2026-09-26** : Flutter 3.47.5, `flutter doctor` sans problème, Redmi Note 13 Pro (Android 16) détecté.
> Durée estimée : **~1 h** (surtout des téléchargements, ~10 Go)
> Sources : [Flutter — Quick start](https://docs.flutter.dev/install/quick) · [Flutter — Android setup](https://docs.flutter.dev/platform-integration/android/setup)

## État actuel du PC

| Élément | État | Action |
|---|---|---|
| Windows 11 Famille 64 bits, Ryzen 7, 31 Go RAM, 329 Go libres | ✅ | — |
| Git 2.46 (nom et e-mail configurés) | ✅ | — |
| VS Code 1.124 | ✅ | — |
| winget | ✅ | — |
| Chemins longs Windows | ✅ activés | — |
| Virtualisation (pour l'émulateur) | ✅ activée | — |
| Chemins sans espaces ni accents (`C:\Users\Maxime\...`) | ✅ | — |
| **Mode développeur Windows** | ❌ désactivé | Étape 1 |
| **Extension Flutter pour VS Code** | ❌ absente | Étape 2 |
| **SDK Flutter** | ❌ absent | Étape 3 |
| **Android Studio + SDK Android** | ❌ absents | Étapes 4 et 5 |
| **Java 8** présent dans le PATH | ⚠️ piège possible | Étape 6 |
| Téléphone Android en débogage USB | ❓ | Étape 7 |

---

## Étape 1 — Activer le mode développeur Windows (2 min)

Flutter crée des liens symboliques pour ses plugins. Sans le mode développeur, tu auras l'erreur *« Building with plugins requires symlink support »*.

1. `Win + R`, tape `ms-settings:developers`, puis Entrée.
2. Active **Mode développeur** et confirme.

## Étape 2 — Installer l'extension Flutter dans VS Code (2 min)

1. Ouvre la [page de l'extension Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) et clique sur **Install**.
2. L'extension **Dart** s'installe avec, automatiquement.

*Autre méthode, dans un terminal : `code --install-extension Dart-Code.flutter`*

## Étape 3 — Installer le SDK Flutter depuis VS Code (10–15 min)

1. Crée le dossier `C:\Users\Maxime\dev`. Évite `Program Files` (droits administrateur) et tout chemin avec des espaces ou des accents.
2. Dans VS Code : `Ctrl + Shift + P`, tape `flutter`, puis choisis **Flutter: New Project**.
3. VS Code demande où est le SDK : clique sur **Download SDK**.
4. Choisis le dossier `C:\Users\Maxime\dev`, puis **Clone Flutter**. Le SDK s'installe dans `C:\Users\Maxime\dev\flutter`.
5. Attends la fin du téléchargement (« Downloading the Flutter SDK… »). S'il semble bloqué, clique sur **Cancel** et recommence.
6. Clique sur **Add SDK to PATH**.
7. VS Code enchaîne sur la création d'un projet : **annule avec Échap**. On créera le projet ensemble au jalon M0.
8. Un avertissement sur Android Studio peut s'afficher : ignore-le, c'est l'étape suivante.
9. **Ferme complètement VS Code et rouvre-le.** Dans un nouveau terminal, vérifie :
   ```
   flutter --version
   ```

*Autre méthode (téléchargement manuel du zip) : [docs.flutter.dev/install/manual](https://docs.flutter.dev/install/manual)*

## Étape 4 — Installer Android Studio (15–30 min)

1. Télécharge Android Studio sur [developer.android.com/studio](https://developer.android.com/studio). *Autre méthode, dans un terminal : `winget install -e --id Google.AndroidStudio`*
2. Installe-le avec les options par défaut ([guide d'installation](https://developer.android.com/studio/install)).
3. Au premier lancement, l'assistant de configuration démarre : choisis **Standard**, accepte les licences, puis **Finish**. Il télécharge le SDK Android dans `C:\Users\Maxime\AppData\Local\Android\Sdk`.

## Étape 5 — Compléter le SDK Android (10 min)

Dans Android Studio, sur l'écran d'accueil : **More Actions → SDK Manager**.

1. Onglet **SDK Platforms** : coche **Android 16.0 (API Level 36)**. Flutter 3.47 compile avec l'API 36, alors que l'assistant d'Android Studio n'installe que la plus récente (API 37). Garde les deux.
2. Onglet **SDK Tools** : coche les outils suivants, puis clique sur **Apply → OK → Finish** :
   - Android SDK Build-Tools
   - **Android SDK Command-line Tools** (indispensable pour l'étape 6)
   - Android Emulator
   - Android SDK Platform-Tools
   - CMake
   - NDK (Side by side)

Tu peux ensuite fermer Android Studio : on codera dans VS Code.

## Étape 6 — Accepter les licences Android (2 min)

Dans un **nouveau** terminal :

```
flutter doctor --android-licenses
```

Réponds `y` à chaque question, jusqu'au message `All SDK package licenses accepted.`

> ⚠️ **Piège Java 8.** Ton PC a Java 8 dans le PATH. Si tu vois l'erreur
> `UnsupportedClassVersionError … class file version 55.0 … only recognizes class file versions up to 52.0`,
> dis à Windows d'utiliser le Java fourni avec Android Studio. Dans PowerShell :
> ```powershell
> [Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Android\Android Studio\jbr', 'User')
> ```
> Ferme et rouvre le terminal, puis relance la commande. Si tu n'utilises pas Java 8 (aucune app ne le demande), tu peux aussi le désinstaller dans *Paramètres → Applications*.
> Voir aussi : [Flutter — Troubleshooting](https://docs.flutter.dev/install/troubleshoot)

## Étape 7 — Préparer le téléphone Android (5 min)

1. **Activer les options pour les développeurs** : dans *Paramètres → À propos du téléphone*, tape **7 fois** sur **Numéro de build**. Le chemin varie selon la marque (Samsung : *À propos du téléphone → Informations sur le logiciel → Numéro de version* ; Xiaomi : voir l'encadré). Guide : [Configure on-device developer options](https://developer.android.com/studio/debug/dev-options)
2. Dans *Paramètres → Options pour les développeurs*, active **Débogage USB**.

> 📱 **Xiaomi / Redmi / POCO (HyperOS ou MIUI), par exemple le Redmi Note 13 Pro**
> - Options développeur : *Paramètres → À propos du téléphone* → tape **7 fois** sur **Version de HyperOS** (ou *Version MIUI*).
> - Le menu se trouve ensuite dans *Paramètres → Paramètres supplémentaires → Options pour les développeurs*.
> - Active **Débogage USB**, **Installer via USB** (indispensable pour que Flutter puisse installer l'app ; demande un compte Xiaomi et parfois une carte SIM) et **Débogage USB (paramètres de sécurité)**.
> - Diagnostic : si Windows voit le téléphone comme « Redmi Note 13 Pro » (stockage) mais que `adb devices` reste vide, c'est que le débogage USB n'est pas actif.
3. Branche le téléphone au PC avec un **câble de données** (certains câbles ne font que charger).
4. Sur le téléphone, accepte **« Autoriser le débogage USB ? »** et coche **Toujours autoriser depuis cet ordinateur**.
5. Si le PC ne détecte pas le téléphone, installe le pilote USB de la marque : [Install OEM USB drivers](https://developer.android.com/studio/run/oem-usb)

### 7 bis. Débogage sans fil (méthode utilisée sur ce PC)

Le câble USB décrochait pendant les gros transferts (voir Dépannage), donc on passe par le Wi-Fi.

1. Le PC et le téléphone sont sur le **même Wi-Fi**.
2. Téléphone : *Options pour les développeurs → **Débogage sans fil*** → activer.
3. PC : trouver l'adresse annoncée par le téléphone, puis s'y connecter. Le port change à chaque activation.
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" mdns services
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" connect 192.168.129.3:<port>
   ```
   Ici, aucun code d'appairage n'a été nécessaire, car le PC avait déjà été autorisé en USB. Sinon : *Débogage sans fil → Associer l'appareil avec un code*, puis `adb pair <ip>:<port> <code>`.

Guide officiel : [débogage Wi-Fi](https://developer.android.com/studio/run/device#wireless)

## Étape 8 — Vérification finale

```
flutter doctor
flutter devices
```

Résultat attendu avec `flutter doctor` :

| Ligne | Attendu |
|---|---|
| Flutter | ✅ |
| Windows Version | ✅ |
| Android toolchain | ✅ |
| Android Studio | ✅ |
| VS Code | ✅ |
| Connected device | ✅ ton téléphone |
| Visual Studio (apps Windows) | peu importe, inutile pour nous (Build Tools 2022 déjà présents sur ce PC) |
| Chrome (web) | peu importe, inutile pour nous |

Avec `flutter devices`, ton téléphone doit apparaître avec la plateforme **android-arm64**.

*Optionnel : Flutter envoie des statistiques d'usage anonymes à Google. Pour les désactiver : `flutter --disable-analytics`.*

---

## Dépannage

### Première compilation : `PKIX path building failed` / `SSLHandshakeException`

**Cause :** l'antivirus (ici **Avast**, via son « Agent Web ») intercepte le HTTPS avec son propre certificat racine. Ce certificat est installé dans Windows, mais pas dans le Java utilisé par Gradle. Gradle ne peut alors rien télécharger.

**Correction appliquée sur ce PC :** on donne à Gradle une copie des certificats de Java, à laquelle on ajoute celui d'Avast. On ne peut pas simplement dire à Java d'utiliser le magasin de Windows (`trustStoreType=Windows-ROOT`), car le Java fourni avec Android Studio n'a pas le module nécessaire.

```powershell
$jbr = 'C:\Program Files\Android\Android Studio\jbr'
$store = "$env:USERPROFILE\.gradle\cacerts-avast"
Copy-Item "$jbr\lib\security\cacerts" $store -Force
& "$jbr\bin\keytool.exe" -importcert -noprompt -alias avast-web-mail-shield-root `
  -file 'C:\ProgramData\Avast Software\Avast\wscert.pem' -keystore $store -storepass changeit
```

Puis, dans `%USERPROFILE%\.gradle\gradle.properties` :
```properties
systemProp.javax.net.ssl.trustStore=C:/Users/Maxime/.gradle/cacerts-avast
systemProp.javax.net.ssl.trustStorePassword=changeit
```

⚠️ Il faut **refaire la commande** si Avast est réinstallé (il génère alors un nouveau certificat) ou si le problème revient après une mise à jour d'Android Studio.
*Autre solution : désactiver l'analyse HTTPS d'Avast (Paramètres → Protection → Agent Web).*

### Compilation : `sdkmanager.bat … finished with non-zero exit value` / « Package ndk not found »

**Cause :** Gradle essaie d'installer tout seul un composant manquant, par exemple le NDK dans la version attendue par Flutter (`28.2.13676358` pour Flutter 3.47). Il passe par `sdkmanager`, que Google a remplacé en 2026 par **Android CLI** (`android.exe`). Le script de transition `sdkmanager.bat` coupe le nom du paquet au `;` et plante.

**Correction :** installer le composant soi-même avec le nouvel outil, qui utilise `/` au lieu de `;` :
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\android.exe" sdk install ndk/28.2.13676358
```
Autres exemples : `platforms/android-36`, `build-tools/36.0.0`. Pour voir ce qui est disponible : `android.exe sdk list --all`.

### Installation sur le téléphone : bloquée, aucune fenêtre, « error: closed »

- **Xiaomi :** l'option *Installer via USB* doit être activée. Sinon l'installation échoue sans message. Chaque installation affiche une fenêtre de confirmation avec un **compte à rebours d'environ 10 s** : sans réponse, elle est refusée automatiquement.
- **Connexion USB qui décroche** sur les gros fichiers : le transport_id de `adb devices -l` augmente à chaque reconnexion, et un `adb push` de plus de 100 Mo se fige. Changer de câble ou de port, ou passer au **débogage sans fil** (étape 7 bis).

### Notification « Repos terminé » seulement quand l'app est ouverte (Xiaomi)

HyperOS **gèle** les apps en arrière-plan au bout de quelques secondes : l'alarme de fin de repos est mise de côté jusqu'à la réouverture de l'app. Dans les journaux (`adb logcat`), on voit `GreezeManager: FZ uid=… reason=tobg`, puis `cached alarm!`.

- Réglage à essayer : **Paramètres → Applications → AppMuscu → Économiseur de batterie → « Aucune restriction »**, et activer **Démarrage automatique**.
- La case « Suspendre l'activité de l'application si elle n'est pas utilisée » n'y change rien : elle concerne les apps inutilisées pendant des mois.
- Si le réglage ne suffit pas, la correction est côté app (voir docs/ARCHITECTURE.md, Minuteur de repos).

---

✅ **Quand tout est vert**, préviens Claude : il relancera les vérifications et on démarre le jalon **M0**.
