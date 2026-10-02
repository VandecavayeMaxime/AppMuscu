# AppMuscu — Spécification fonctionnelle (MVP)

> Statut : **brouillon à valider** · Dernière mise à jour : 2026-09-26
> Document compagnon : [ARCHITECTURE.md](ARCHITECTURE.md) (choix techniques, modèle de données, plan de développement)

---

## 1. Vision

Application mobile de suivi de musculation inspirée de **Strong** : noter vite ses séances en salle (exercices, séries, poids, répétitions), réutiliser des modèles de séance et gérer ses temps de repos. L'app fonctionne entièrement hors-ligne, répond vite et s'utilise d'une main entre deux séries.

### Objectifs du MVP

1. Enregistrer une séance complète plus vite que sur papier.
2. Toujours voir ce qu'on a fait **la dernière fois** sur un exercice (colonne « Précédent »).
3. Démarrer une séance type **en deux gestes** depuis un modèle (carte, puis « Démarrer »).
4. **Ne jamais perdre de données** (app fermée, batterie vide, appel entrant).

### Hors périmètre du MVP

Écran d'historique des séances, export/import, comptes / sync cloud, supersets, calculateur de disques, cardio avec distance, intégrations santé, iOS. Tout ça est listé dans la [roadmap v2](#8-roadmap-après-le-mvp).

> Même sans écran d'historique, les séances terminées sont **conservées en base** : c'est ce qui alimente la colonne « Précédent » et les statistiques.
>
> **Après le MVP** : l'onglet Stats (séances par semaine, carte des muscles, mesures corporelles) et l'onglet « Statistiques » de la fiche exercice (courbes, records) ont été ajoutés (§5.6, EX-12 à EX-15, D17).

## 2. Contexte et contraintes

| Contrainte | Valeur |
|---|---|
| Utilisateurs | 1 seul (usage perso / apprentissage), pas de compte |
| Technologie | Flutter (Dart) |
| Plateforme cible | **Android uniquement** (développement sous Windows, tests sur le téléphone Android du développeur) |
| Développeur | Débutant en Flutter : chaque jalon introduit et explique ses nouveaux concepts |
| Réseau | Aucun, 100 % hors-ligne. Données stockées localement (SQLite) |
| Évolutivité | Modèle de données conçu pour permettre une sync cloud en v2 sans migration destructive |
| Langue / unités | Interface en français, poids en kg |

## 3. Glossaire

| Terme | Définition |
|---|---|
| **Exercice** | Mouvement de la bibliothèque (ex. « Bench Press (Barbell) »). |
| **Séance** | Entraînement daté, avec une heure de début et de fin. |
| **Série** | Une ligne « poids × reps » (ou durée) d'un exercice dans une séance. |
| **Modèle** | Séance type réutilisable (ex. « Push ») : exercices et séries prévues. |
| **Précédent** | Valeurs de la série de même rang lors de la dernière séance contenant cet exercice. |
| **Placeholder** | Valeur grisée affichée dans un champ vide, reprise si on valide sans rien saisir. |
| **Temps de repos** | Durée de repos **propre à chaque série**. Le compte à rebours démarre quand on valide la série et s'affiche sur la ligne juste en dessous. |
| **Volume** | Σ (kg × reps) des séries validées. |
| **1RM estimé** | Charge qu'on pourrait soulever une seule fois, estimée à partir d'une série (RG-13). |
| **Muscles secondaires** | Muscles qu'un exercice fait travailler en plus de son groupe musculaire principal (triceps et épaules pour le développé couché). |
| **Mesure** | Valeur corporelle datée, saisie à la main : poids, masse grasse, masse musculaire ou tour (bras, taille…). |

## 4. Navigation et écrans

Barre d'onglets en bas, 4 entrées :

| Onglet | Contenu |
|---|---|
| **Séance** | Liste des modèles, création de modèle. Toute séance démarre d'un modèle |
| **Exercices** | Bibliothèque, recherche, filtres, exercices perso |
| **Stats** | Séances par semaine, carte des muscles travaillés, poids et mensurations (§5.6) |
| **Réglages** | Temps de repos par défaut, son et vibration, écran allumé, thème |

L'écran **Séance en cours** s'ouvre en plein écran par-dessus les onglets. On peut le réduire en une barre au-dessus des onglets, visible dans tous les onglets (WO-20) :

```
┌──────────────────────────────────┐
│ ▔▔▔▔▔▔▔▔▔▔▔▔▔░░░░░░░░░░ (repos)  │
│ Push                ⏱ 1:12    ˄  │
│ 32:15                            │
├──────────────────────────────────┤
│ Séance  Exercices  Stats Réglages│
└──────────────────────────────────┘
```

Toucher un exercice, dans la bibliothèque ou depuis une séance (WO-22), ouvre sa **fiche** avec une flèche de retour (EX-07) :

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ ←  Bench Press (Barbell)   ⋯  │      │ ←  Bench Press (Barbell)   ⋯  │
│[À propos] Historique Statistiques│      │À propos [Historique] Statistiques│
├──────────────────────────────────┤      ├──────────────────────────────────┤
│      ┌────────────────────┐      │      │ ┌──────────────────────────────┐ │
│      │  (image générique) │      │      │ │ Push                         │ │
│      └────────────────────┘      │      │ │ mercredi 23 septembre 2026   │ │
│ Groupe musculaire    Pectoraux   │      │ │  1   80 kg × 8    ★          │ │
│ Muscles second.  Triceps, Épaules│      │ │  2   82,5 kg × 6             │ │
│ Catégorie                Barre   │      │ │  3   80 kg × 6               │ │
│ Instructions                     │      │ └──────────────────────────────┘ │
│ 1. Allonge-toi sur le banc…      │      │ ┌──────────────────────────────┐ │
│                                  │      │ │ Séance du soir               │ │
│ Préférences                      │      │ │ lundi 21 septembre 2026      │ │
│ Unité                 [kg | lb]  │      │ │  1   77,5 kg × 8  ★          │ │
│ Minuteur de repos  Réglage global│      │ └──────────────────────────────┘ │
└──────────────────────────────────┘      └──────────────────────────────────┘
```

Le menu ⋯ (Modifier, Supprimer) n'existe que pour les exercices perso. Le 3e onglet, « Statistiques », est décrit plus bas (EX-12 à EX-15).

### Maquette : modèles (onglet Séance et éditeur)

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ Séance                           │      │ ←  Modifier le modèle  [Enreg.]  │
├──────────────────────────────────┤      ├──────────────────────────────────┤
│ Modèles              + Nouveau   │      │ Nom du modèle                    │
│ ┌──────────────────────────────┐ │      │ Push                             │
│ │ Push                      ⋯  │ │      │                                  │
│ │ 3 × Bench Press (Barbell) │ │      │ Bench Press (Barbell)      ⋯  │
│ │ 3 × Développé militaire      │ │      │ Série        kg        Reps      │
│ │ 4 × Squat (Barbell)            │ │      │   1       [ 80  ]    [  8  ]     │
│ │ Il y a 3 jours               │ │      │ ───────────── 2:00 ───────────── │
│ └──────────────────────────────┘ │      │   2       [ 80  ]    [  8  ]     │
│                                  │      │ ───────────── 2:00 ───────────── │
│                                  │      │        + Ajouter une série       │
│  toucher → aperçu + [▶ Démarrer] │      │    [ + Ajouter des exercices ]   │
└──────────────────────────────────┘      └──────────────────────────────────┘
```

Menu ⋯ d'une carte : Modifier, Dupliquer, Réorganiser, Supprimer (appui long sur une carte = Réorganiser). Menu ⋯ d'un exercice dans l'éditeur : Réorganiser, Retirer du modèle.

### Maquette : réorganiser les exercices (séance et éditeur de modèle)

```
Appui long sur le nom d'un exercice (ou ⋯ → Réorganiser) :
┌──────────────────────────────────┐
│ Glisse les exercices pour   [OK] │
│ changer leur ordre               │
├──────────────────────────────────┤
│ ≡  Bench Press (Barbell)      │
│ ≡  Squat (Barbell)                 │
│ ≡  Pull-Up                     │
└──────────────────────────────────┘
OK → les séries réapparaissent
```

### Maquette : onglet Stats (SA)

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ Stats                            │      │ Stats                            │
│  [Séances]   Muscles     Corps   │      │   Séances   [Muscles]    Corps   │
├──────────────────────────────────┤      ├──────────────────────────────────┤
│ Séances par semaine              │      │ 7 j  [30 j]  3 mois  1 an  Tout  │
│                              ░   │      │                                  │
│         ▒         ▒     ▓    ▒   │      │       Face            Dos        │
│    ▒    ▓    ░    ▓     ▒    ▓   │      │   (silhouette)   (silhouette)    │
│    ▓    ░    ▒    ░     ▓    ░   │      │     Peu ░░▒▒▓▓██ Beaucoup        │
│   ─────────────────────────────  │      │                                  │
│    août             sept.        │      │ Séries sur 30 jours              │
│ ▓ Push    ▒ Pull    ░ Jambes     │      │ Pectoraux     18   ████████████  │
│                                  │      │ Dos           15   ██████████    │
│ Semaine du 21 septembre          │      │ Triceps      9,5   ██████        │
│ Push      lun. 21    52 min   ›  │      │ Quadriceps     8   █████         │
│ Pull      mer. 23    48 min   ›  │      │ …                                │
│ Jambes    ven. 25    61 min   ›  │      │                                  │
└──────────────────────────────────┘      └──────────────────────────────────┘
 une barre par semaine, un bloc par         muscles colorés du gris (rien) au
 séance, couleur = modèle (RG-16)           rouge foncé (le plus travaillé)
```

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ Stats                            │      │ ←  Nouvelle mesure  [Enregistrer]│
│   Séances    Muscles    [Corps]  │      ├──────────────────────────────────┤
├──────────────────────────────────┤      │ Date           samedi 26 sept.   │
│ Poids                  78,4 kg › │      │                                  │
│ ▼ 1,2 kg en 30 jours             │      │ Poids (kg)             [ 78,4 ]  │
│ ‾‾╲__╱‾╲___╱‾╲____  (+ moyenne)  │      │ Masse grasse (%)       [ 15,2 ]  │
│ 1 mois  [3 mois]  1 an  Tout     │      │ Masse musculaire (kg)  [ 35,1 ]  │
│ Masse grasse     15,2 % ▼ 0,4  › │      │                                  │
│ Masse musculaire 35,1 kg ▲ 0,3 › │      │ Tours (cm)                       │
│                                  │      │ Cou                    [  38  ]  │
│  Cou 38 ────────  ◯              │      │ Poitrine               [ 102  ]  │
│  Poitrine 102 ── ╱█╲ ── Bras     │      │ Bras                   [ 38,5 ]  │
│  Taille 82 ▼1 ──  █     38,5 ▲0,5│      │ Taille                 [  82  ]  │
│  Hanches 96 ──── █ █             │      │ …                                │
│  Cuisse 58 ───── █ █ ── Mollet 38│      │                                  │
│                      [+ Mesure]  │      │ valeurs grisées = dernière mesure│
└──────────────────────────────────┘      └──────────────────────────────────┘
 toucher une mesure → sa page (SA-08)        seuls les champs remplis comptent
```

### Maquette : fiche exercice, onglet « Statistiques » (EX-12 à EX-15)

```
┌──────────────────────────────────┐
│ ←  Bench Press (Barbell)   ⋯  │
│À propos  Historique [Statistiques]
├──────────────────────────────────┤
│ [1RM estimé]  Poids max  Volume  │
│ 105 ┤                 •──•       │
│ 100 ┤       •──•──•──╱           │
│  95 ┤ •──•─╱                     │
│     └─────────────────────────   │
│ 3 mois   [1 an]   Tout           │
│                                  │
│ Records                          │
│ 1RM estimé     105 kg   12 sept. │
│ Poids max      92,5 kg   5 sept. │
│ Meilleure série 85 kg × 8        │
│ Meilleur volume 2 480 kg         │
│                                  │
│ Records par nombre de reps       │
│ Reps   Poids       Date          │
│  1     100 kg      12 sept.      │
│  5     90 kg       29 août       │
│  8     85 kg       12 sept.      │
│                                  │
│ Fréquence                        │
│ 24 séances · 1,8 par semaine     │
│ Dernière fois : il y a 3 jours   │
└──────────────────────────────────┘
```

### Maquette : séance en cours

```
┌────────────────────────────────────────────┐
│ ⌄   Séance du matin            [Terminer]  │
│     Durée 00:42:17                         │
├────────────────────────────────────────────┤
│ Bench Press (Barbell)              ⋯    │
│ Série   Précédent     kg     Reps     ✓    │
│  1      80 × 8        82,5   8       [✓]   │  ← série validée (colorée)
│  ─────────────── ✓ 1:30 ───────────────    │  ← repos terminé (surligné comme la série)
│  2      80 × 8        82,5   7       [✓]   │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░ 1:23 ░░░░░░░░░░░░░░░░    │  ← repos en cours (progression)
│  3      80 × 7        82,5   6       [ ]   │
│  ──────────────── 2:00 ────────────────    │  ← repos prévu
│  4      77,5 × 6      77,5   6       [ ]   │  ← placeholders grisés
│  ──────────────── 2:00 ────────────────    │  ← repos avant l'exercice suivant
│            + Ajouter une série             │
├────────────────────────────────────────────┤
│ Barbell Row                        ⋯    │
│  ...                                       │
│         [ + Ajouter des exercices ]        │
│         [ Annuler la séance ]              │
└────────────────────────────────────────────┘
```

**Légende des lignes de repos** (RT-03) : chaque série est suivie de sa ligne de repos.

| Dans la maquette | État | Dans l'app |
|---|---|---|
| `──── 2:00 ────` | prévu | Temps de repos de la série, affiché discrètement |
| `▓▓▓▓░░░░ 1:23` | en cours | Barre de progression qui se remplit (▓ = temps écoulé, ░ = temps restant) avec le temps restant |
| `── ✓ 1:30 ──` | terminé | ✓, ligne surlignée de la même couleur que la série validée |

Chaque série a son propre temps de repos : ici 1:30 après la 1re série, 2:00 après les suivantes.

## 5. Exigences fonctionnelles

Priorités : **M** = Must (indispensable au MVP) · **S** = Should (MVP si le temps le permet) · **C** = Could (bonus)

### 5.1 Bibliothèque d'exercices (EX)

| ID | Exigence | Prio |
|---|---|---|
| EX-01 | L'app est livrée avec les **10 exercices de base** listés ci-dessous. *Complétés à 83 par D21 : liste exhaustive dans `lib/core/database/seed/built_in_exercises.dart`, chaque groupe musculaire de la carte des muscles (SA-04) ayant au moins deux exercices.* | M |
| EX-02 | Liste alphabétique avec recherche par nom, insensible à la casse et aux accents (« developpe » trouve « Développé couché »). | M |
| EX-03 | Filtres par groupe musculaire et par équipement. | S |
| EX-04 | Créer un exercice perso : nom, groupe musculaire, muscles secondaires (facultatifs, plusieurs possibles), catégorie (= équipement), type de suivi, instructions (facultatif). | M |
| EX-05 | Modifier ou supprimer un exercice perso, depuis le menu ⋯ de sa fiche. Un exercice supprimé est **archivé** : il disparaît de la bibliothèque mais reste en base avec les séances et modèles qui l'utilisent. | M |
| EX-06 | Le nom d'un exercice actif est unique (sans tenir compte de la casse ni des accents). | S |
| EX-07 | **Fiche exercice.** Toucher n'importe quel exercice ouvre sa fiche (avec retour arrière), qui a trois onglets : « À propos » (EX-09), « Historique » (EX-10) et « Statistiques » (EX-12 à EX-15). | M |
| EX-08 | **Préférences par exercice**, réglables pour tous les exercices, intégrés compris : unité des poids (kg ou lb, kg par défaut, masquée pour les exercices sans poids) et minuteur de repos (réglage global, désactivé, ou de 0:30 à 5:00). | M |
| EX-09 | **Onglet « À propos »** : image du mouvement (générique pour l'instant), groupe musculaire, muscles secondaires, catégorie, note (EX-11), instructions (fournies pour les exercices intégrés, saisies pour les exercices perso), préférences (EX-08). | M |
| EX-10 | **Onglet « Historique »** : un bloc par séance terminée où l'exercice a au moins une série validée, de la plus récente à la plus ancienne. Chaque bloc affiche le nom de la séance, la date et les séries validées (RG-02), avec la meilleure série marquée ★ (RG-13). | M |
| EX-11 | **Note d'exercice** : une note libre (réglage de la machine, sensations…) attachée à l'exercice lui-même, intégré ou perso. Elle s'ajoute ou se modifie depuis la fiche (section « Note »), depuis la séance ou depuis l'éditeur de modèle (menu ⋯), et elle est enregistrée tout de suite. Elle s'affiche sous le nom de l'exercice en séance et dans l'éditeur. | M |
| EX-12 | **Onglet « Statistiques » : courbe d'évolution.** Un point par séance de l'historique (EX-10). La valeur suivie se choisit selon le type de suivi : poids + reps → 1RM estimé (de la meilleure série, RG-13), poids max, volume de la séance (RG-01) ; reps seules → reps max d'une série, reps de la séance ; durée → durée max d'une série, durée de la séance. Période : 3 mois, 1 an (au départ) ou tout. Toucher un point affiche sa date et sa valeur. Sans historique : « Pas encore de statistiques ». | S |
| EX-13 | **Records** : les meilleures valeurs de tout l'historique, avec leur date. Poids + reps : 1RM estimé (avec la série qui l'a donné), poids max, meilleure série en volume (kg × reps), meilleur volume sur une séance. Reps seules : reps max d'une série, reps max sur une séance. Durée : durée max d'une série, durée max sur une séance. | S |
| EX-14 | **Records par nombre de reps** (poids + reps seulement) : pour chaque nombre de reps, le meilleur poids soulevé et sa date, seulement pour les vrais records (RG-18). | C |
| EX-15 | **Fréquence** : nombre de séances avec l'exercice, moyenne par semaine (RG-19), dernière fois (« Il y a 3 jours »). | C |

**Bibliothèque initiale**

| Exercice | Groupe musculaire | Muscles secondaires | Équipement | Type de suivi |
|---|---|---|---|---|
| Bench Press (Barbell) | Pectoraux | Triceps, Épaules | Barre | Poids + reps |
| Squat (Barbell) | Quadriceps | Fessiers, Ischios | Barre | Poids + reps |
| Deadlift (Barbell) | Lombaires | Fessiers, Ischios, Avant-bras | Barre | Poids + reps |
| Overhead Press (Barbell) | Épaules | Triceps | Barre | Poids + reps |
| Barbell Row | Dorsaux | Biceps, Épaules | Barre | Poids + reps |
| Leg Press | Quadriceps | Fessiers, Ischios | Machine | Poids + reps |
| Bicep Curl (Dumbbell) | Biceps | Avant-bras | Haltères | Poids + reps |
| Tricep Pushdown (Cable) | Triceps | — | Poulie | Poids + reps |
| Pull-Up | Dorsaux | Biceps, Avant-bras | Poids du corps | Reps seules |
| Plank | Abdos | — | Poids du corps | Durée |

**Types de suivi (MVP)**

| Type | Colonnes saisies | Exemples |
|---|---|---|
| Poids + reps | kg, reps | Développé couché, Squat |
| Reps seules | reps | Pull-Up |
| Durée | mm:ss | Gainage |

*Lest/assistance (± kg) et distance + durée arrivent en v2.*

**Équipements** (appelés « Catégorie » dans l'interface) **:** Barre, Haltères, Machine, Poulie, Kettlebell, Poids du corps, Élastique, Autre.
**Groupes musculaires :** Pectoraux, Trapèzes, Dorsaux, Lombaires, Épaules, Biceps, Triceps, Avant-bras, Abdos, Obliques, Quadriceps, Adducteurs, Ischios, Fessiers, Mollets, Corps entier, Cardio, Autre. *Depuis D20, « Dos » et « Abdos » et « Quadriceps » sont chacun devenus plusieurs groupes plus précis.* Les muscles secondaires se choisissent dans la même liste (sans le groupe principal, sans « Corps entier », « Cardio » ni « Autre »).

### 5.2 Séance en cours (WO)

| ID | Exigence | Prio |
|---|---|---|
| WO-01 | Une séance démarre toujours **depuis un modèle** (TP-05) et prend son nom, qui reste modifiable. *Plus de séance vide (D14).* | M |
| WO-02 | Une seule séance en cours à la fois. Si on en démarre une autre, l'app propose : « Reprendre la séance en cours » ou « L'abandonner et démarrer ». | M |
| WO-03 | Un chronomètre affiche le temps écoulé depuis le début de la séance. | M |
| WO-04 | Ajouter un ou plusieurs exercices via un sélecteur multi-sélection : c'est **l'onglet Exercices** lui-même (recherche, filtres, création), avec une case à cocher par exercice. Toucher le nom d'un exercice ouvre sa fiche, la case le sélectionne ; la sélection est conservée au retour de la fiche. Un exercice créé depuis le sélecteur est coché d'office. Chaque exercice ajouté arrive avec 1 série vide. Même sélecteur dans l'éditeur de modèle. | M |
| WO-05 | Chaque exercice affiche un tableau de séries : Série, Précédent, colonnes du type de suivi, case de validation ✓. Chaque série est suivie de sa ligne de repos (RT-03). | M |
| WO-06 | La colonne **Précédent** affiche les valeurs de la série de même rang lors de la dernière séance contenant l'exercice (RG-03, RG-04), ou « — » si aucune. Taper dessus recopie ces valeurs dans la série. | M |
| WO-07 | Les nombres se saisissent au pavé numérique. Le poids accepte les décimales, avec la virgule ou le point. Un champ vide affiche un placeholder grisé (RG-11). | M |
| WO-08 | **Valider une série** (✓) enregistre l'heure de validation, colore la ligne et lance le minuteur de repos. Un champ vide qui a un placeholder prend sa valeur. S'il reste un champ vide sans placeholder, la validation est refusée et le champ est signalé. | M |
| WO-09 | Retaper ✓ dévalide la série. | M |
| WO-10 | « + Ajouter une série » ajoute une série vide en bas de l'exercice. Elle reprend le temps de repos de la série au-dessus (RG-12). | M |
| WO-11 | Supprimer une série en la balayant vers la gauche, depuis la colonne « Série » ou « Précédent » : sur un champ de saisie, le glissement sélectionne du texte. Les séries sont renumérotées automatiquement. | M |
| WO-13 | Le menu ⋯ d'un exercice permet d'ajouter ou modifier **sa note** (EX-11, celle de l'exercice, pas de la séance), de le réorganiser (WO-15) et de le retirer de la séance. | M |
| WO-14 | Remplacer un exercice par un autre en gardant les séries (depuis le menu ⋯). | C |
| WO-15 | Réordonner les exercices par glisser-déposer : un appui long sur le nom d'un exercice (ou ⋯ → « Réorganiser ») réduit tous les exercices à une ligne ; on les fait glisser par la poignée ≡, puis « OK » rend l'affichage normal. Même geste dans l'éditeur de modèle. | S |
| ~~WO-16~~ | ~~Ajouter une note à la séance.~~ *Abandonnée (D16) : seule la note d'exercice (EX-11) existe.* | — |
| WO-17 | **Terminer la séance.** Une série non validée est dite *remplie* si toutes les valeurs de son type de suivi sont saisies (kg et reps, reps, ou durée). Les séries non validées vides ou incomplètes sont supprimées sans rien demander. S'il reste des séries remplies, une fenêtre simple, sans détail série par série, propose « Compléter » (les valider), « Jeter » (seulement s'il y a déjà au moins une série validée) ou « Annuler ». Les exercices qui n'ont plus aucune série sont retirés. S'il n'y a ni série validée ni série remplie, la séance ne peut pas être terminée : l'app propose de l'abandonner. | M |
| WO-18 | Après la fin, un **écran de résumé** affiche le nom, la date et les horaires (début → fin), la durée, le nombre d'exercices et de séries, et le volume total. Puis, pour chaque exercice : toutes ses séries validées (★ = meilleure, RG-13) et la **comparaison avec la dernière fois**, c'est-à-dire l'évolution du total (volume en kg, reps ou durée selon le type de suivi) avec son écart, et celle de la meilleure série (▲ / ▼ / =), avec la meilleure série de la dernière fois. « Première fois avec cet exercice » s'il n'y a pas de séance précédente. | M |
| WO-19 | Abandonner la séance (avec confirmation) la supprime définitivement. | M |
| WO-20 | Réduire la séance (« ˅ ») en une barre au-dessus des onglets, visible dans tous les onglets tant que la séance est en cours : nom, chrono, compteur et barre de progression du repos en cours. La toucher rouvre la séance, à la hauteur du repos en cours s'il y en a un. | S |
| WO-21 | **Persistance :** chaque modification est enregistrée immédiatement. Si l'app est tuée, on retrouve la séance intacte au redémarrage, avec la barre de séance réduite (WO-20). | M |
| WO-22 | Toucher le nom d'un exercice en séance ouvre sa fiche (EX-07), pour revoir son historique entre deux séries. Le menu Modifier / Supprimer y est masqué, pour ne pas quitter la séance par erreur. | M |
| WO-23 | **Supprimer une séance terminée** : dans l'onglet Stats, appui long sur une séance de la liste de la semaine (SA-03) → petit menu → « Supprimer la séance ». Pas de confirmation : le message « Séance supprimée » propose « Annuler » et se referme de lui-même après 3 s ; son fond se remplit d'une teinte plus claire, de gauche à droite, pour montrer le temps restant. Une fois refermé, la séance ne peut plus être récupérée. Elle disparaît des statistiques, de l'historique des exercices, de la colonne « Précédent » et de la date de dernière utilisation du modèle (suppression douce, RG-10, qui ne sert qu'à préparer une future synchronisation). | S |

### 5.3 Minuteur de repos (RT)

| ID | Exigence | Prio |
|---|---|---|
| RT-01 | Le temps de repos se définit **par série**. Une série sans valeur propre prend celle de l'exercice en bibliothèque, sinon le réglage global (2:00 par défaut). Voir RG-09. La valeur 0 désactive le minuteur pour cette série. | M |
| RT-02 | Valider une série démarre le minuteur de repos **de cette série**, avec son temps de repos. Un seul minuteur tourne à la fois : si on valide une autre série, le repos en cours s'arrête et le nouveau démarre sous la série qu'on vient de valider. Dévalider une série dont le repos tourne arrête le minuteur. | M |
| RT-03 | **Une ligne de repos suit chaque série**, y compris la dernière d'un exercice. Elle a trois états : **prévu** (temps de repos affiché discrètement, avant validation), **en cours** (barre de progression et temps restant, après validation), **terminé** (✓, surligné de la même couleur que la série validée, une fois le temps écoulé). | M |
| RT-04 | La ligne de repos **n'a aucun bouton**. Pour écourter un repos, il suffit de valider la série suivante (RT-02). Terminer ou abandonner la séance arrête aussi le minuteur. | M |
| RT-05 | À la fin du repos, une notification « Repos terminé — Prochaine série : *exercice* » s'affiche avec le son et la vibration du téléphone, que l'app soit ouverte, en arrière-plan ou l'écran verrouillé. L'autorisation d'afficher des notifications est demandée au lancement de l'app (Android ne pose la question qu'une fois). Son et vibration se coupent dans les réglages (ST-02). | M |
| RT-06 | Le minuteur reste exact quand l'app passe en arrière-plan, est tuée ou que l'écran se verrouille, car il repose sur une heure de fin absolue et non sur un décompte. | M |
| RT-07 | Taper sur une ligne de repos permet de modifier le temps de repos **de cette série**, avec une option « Appliquer à toutes les séries de l'exercice ». | M |
| RT-08 | Si la ligne de repos en cours sort de l'écran (défilement) ou si la séance est réduite (WO-20), un compteur compact « ⏱ 1:12 » s'affiche dans l'en-tête ou la barre réduite. Un tap dessus ramène à la ligne. | S |
| RT-09 | Dans le réglage de RT-07 (séance ou éditeur de modèle), une case « Enregistrer comme défaut de l'exercice » met aussi à jour la bibliothèque, tout de suite. Quand elle est cochée, le choix « Par défaut » disparaît. | C |
| RT-10 | Toucher la notification « Repos terminé » ouvre la séance en cours, que l'app soit en arrière-plan, sur un autre onglet ou fermée. Rien ne change si la séance est déjà affichée ou s'il n'y a plus de séance en cours. | S |

### 5.4 Modèles (TP)

| ID | Exigence | Prio |
|---|---|---|
| TP-01 | Créer un modèle : nom, exercices ordonnés (glisser-déposer, comme WO-15), séries prévues (kg, reps ou durée, **temps de repos**), toutes facultatives. L'éditeur a la présentation de la séance, sans « Précédent » ni case ✓. Il faut un nom et au moins un exercice ; chaque exercice garde au moins une série. Les modifications ne sont enregistrées qu'avec « Enregistrer » ; quitter avant demande confirmation. | M |
| TP-02 | L'onglet Séance liste les modèles. Chaque carte affiche le nom, un aperçu des exercices, un par ligne (« 3 × Développé couché », « 4 × Squat »…) et la date de dernière utilisation (« Hier », « Il y a 3 jours », « Jamais utilisé »). | M |
| TP-03 | Modifier, renommer ou supprimer un modèle (avec confirmation), depuis le menu ⋯ de sa carte. Supprimer un modèle ne touche pas aux séances passées. | M |
| TP-04 | Dupliquer un modèle (« Push (copie) », en fin de liste). | S |
| TP-05 | **Démarrer une séance depuis un modèle** : toucher la carte ouvre un aperçu avec « Démarrer la séance » (WO-02 s'applique). La séance reprend le nom, les exercices et les séries (nombre, temps de repos) du modèle. Les kg/reps du modèle deviennent les placeholders (RG-11) ; ils sont copiés dans la séance, que modifier le modèle ensuite ne change pas. | M |
| ~~TP-06~~ | ~~Créer un modèle à partir d'une séance terminée.~~ *Supprimée (D14) : toute séance vient d'un modèle.* | — |
| TP-07 | Quand une séance issue d'un modèle diffère de ce modèle (exercices, ordre, nombre de séries, valeurs réalisées ou temps de repos), le résumé affiche « La séance diffère du modèle » avec un bouton « Mettre à jour le modèle ». Le modèle prend alors les séries validées de la séance. Sans action, il ne change pas. | S |
| TP-08 | Réordonner les modèles : appui long sur une carte (ou ⋯ → « Réorganiser »), les modèles se réduisent à une ligne, on les fait glisser par la poignée ≡, puis « OK » (même geste que WO-15). | C |

### 5.5 Réglages (ST)

| ID | Exigence | Prio |
|---|---|---|
| ST-01 | Régler le temps de repos global par défaut (2:00 au départ, « Sans repos » possible). Il vaut pour les exercices sans temps de repos propre (RG-09). | M |
| ST-02 | Activer ou désactiver le son et la vibration de fin de repos (deux interrupteurs, activés au départ). Le changement vaut à partir du repos suivant. | M |
| ST-03 | Thème clair, sombre ou selon le système (au départ). | S |
| ST-04 | Garder l'écran allumé tant qu'une séance est en cours (désactivé au départ). | C |

### 5.6 Onglet Stats (SA)

| ID | Exigence | Prio |
|---|---|---|
| SA-01 | Un onglet **Stats**, entre Exercices et Réglages, avec trois sous-onglets : « Séances », « Muscles » et « Corps ». | M |
| SA-02 | **Séances par semaine** : un diagramme en barres, une barre par semaine (du lundi au dimanche), qui empile un bloc de même hauteur par séance terminée. Chaque bloc prend la couleur du modèle de la séance (RG-16), avec une légende. Les 12 dernières semaines sont visibles, la semaine en cours à droite ; on glisse vers la gauche pour voir les plus anciennes. | M |
| SA-03 | Sous le diagramme, les séances de la semaine sélectionnée (la semaine en cours au départ ; toucher une barre en sélectionne une autre) : nom, jour, durée. Toucher une séance ouvre son résumé (WO-18) en lecture seule : flèche de retour, sans bouton « OK » ni proposition de mise à jour du modèle. Un appui long sur une séance permet de la supprimer (WO-23). | S |
| SA-04 | **Carte des muscles** : deux silhouettes (face et dos) dont chaque muscle est coloré selon ses séries de la semaine affichée (RG-17), avec un repère propre à chaque muscle plutôt qu'un maximum relatif (RG-23) : gris (pas travaillé), puis 3 couleurs franches sans dégradé (bleu : bas, vert : optimal, orange : élevé — l'orange plutôt qu'un rouge, un volume élevé n'étant pas forcément un problème). **Une semaine à la fois, du lundi au dimanche** : glisser sur les silhouettes change de semaine (vers la droite pour reculer, vers la gauche pour avancer, jamais de semaine future), avec un raccourci pour revenir à la semaine en cours. Légende : un point de chaque couleur, avec son mot (Bas / Optimal / Élevé). | M |
| SA-05 | Sous les silhouettes, les groupes musculaires travaillés sur la semaine, du plus au moins travaillé : nom, nombre de séries (RG-17), puis une échelle des 3 zones (RG-23) avec les 2 seuils chiffrés et un repère à la position du muscle. Toucher un muscle sur une silhouette met sa ligne en avant. Semaine sans aucune série validée : la carte reste affichée, tout en gris, avec un message sous la liste. | S |
| SA-06 | **Nouvelle mesure** : « + Mesure » ouvre un formulaire daté du jour (date modifiable) : poids (kg), masse grasse (%), masse musculaire (kg) et tours en cm (cou, poitrine, bras, avant-bras, taille, hanches, fesses, cuisse, mollet). Tous les champs sont facultatifs, mais il faut au moins une valeur (RG-22). Chaque champ affiche en grisé sa dernière valeur, qui n'est **pas** enregistrée si on n'y touche pas. | M |
| SA-07 | **Sous-onglet « Corps »** : la courbe du poids avec sa moyenne lissée (RG-20) et sa période (1 mois, 3 mois au départ, 1 an), la dernière valeur en gros et son écart (RG-21) ; la masse grasse et la masse musculaire (dernière valeur et écart) ; puis les tours, écrits autour de la silhouette neutre de la carte des muscles (D26), chacun avec sa valeur et son écart. Seules les mesures déjà saisies apparaissent ; sans aucune mesure, un message invite à en ajouter. | M |
| SA-08 | Toucher une mesure ouvre sa page : la courbe en grand (avec sa période), puis toutes ses valeurs, de la plus récente à la plus ancienne. Toucher une valeur permet de la modifier ; la balayer vers la gauche la supprime. | S |

## 6. Règles de gestion

| ID | Règle |
|---|---|
| RG-01 | **Volume** = Σ (kg × reps) des séries **validées**, toujours calculé en kg. Les exercices « reps seules » et « durée » ne comptent pas. |
| RG-02 | **Numérotation** : les séries d'un exercice sont numérotées 1, 2, 3… dans l'ordre. |
| RG-03 | **Correspondance « Précédent »** : la k-ième série d'un exercice (tous types confondus, dans l'ordre) correspond à la k-ième série du même exercice dans la séance de référence (RG-04). |
| RG-04 | **Séance de référence** d'un exercice : la séance terminée et non supprimée la plus récente (par date de début) qui contient au moins une série validée de cet exercice. La séance en cours est exclue. |
| RG-05 | **Nom d'une séance** = nom du modèle dont elle démarre. *(Le nom selon l'heure, « Séance du soir »…, a disparu avec la séance vide, D14.)* |
| RG-06 | **Bornes de saisie** : poids de 0 à 1 000 kg, au centième près. Reps : entier de 0 à 999. Durée : de 0 s à 23:59:59. Temps de repos : de 0 s à 10:00, par pas de 5 s. |
| RG-07 | **Durée de séance** = heure de fin − heure de début. |
| RG-08 | Une séance terminée contient au moins une série validée. |
| RG-09 | **Temps de repos effectif d'une série** = sa valeur propre si elle est définie, sinon le temps par défaut de l'exercice en bibliothèque, sinon le réglage global. |
| RG-10 | Les suppressions sont « douces » en base (marquées, pas effacées) pour préparer la sync. L'utilisateur ne voit pas la différence. Exception : une séance abandonnée est effacée pour de bon. |
| RG-11 | **Placeholder d'un champ**, champ par champ = valeur prévue dans le modèle si elle existe, sinon valeur « Précédent », sinon rien. |
| RG-12 | Une série ajoutée reprend le temps de repos propre de la série au-dessus. S'il n'y en a pas, elle n'a pas de valeur propre et RG-09 s'applique. |
| RG-13 | **Meilleure série** d'une séance (en cas d'égalité, la première) : poids + reps → le 1RM estimé le plus élevé (formule d'Epley : kg × (1 + reps / 30), ce qui permet de comparer 100 kg × 5 et 90 kg × 10) ; reps seules → le plus de reps ; durée → la plus longue. |
| RG-14 | **Unités** : les poids sont toujours enregistrés en kg. Ils sont saisis et affichés dans l'unité de l'exercice (1 lb = 0,45359237 kg), avec la virgule française et au plus 2 décimales. |
| RG-15 | Dans l'éditeur de modèle, une série ajoutée est la copie de celle du dessus (valeurs prévues et temps de repos). |
| RG-16 | **Couleur d'une séance** (SA-02) : celle de son modèle, prise dans une palette de 8 couleurs selon l'ordre des modèles (1er modèle → 1re couleur…, puis la palette recommence). Les modèles supprimés viennent après les modèles actifs. Réordonner les modèles change donc leurs couleurs. Une séance sans modèle (créée avant D14) est grise, « Autres » dans la légende. La légende donne le nom actuel du modèle. |
| RG-17 | **Séries par muscle** (SA-04, SA-05) : chaque série validée d'une séance terminée compte 1 pour le groupe musculaire principal de l'exercice et ½ pour chacun de ses muscles secondaires. Sur les silhouettes, « Épaules » colore les deltoïdes (face et dos, un seul groupe) ; « Corps entier », « Cardio » et « Autre » n'apparaissent que dans la liste. |
| RG-18 | **Records par nombre de reps** (EX-14) : pour chaque nombre de reps N, le meilleur poids soulevé en exactement N reps (séries à 0 kg ou 0 rep ignorées). La ligne ne s'affiche que si ce poids dépasse celui de toutes les lignes à plus de reps : 100 kg × 5 rend inutile « 95 kg × 3 ». Date = la première fois que ce record a été atteint. |
| RG-19 | **Fréquence moyenne** (EX-15) = nombre de séances ÷ nombre de semaines entre la première séance et aujourd'hui (au moins 1), arrondi à une décimale. |
| RG-20 | **Moyenne lissée du poids** (SA-07) : pour chaque pesée, la moyenne des pesées des 7 derniers jours, celle-ci comprise. Elle gomme les variations d'un jour à l'autre (eau, repas). |
| RG-21 | **Écart d'une mesure** (▲ / ▼ / =) = dernière valeur − valeur de référence. Poids, masse grasse et masse musculaire : la référence est la dernière mesure datée d'il y a au moins 30 jours (« en 30 jours ») ; s'il n'y en a pas, la première mesure (« depuis le 12 sept. »). Tours : la première mesure. Pas d'écart avec une seule mesure. |
| RG-22 | **Bornes des mesures** : poids et masse musculaire de 1 à 500 kg, masse grasse de 1 à 100 %, tours de 1 à 300 cm, au centième près. Une mesure a au plus une valeur par jour et par type : en saisir une autre le même jour la remplace. |
| RG-23 | **Repère par muscle** (SA-04, SA-05, D22) : un nombre de séries par semaine bas et un haut, propres à chaque muscle (ex. pectoraux 6 et 20, épaules 6 et 26), plutôt qu'un maximum relatif entre muscles. En dessous du repère bas : insuffisant. Entre les deux : correct à optimal. Au-delà (jusqu'à une fois et demie le repère haut, où la couleur est plafonnée) : volume élevé. Popularisés par le Dr Mike Israetel (Renaissance Periodization) à partir des méta-analyses de Schoenfeld sur le volume d'entraînement : des repères de coach, pas une mesure exacte, ajustables dans `muscleVolumeLandmarks`. |

## 7. Exigences non fonctionnelles (NF)

| ID | Catégorie | Exigence |
|---|---|---|
| NF-01 | Hors-ligne | Toutes les fonctionnalités marchent sans réseau. L'app ne fait aucun appel réseau. |
| NF-02 | Durabilité | Chaque action est écrite en base immédiatement. Aucune perte de données si l'app est tuée. |
| NF-03 | Réactivité | Valider une série ou saisir une valeur donne un retour visuel en moins de 100 ms. Démarrage à froid en moins de 2 s sur un téléphone milieu de gamme. |
| NF-04 | Ergonomie | Utilisable d'une main. Cibles tactiles ≥ 48 dp. Valider une série déjà remplie tient en 1 tap. |
| NF-05 | Lisibilité | Mode sombre soigné (usage en salle), contrastes conformes WCAG AA. |
| NF-06 | Compatibilité | Android 8.0 (API 26) minimum. iOS hors périmètre. |
| NF-07 | Évolutivité | Identifiants UUID, horodatages de création et de modification, suppressions douces, pour une sync cloud en v2. |
| NF-08 | Migrations | Schéma de base versionné. Chaque mise à jour de l'app migre les données sans perte. |
| NF-09 | Qualité | Règles métier couvertes par des tests unitaires, parcours « séance complète » couvert par un test widget, `flutter analyze` sans avertissement. |
| NF-10 | Vie privée | L'app n'envoie aucune donnée. Seule la sauvegarde automatique d'Android (sur le compte Google de l'utilisateur) peut copier la base. |

## 8. Roadmap après le MVP

- **Historique :** liste des séances, détail, modification, suppression, refaire une séance
- **Données :** export/import JSON, export CSV
- **Fiche exercice :** vraies images ou vidéos des mouvements ; badge « PR » pendant la séance *(courbes et records : faits, EX-12 à EX-15)*
- **Statistiques :** volume par semaine, records récents, exercices les plus faits, durée moyenne des séances *(séances par semaine, carte des muscles : faits, SA)*
- **Mesures corporelles :** photos de progression *(poids, masse grasse, masse musculaire, tours : faits, SA-06 à SA-08)*
- **Séance :** supersets et circuits, calculateur de disques, séries d'échauffement suggérées
- **Types de suivi :** lest/assistance (± kg), distance + durée (cardio)
- **Organisation :** dossiers de modèles, programmes sur plusieurs semaines
- **Bibliothèque :** enrichir la liste d'exercices intégrés
- **Cloud :** comptes et synchronisation multi-appareils (ex. Supabase)
- **Plateformes et intégrations :** widget d'écran d'accueil *(iOS : ébauche en place, jamais testée en vrai sans Mac ; Health Connect/Apple Santé : faits, D36)*

## 9. Décisions

| # | Question | Décision (2026-09-26) |
|---|---|---|
| D1 | Plateforme | Flutter, Android uniquement |
| D2 | Stockage | Local d'abord (SQLite), sync cloud possible en v2 |
| D3 | Périmètre MVP | Séance + modèles + minuteur de repos. Historique et export repoussés en v2 |
| D4 | Temps de repos | Défini par série, affiché sur une ligne sous chaque série, sans bouton −15 s / +15 s / Passer |
| D5 | Bibliothèque initiale | 10 exercices de base (§5.1) |
| D6 | Niveau du développeur | Débutant en Flutter → concepts expliqués au fil des jalons |
| D7 | Navigation | go_router, appris dès le début (très utilisé dans les projets pros) |
| D8 | Fiche exercice | Ajoutée au MVP (EX-07 à EX-10) : onglets « À propos » et « Historique », pour tous les exercices |
| D9 | Catégorie | « Catégorie » = équipement (comme dans Strong) |
| D10 | Unités | Choix kg / lb **par exercice** (kg par défaut), pas de réglage global. Les lb entrent donc dans le MVP |
| D11 | Idées retenues | Ouvrir la fiche pendant une séance (WO-22), meilleure série ★ (RG-13), onglets Records et Graphique en v2 |
| D12 | Types de série | **Retirés** (échauffement, drop set, échec : WO-12 supprimée). Toutes les séries sont « normales ». La colonne `set_type` reste en base avec la valeur `normal`, ce qui évite une migration et permet de les réintroduire un jour |
| D13 | Modèles | Séries avec kg/reps prévus (comme Strong), copiés dans la séance au démarrage. Toucher une carte ouvre un aperçu avec « Démarrer » (pas de démarrage en 1 tap). La mise à jour du modèle se propose dans le résumé, sans fenêtre supplémentaire |
| D14 | Après les premiers essais du M5 | **Plus de séance vide** : toute séance démarre d'un modèle (WO-01), d'où la suppression de TP-06 et du nom selon l'heure (RG-05). Le **sélecteur d'exercices est l'onglet Exercices** en mode sélection, pour que les deux évoluent ensemble (WO-04). Réordonner les exercices par **glisser-déposer après réduction**, comme Strong (WO-15, TP-01). Carte de modèle : un exercice par ligne (TP-02) |
| D15 | M6 | La **note est attachée à l'exercice**, où qu'on la saisisse, et non plus à la séance (EX-11). La séance réduite remplace la carte « Séance en cours » de l'onglet Séance. Écran allumé désactivé au départ. **Pas d'APK release** pour l'instant : d'autres fonctionnalités passent avant |
| D16 | Dernières idées du MVP | **Pas de note de séance** (WO-16 abandonnée, pas de note de modèle non plus) : la note d'exercice suffit. Faits : réordonner les modèles (TP-08), repos enregistré comme défaut de l'exercice (RT-09), notification qui ouvre la séance (RT-10). APK release toujours reporté |
| D17 | Onglet Stats (M8) | Un onglet **Stats** entre Exercices et Réglages, en trois sous-onglets : **Séances** (une barre par semaine, un bloc par séance coloré selon son modèle), **Muscles** (silhouettes face/dos colorées selon les séries, muscles secondaires comptés pour ½, d'où leur ajout aux exercices) et **Corps** (poids, masse grasse, masse musculaire, tours ; courbe du poids, voir D26 pour la présentation des tours). La fiche exercice gagne un onglet **Statistiques** : courbes, records, records par nombre de reps, fréquence. Pas de calendrier, d'objectif hebdomadaire ni de photos |
| D18 | Après le premier essai du M8a | On peut **supprimer une séance terminée** (WO-23) : appui long sur la séance dans l'onglet Stats → menu → « Supprimer la séance », avec « Annuler » dans le message plutôt qu'une confirmation. Le message se referme tout seul après 3 s (son fond se remplit d'une teinte plus claire pour le montrer) ; passé ce délai, la séance n'est plus récupérable dans l'app. La suppression douce (RG-10) ne sert qu'à préparer une future synchronisation |
| D19 | Après le premier essai du M8b | La silhouette dessinée à la main a été jugée moche : elle est remplacée par de vrais tracés anatomiques, repris d'un projet open source (licence MIT) plutôt que dessinés par Claude |
| D20 | Après le premier essai du M8b | Les groupes musculaires de la carte étaient trop globaux : **« Dos » devient Trapèzes / Dorsaux / Lombaires, « Abdos » gagne Obliques, « Quadriceps » gagne Adducteurs** (migration v5 → v6). Rowing et Pull-Up passent en Dorsaux, Soulevé de terre en Lombaires. « Épaules » reste un seul groupe |
| D21 | Pour essayer la carte des muscles | **Bibliothèque élargie à 83 exercices** (migration v6 → v7) : 73 exercices de plus, pour qu'aucun groupe musculaire n'en manque. Les noms restent ceux utilisés en salle (ex. « Hip thrust », pas une traduction) |
| D22 | Après le premier essai avec 83 exercices | **Noms d'exercices en anglais** (migration v7 → v8, ex. « Hip Thrust (Barbell) ») : c'est ce que tout le monde utilise en salle. **Carte des muscles** : un repère par muscle plutôt qu'un maximum relatif (RG-23), pour qu'une seule série ne colore pas un muscle en rouge vif. **Une semaine à la fois** (lundi à dimanche), navigable, pour vérifier semaine par semaine si chaque muscle a été assez travaillé, plutôt que 7 j / 30 j / 3 mois / 1 an / tout |
| D23 | Idem | **Barre de défilement** toujours visible sur la liste d'exercices (83, c'est long) pour voir où on en est |
| D24 | Après le premier essai du M8b | **Navigation par glissement** sur la silhouette (au lieu de flèches), qui suit le doigt dès le début du geste. **Couleurs à 3 zones franches, sans dégradé** (bleu = bas, vert = optimal, orange = élevé — pas de rouge, qui suggérerait un problème) : un dégradé continu essayé d'abord, jugé moins lisible d'un coup d'œil. Sous chaque muscle, une échelle (seuils bas/haut chiffrés, repère à la position du muscle) plutôt qu'une simple barre proportionnelle |
| D25 | Pendant le M8c | **Une série ajoutée sans équivalent la dernière fois** (WO-10) reprend le préremplissage de la série d'avant dans la séance en cours, en chaîne, plutôt que de rester vide. **Terminer une séance sans rien de validé mais avec une série remplie** propose désormais d'abandonner (au lieu de rien) |
| D26 | M8c | **Carte du corps** : le poids, la masse grasse et la masse musculaire en lignes (nom, valeur, écart), plus simples à lire qu'une silhouette pour des chiffres seuls. Les tours, eux, reprennent la silhouette de la carte des muscles (D19), neutre et annotée : chaque étiquette est placée à la hauteur du tracé du muscle correspondant (`boundsOf`), pas devinée à la main |
| D27 | Après le premier essai du M8c | **Tours de fesses et d'avant-bras** en plus (migration v9 → v10). Sans tracé dédié en vue de face pour les fesses (au dos), l'étiquette se place entre les hanches et le haut des cuisses |
| D28 | Hors jalon, sur demande | **Chest Dip et Tricep Dip passent en « poids + reps »** (migration v10 → v11) : poids du corps, mais une ceinture de lest permet d'ajouter une charge, comme pour les tractions lestées. Les autres exercices au poids du corps (Pull-Up compris) restent en reps seules : pas de règle générale, juste ces deux-là pour l'instant |
| D29 | Hors jalon, sur demande | **Trapèzes scindés en haut et milieu/bas** (migration v11 → v12) : la silhouette n'a qu'un seul tracé par côté pour tout le trapèze, découpé en deux zones par un simple recadrage géométrique (pas de nouveau dessin) |
| D30 | Hors jalon, sur demande | **Bibliothèque élargie à 528 exercices** (445 de plus, migration v12 → v13) à partir du jeu de données ouvert RepDB, avec illustration par exercice. Remplace les photos wger (style incohérent d'un exercice à l'autre, cadrage parfois mauvais) : RepDB propose un style plat unique, un seul personnage, pour toute la bibliothèque. Licence gratuite en usage commercial avec attribution (affichée dans Réglages), pas de retouche lourde des images |
| D31 | Hors jalon, sur demande | **Carte du corps (onglet Corps)** : les tours passent avant le graphique (plus qu'après, D26), silhouette agrandie, tactile directement sur le dessin pour les tours qui ont un tracé musculaire dédié (poitrine, bras, avant-bras, taille, cuisse, mollet — cou/hanches/fesses restent seulement sur l'étiquette, faute de tracé). Toucher une zone (dessin ou étiquette) affiche son historique dans un graphique unique en bas de page (plus qu'un graphique fixe pour le poids) ; toucher ce graphique ouvre toujours sa page complète (SA-08) |
| D32 | Hors jalon, sur demande | **Réglages n'est plus un 4e onglet du bas** : une icône (sans texte) en haut à droite de Séance, Exercices et Stats y mène aussi vite, tout en gardant 3 onglets en bas |
| D33 | Hors jalon, sur demande | **Corps toujours complet, même sans donnée** : les 9 tours (onglet Corps) et les 16 muscles (onglet Muscles) restent tous affichés, avec la silhouette, même sans aucune mesure ou série encore saisie (valeur manquante en gris, pas de suppression de la ligne ou de tout l'écran) — pour montrer d'emblée ce qu'on peut suivre plutôt qu'un écran vide |
| D34 | Hors jalon, sur demande | **Toucher un champ poids/reps/durée sélectionne tout son texte** : les champs sont centrés, donc un appui au milieu plaçait le curseur au milieu du nombre et la saisie suivante s'y insérait plutôt que de remplacer — signalé comme gênant à l'usage. **Faire disparaître le clavier** : toucher en dehors d'un champ (n'importe où dans l'app), ou glisser sur la liste de la séance ou de l'éditeur de modèle — en plus du bouton déjà là |
| D35 | Hors jalon, sur demande | **Courbe de la fiche exercice (poids + reps) : reps max/totales en plus** des choix déjà là (1RM estimé, poids max, volume), comme pour les exercices à reps seules — un exercice au poids du corps garde ainsi sa progression en reps visible sans changer d'onglet |
| D36 | Hors jalon, sur demande | **Onglet « Activité »** : pas, distance, calories actives et sommeil, lus sur le téléphone (Health Connect sur Android, Apple Santé sur iOS, montre Xiaomi/Zepp Life en amont) via le paquet `health`, pas saisis à la main comme le reste de l'app. Contrôler l'app depuis la montre est écarté (bracelet Xiaomi classique, pas de Wear OS). Un seul écran d'autorisation bloque tout, à la différence de Corps/Muscles (D33) : sans elle il n'y a vraiment rien à montrer. Développé sans Mac ni iPhone : le code et la config Android sont vérifiés (tests, compilation), la config iOS (Info.plist, `Runner.entitlements`) est préparée mais pas la capacité Xcode elle-même, à finaliser sur Mac |
| D37 | Après le premier essai du D36 | **Activité rejoint les sous-onglets de Stats** (Séances/Muscles/Corps/Activité) plutôt que de rester un 5ᵉ onglet du bas : plus cohérent avec le reste des statistiques, et un onglet de moins dans la barre de navigation |
| D38 | Hors jalon, sur demande | **Filtres d'exercices fusionnés et à choix multiples** : un seul bouton « Filtres » (au lieu d'un par catégorie) ouvre une feuille avec groupe musculaire et équipement l'un sous l'autre, chacun en puces à cocher — plusieurs valeurs à la fois par catégorie, comme l'app Strong, plutôt qu'une seule avant |
| D39 | Signalé lent par l'utilisateur, mesuré (`adb shell am start -W`) | **Démarrage : plus d'attente du thème avant le premier affichage.** `main()` lisait le thème choisi (ST-03) avant `runApp`, pour éviter un bref flash en clair avant de passer en sombre — sur le téléphone de test, cette lecture ne se termine jamais à temps (testé jusqu'à 10 s d'attente, toujours bloquée), un coût garanti (avant : jusqu'à 1 s à chaque lancement) pour un bénéfice qui n'arrive jamais. Démarrage mesuré : ~2,3-2,6 s → ~1,4 s (version « profile », proche de ce qu'aurait l'app publiée) |
