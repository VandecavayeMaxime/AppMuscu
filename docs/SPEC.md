# AppMuscu — Spécification fonctionnelle (MVP)

> Statut : **brouillon à valider** · Dernière mise à jour : 2026-09-26
> Document compagnon : [ARCHITECTURE.md](ARCHITECTURE.md) (choix techniques, modèle de données, plan de développement)

---

## 1. Vision

Application mobile de suivi de musculation inspirée de **Strong** : noter vite ses séances en salle (exercices, séries, poids, répétitions), réutiliser des modèles de séance et gérer ses temps de repos. L'app fonctionne entièrement hors-ligne, répond vite et s'utilise d'une main entre deux séries.

### Objectifs du MVP

1. Enregistrer une séance complète plus vite que sur papier.
2. Toujours voir ce qu'on a fait **la dernière fois** sur un exercice (colonne « Précédent »).
3. Démarrer une séance type **en 1 tap** depuis un modèle.
4. **Ne jamais perdre de données** (app fermée, batterie vide, appel entrant).

### Hors périmètre du MVP

Écran d'historique des séances, export/import, graphiques, records perso, mesures corporelles, comptes / sync cloud, supersets, calculateur de disques, cardio avec distance, intégrations santé, iOS. Tout ça est listé dans la [roadmap v2](#8-roadmap-après-le-mvp).

> Même sans écran d'historique, les séances terminées sont **conservées en base** : c'est ce qui alimente la colonne « Précédent ».

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
| **Exercice** | Mouvement de la bibliothèque (ex. « Développé couché (barre) »). |
| **Séance** | Entraînement daté, avec une heure de début et de fin. |
| **Série** | Une ligne « poids × reps » (ou durée) d'un exercice dans une séance. |
| **Modèle** | Séance type réutilisable (ex. « Push ») : exercices et séries prévues. |
| **Précédent** | Valeurs de la série de même rang lors de la dernière séance contenant cet exercice. |
| **Placeholder** | Valeur grisée affichée dans un champ vide, reprise si on valide sans rien saisir. |
| **Temps de repos** | Durée de repos **propre à chaque série**. Le compte à rebours démarre quand on valide la série et s'affiche sur la ligne juste en dessous. |
| **Volume** | Σ (kg × reps) des séries validées. |

## 4. Navigation et écrans

Barre d'onglets en bas, 3 entrées :

| Onglet | Contenu |
|---|---|
| **Séance** | Bouton « Démarrer une séance vide », liste des modèles, création de modèle |
| **Exercices** | Bibliothèque, recherche, filtres, exercices perso |
| **Réglages** | Temps de repos par défaut, vibration/son, thème |

L'écran **Séance en cours** s'ouvre en plein écran par-dessus les onglets. On peut le réduire en barre persistante en bas de l'écran (WO-20).

Toucher un exercice, dans la bibliothèque ou depuis une séance (WO-22), ouvre sa **fiche** avec une flèche de retour (EX-07) :

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ ←  Développé couché (barre)   ⋯  │      │ ←  Développé couché (barre)   ⋯  │
│   [À propos]      Historique     │      │    À propos     [Historique]     │
├──────────────────────────────────┤      ├──────────────────────────────────┤
│      ┌────────────────────┐      │      │ ┌──────────────────────────────┐ │
│      │  (image générique) │      │      │ │ Push                         │ │
│      └────────────────────┘      │      │ │ mercredi 23 septembre 2026   │ │
│ Groupe musculaire    Pectoraux   │      │ │  1   80 kg × 8    ★          │ │
│ Catégorie                Barre   │      │ │  2   82,5 kg × 6             │ │
│                                  │      │ │  3   80 kg × 6               │ │
│ Instructions                     │      │ └──────────────────────────────┘ │
│ 1. Allonge-toi sur le banc…      │      │ ┌──────────────────────────────┐ │
│                                  │      │ │ Séance du soir               │ │
│ Préférences                      │      │ │ lundi 21 septembre 2026      │ │
│ Unité                 [kg | lb]  │      │ │  1   77,5 kg × 8  ★          │ │
│ Minuteur de repos  Réglage global│      │ └──────────────────────────────┘ │
└──────────────────────────────────┘      └──────────────────────────────────┘
```

Le menu ⋯ (Modifier, Supprimer) n'existe que pour les exercices perso.

### Maquette : séance en cours

```
┌────────────────────────────────────────────┐
│ ⌄   Séance du matin            [Terminer]  │
│     Durée 00:42:17                         │
├────────────────────────────────────────────┤
│ Développé couché (barre)              ⋯    │
│ Série   Précédent     kg     Reps     ✓    │
│  1      80 × 8        82,5   8       [✓]   │  ← série validée (colorée)
│  ─────────────── ✓ 1:30 ───────────────    │  ← repos terminé (grisé)
│  2      80 × 8        82,5   7       [✓]   │
│  ▓▓▓▓▓▓▓▓▓▓░░░░░░ 1:23 ░░░░░░░░░░░░░░░░    │  ← repos en cours (progression)
│  3      80 × 7        82,5   6       [ ]   │
│  ──────────────── 2:00 ────────────────    │  ← repos prévu
│  4      77,5 × 6      77,5   6       [ ]   │  ← placeholders grisés
│  ──────────────── 2:00 ────────────────    │  ← repos avant l'exercice suivant
│            + Ajouter une série             │
├────────────────────────────────────────────┤
│ Rowing (barre)                        ⋯    │
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
| `── ✓ 1:30 ──` | terminé | Ligne grisée avec ✓ |

Chaque série a son propre temps de repos : ici 1:30 après la 1re série, 2:00 après les suivantes.

## 5. Exigences fonctionnelles

Priorités : **M** = Must (indispensable au MVP) · **S** = Should (MVP si le temps le permet) · **C** = Could (bonus)

### 5.1 Bibliothèque d'exercices (EX)

| ID | Exigence | Prio |
|---|---|---|
| EX-01 | L'app est livrée avec les **10 exercices de base** listés ci-dessous. | M |
| EX-02 | Liste alphabétique avec recherche par nom, insensible à la casse et aux accents (« developpe » trouve « Développé couché »). | M |
| EX-03 | Filtres par groupe musculaire et par équipement. | S |
| EX-04 | Créer un exercice perso : nom, groupe musculaire, catégorie (= équipement), type de suivi, instructions (facultatif). | M |
| EX-05 | Modifier ou supprimer un exercice perso, depuis le menu ⋯ de sa fiche. Un exercice supprimé est **archivé** : il disparaît de la bibliothèque mais reste en base avec les séances et modèles qui l'utilisent. | M |
| EX-06 | Le nom d'un exercice actif est unique (sans tenir compte de la casse ni des accents). | S |
| EX-07 | **Fiche exercice.** Toucher n'importe quel exercice ouvre sa fiche (avec retour arrière), qui a deux onglets : « À propos » (EX-09) et « Historique » (EX-10). | M |
| EX-08 | **Préférences par exercice**, réglables pour tous les exercices, intégrés compris : unité des poids (kg ou lb, kg par défaut, masquée pour les exercices sans poids) et minuteur de repos (réglage global, désactivé, ou de 0:30 à 5:00). | M |
| EX-09 | **Onglet « À propos »** : image du mouvement (générique pour l'instant), groupe musculaire, catégorie, instructions (fournies pour les exercices intégrés, saisies pour les exercices perso), préférences (EX-08). | M |
| EX-10 | **Onglet « Historique »** : un bloc par séance terminée où l'exercice a au moins une série validée, de la plus récente à la plus ancienne. Chaque bloc affiche le nom de la séance, la date et les séries validées (RG-02), avec la meilleure série marquée ★ (RG-13). | M |

**Bibliothèque initiale**

| Exercice | Groupe musculaire | Équipement | Type de suivi |
|---|---|---|---|
| Développé couché (barre) | Pectoraux | Barre | Poids + reps |
| Squat (barre) | Quadriceps | Barre | Poids + reps |
| Soulevé de terre (barre) | Dos | Barre | Poids + reps |
| Développé militaire (barre) | Épaules | Barre | Poids + reps |
| Rowing (barre) | Dos | Barre | Poids + reps |
| Presse à cuisses | Quadriceps | Machine | Poids + reps |
| Curl biceps (haltères) | Biceps | Haltères | Poids + reps |
| Extension triceps (poulie) | Triceps | Poulie | Poids + reps |
| Tractions | Dos | Poids du corps | Reps seules |
| Gainage (planche) | Abdos | Poids du corps | Durée |

**Types de suivi (MVP)**

| Type | Colonnes saisies | Exemples |
|---|---|---|
| Poids + reps | kg, reps | Développé couché, Squat |
| Reps seules | reps | Tractions |
| Durée | mm:ss | Gainage |

*Lest/assistance (± kg) et distance + durée arrivent en v2.*

**Équipements** (appelés « Catégorie » dans l'interface) **:** Barre, Haltères, Machine, Poulie, Kettlebell, Poids du corps, Élastique, Autre.
**Groupes musculaires :** Pectoraux, Dos, Épaules, Biceps, Triceps, Avant-bras, Abdos, Quadriceps, Ischios, Fessiers, Mollets, Corps entier, Cardio, Autre.

### 5.2 Séance en cours (WO)

| ID | Exigence | Prio |
|---|---|---|
| WO-01 | Démarrer une séance vide. Son nom par défaut dépend de l'heure (RG-05) et reste modifiable. | M |
| WO-02 | Une seule séance en cours à la fois. Si on en démarre une autre, l'app propose : « Reprendre la séance en cours » ou « L'abandonner et démarrer ». | M |
| WO-03 | Un chronomètre affiche le temps écoulé depuis le début de la séance. | M |
| WO-04 | Ajouter un ou plusieurs exercices via un sélecteur multi-sélection avec recherche. Dans le sélecteur, toucher le nom d'un exercice ouvre sa fiche, et la case à cocher le sélectionne ; la sélection est conservée au retour de la fiche. Chaque exercice ajouté arrive avec 1 série vide. | M |
| WO-05 | Chaque exercice affiche un tableau de séries : Série, Précédent, colonnes du type de suivi, case de validation ✓. Chaque série est suivie de sa ligne de repos (RT-03). | M |
| WO-06 | La colonne **Précédent** affiche les valeurs de la série de même rang lors de la dernière séance contenant l'exercice (RG-03, RG-04), ou « — » si aucune. Taper dessus recopie ces valeurs dans la série. | M |
| WO-07 | Les nombres se saisissent au pavé numérique. Le poids accepte les décimales, avec la virgule ou le point. Un champ vide affiche un placeholder grisé (RG-11). | M |
| WO-08 | **Valider une série** (✓) enregistre l'heure de validation, colore la ligne et lance le minuteur de repos. Un champ vide qui a un placeholder prend sa valeur. S'il reste un champ vide sans placeholder, la validation est refusée et le champ est signalé. | M |
| WO-09 | Retaper ✓ dévalide la série. | M |
| WO-10 | « + Ajouter une série » ajoute une série vide en bas de l'exercice. Elle reprend le temps de repos de la série au-dessus (RG-12). | M |
| WO-11 | Supprimer une série en la balayant vers la gauche, depuis la colonne « Série » ou « Précédent » : sur un champ de saisie, le glissement sélectionne du texte. Les séries sont renumérotées automatiquement. | M |
| WO-13 | Le menu ⋯ d'un exercice permet d'ajouter une note, de régler d'un coup le temps de repos de **toutes** ses séries, et de retirer l'exercice de la séance. | M |
| WO-14 | Remplacer un exercice par un autre en gardant les séries (depuis le menu ⋯). | C |
| WO-15 | Réordonner les exercices par glisser-déposer. | S |
| WO-16 | Ajouter une note à la séance (texte libre). | S |
| WO-17 | **Terminer la séance.** Une série non validée est dite *remplie* si toutes les valeurs de son type de suivi sont saisies (kg et reps, reps, ou durée). Les séries non validées vides ou incomplètes sont supprimées sans rien demander. S'il reste des séries remplies, une fenêtre simple, sans détail série par série, propose « Compléter » (les valider), « Jeter » (seulement s'il y a déjà au moins une série validée) ou « Annuler ». Les exercices qui n'ont plus aucune série sont retirés. S'il n'y a ni série validée ni série remplie, la séance ne peut pas être terminée : l'app propose de l'abandonner. | M |
| WO-18 | Après la fin, un **écran de résumé** affiche le nom, la date et les horaires (début → fin), la durée, le nombre d'exercices et de séries, et le volume total. Puis, pour chaque exercice : toutes ses séries validées (★ = meilleure, RG-13) et la **comparaison avec la dernière fois**, c'est-à-dire l'évolution du total (volume en kg, reps ou durée selon le type de suivi) avec son écart, et celle de la meilleure série (▲ / ▼ / =), avec la meilleure série de la dernière fois. « Première fois avec cet exercice » s'il n'y a pas de séance précédente. | M |
| WO-19 | Abandonner la séance (avec confirmation) la supprime définitivement. | M |
| WO-20 | Réduire la séance en barre persistante (nom, chrono et repos en cours) pour naviguer dans les onglets, puis la rouvrir d'un tap. | S |
| WO-21 | **Persistance :** chaque modification est enregistrée immédiatement. Si l'app est tuée, on retrouve la séance intacte au redémarrage, avec un bandeau « Séance en cours — Reprendre ». | M |
| WO-22 | Toucher le nom d'un exercice en séance ouvre sa fiche (EX-07), pour revoir son historique entre deux séries. Le menu Modifier / Supprimer y est masqué, pour ne pas quitter la séance par erreur. | M |

### 5.3 Minuteur de repos (RT)

| ID | Exigence | Prio |
|---|---|---|
| RT-01 | Le temps de repos se définit **par série**. Une série sans valeur propre prend celle de l'exercice en bibliothèque, sinon le réglage global (2:00 par défaut). Voir RG-09. La valeur 0 désactive le minuteur pour cette série. | M |
| RT-02 | Valider une série démarre le minuteur de repos **de cette série**, avec son temps de repos. Un seul minuteur tourne à la fois : si on valide une autre série, le repos en cours s'arrête et le nouveau démarre sous la série qu'on vient de valider. Dévalider une série dont le repos tourne arrête le minuteur. | M |
| RT-03 | **Une ligne de repos suit chaque série**, y compris la dernière d'un exercice. Elle a trois états : **prévu** (temps de repos affiché discrètement, avant validation), **en cours** (barre de progression et temps restant, après validation), **terminé** (grisé avec ✓, une fois le temps écoulé). | M |
| RT-04 | La ligne de repos **n'a aucun bouton**. Pour écourter un repos, il suffit de valider la série suivante (RT-02). Terminer ou abandonner la séance arrête aussi le minuteur. | M |
| RT-05 | À la fin du repos : vibration et son (désactivables dans les réglages) si l'app est ouverte, notification si elle est en arrière-plan ou si l'écran est verrouillé. | M |
| RT-06 | Le minuteur reste exact quand l'app passe en arrière-plan, est tuée ou que l'écran se verrouille, car il repose sur une heure de fin absolue et non sur un décompte. | M |
| RT-07 | Taper sur une ligne de repos permet de modifier le temps de repos **de cette série**, avec une option « Appliquer à toutes les séries de l'exercice ». | M |
| RT-08 | Si la ligne de repos en cours sort de l'écran (défilement) ou si la séance est réduite (WO-20), un compteur compact s'affiche dans l'en-tête ou la barre réduite. Un tap dessus ramène à la ligne. | S |
| RT-09 | Dans le réglage de RT-07, une option « Enregistrer comme défaut pour cet exercice » met aussi à jour la bibliothèque. | C |

### 5.4 Modèles (TP)

| ID | Exigence | Prio |
|---|---|---|
| TP-01 | Créer un modèle : nom, exercices ordonnés, séries prévues (kg, reps ou durée, **temps de repos**), note. | M |
| TP-02 | L'onglet Séance liste les modèles. Chaque carte affiche le nom, un aperçu des exercices (« 3 × Développé couché, 4 × Squat… ») et la date de dernière utilisation. | M |
| TP-03 | Modifier, renommer ou supprimer un modèle (avec confirmation). Supprimer un modèle ne touche pas aux séances passées. | M |
| TP-04 | Dupliquer un modèle. | S |
| TP-05 | **Démarrer une séance depuis un modèle** : la séance reprend le nom, les exercices et les séries (nombre, temps de repos) du modèle. Les kg/reps du modèle deviennent les placeholders (RG-11). | M |
| TP-06 | Créer un modèle à partir d'une séance terminée, depuis l'écran de résumé. | S |
| TP-07 | Quand on termine une séance issue d'un modèle et que les exercices, le nombre de séries ou les valeurs ont changé, l'app propose « Mettre à jour le modèle » ou « Garder le modèle tel quel ». | S |
| TP-08 | Réordonner les modèles. | C |

### 5.5 Réglages (ST)

| ID | Exigence | Prio |
|---|---|---|
| ST-01 | Régler le temps de repos global par défaut. | M |
| ST-02 | Activer ou désactiver la vibration et le son de fin de repos. | M |
| ST-03 | Thème clair, sombre ou selon le système. | S |
| ST-04 | Garder l'écran allumé pendant une séance. | C |

## 6. Règles de gestion

| ID | Règle |
|---|---|
| RG-01 | **Volume** = Σ (kg × reps) des séries **validées**, toujours calculé en kg. Les exercices « reps seules » et « durée » ne comptent pas. |
| RG-02 | **Numérotation** : les séries d'un exercice sont numérotées 1, 2, 3… dans l'ordre. |
| RG-03 | **Correspondance « Précédent »** : la k-ième série d'un exercice (tous types confondus, dans l'ordre) correspond à la k-ième série du même exercice dans la séance de référence (RG-04). |
| RG-04 | **Séance de référence** d'un exercice : la séance terminée et non supprimée la plus récente (par date de début) qui contient au moins une série validée de cet exercice. La séance en cours est exclue. |
| RG-05 | **Nom par défaut** : 5h00–11h59 « Séance du matin », 12h00–17h59 « Séance de l'après-midi », 18h00–4h59 « Séance du soir ». Une séance démarrée depuis un modèle prend le nom du modèle. |
| RG-06 | **Bornes de saisie** : poids de 0 à 1 000 kg, au centième près. Reps : entier de 0 à 999. Durée : de 0 s à 23:59:59. Temps de repos : de 0 s à 10:00, par pas de 5 s. |
| RG-07 | **Durée de séance** = heure de fin − heure de début. |
| RG-08 | Une séance terminée contient au moins une série validée. |
| RG-09 | **Temps de repos effectif d'une série** = sa valeur propre si elle est définie, sinon le temps par défaut de l'exercice en bibliothèque, sinon le réglage global. |
| RG-10 | Les suppressions sont « douces » en base (marquées, pas effacées) pour préparer la sync. L'utilisateur ne voit pas la différence. Exception : une séance abandonnée est effacée pour de bon. |
| RG-11 | **Placeholder d'un champ** = valeur prévue dans le modèle si elle existe, sinon valeur « Précédent », sinon rien. |
| RG-12 | Une série ajoutée reprend le temps de repos propre de la série au-dessus. S'il n'y en a pas, elle n'a pas de valeur propre et RG-09 s'applique. |
| RG-13 | **Meilleure série** d'une séance (en cas d'égalité, la première) : poids + reps → le 1RM estimé le plus élevé (formule d'Epley : kg × (1 + reps / 30), ce qui permet de comparer 100 kg × 5 et 90 kg × 10) ; reps seules → le plus de reps ; durée → la plus longue. |
| RG-14 | **Unités** : les poids sont toujours enregistrés en kg. Ils sont saisis et affichés dans l'unité de l'exercice (1 lb = 0,45359237 kg), avec la virgule française et au plus 2 décimales. |

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
- **Fiche exercice :** vraies images ou vidéos des mouvements ; onglet « Records » (records perso, 1RM estimé, badge « PR » pendant la séance) ; onglet « Graphique » (1RM, volume, poids max dans le temps)
- **Statistiques :** statistiques hebdomadaires
- **Mesures corporelles :** poids, % de masse grasse, tours de bras/taille…
- **Séance :** supersets et circuits, calculateur de disques, séries d'échauffement suggérées
- **Types de suivi :** lest/assistance (± kg), distance + durée (cardio)
- **Organisation :** dossiers de modèles, programmes sur plusieurs semaines
- **Bibliothèque :** enrichir la liste d'exercices intégrés
- **Cloud :** comptes et synchronisation multi-appareils (ex. Supabase)
- **Plateformes et intégrations :** iOS, widget d'écran d'accueil, Health Connect, montre

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
