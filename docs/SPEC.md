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
| **Séance** | Liste des modèles, création de modèle. Toute séance démarre d'un modèle |
| **Exercices** | Bibliothèque, recherche, filtres, exercices perso |
| **Réglages** | Temps de repos par défaut, son et vibration, écran allumé, thème |

L'écran **Séance en cours** s'ouvre en plein écran par-dessus les onglets. On peut le réduire en une barre au-dessus des onglets, visible dans les trois (WO-20) :

```
┌──────────────────────────────────┐
│ ▔▔▔▔▔▔▔▔▔▔▔▔▔░░░░░░░░░░ (repos)  │
│ Push                ⏱ 1:12    ˄  │
│ 32:15                            │
├──────────────────────────────────┤
│   Séance    Exercices   Réglages │
└──────────────────────────────────┘
```

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

### Maquette : modèles (onglet Séance et éditeur)

```
┌──────────────────────────────────┐      ┌──────────────────────────────────┐
│ Séance                           │      │ ←  Modifier le modèle  [Enreg.]  │
├──────────────────────────────────┤      ├──────────────────────────────────┤
│ Modèles              + Nouveau   │      │ Nom du modèle                    │
│ ┌──────────────────────────────┐ │      │ Push                             │
│ │ Push                      ⋯  │ │      │                                  │
│ │ 3 × Développé couché (barre) │ │      │ Développé couché (barre)      ⋯  │
│ │ 3 × Développé militaire      │ │      │ Série        kg        Reps      │
│ │ 4 × Squat (barre)            │ │      │   1       [ 80  ]    [  8  ]     │
│ │ Il y a 3 jours               │ │      │ ───────────── 2:00 ───────────── │
│ └──────────────────────────────┘ │      │   2       [ 80  ]    [  8  ]     │
│                                  │      │ ───────────── 2:00 ───────────── │
│                                  │      │        + Ajouter une série       │
│  toucher → aperçu + [▶ Démarrer] │      │    [ + Ajouter des exercices ]   │
└──────────────────────────────────┘      └──────────────────────────────────┘
```

Menu ⋯ d'une carte : Modifier, Dupliquer, Supprimer. Menu ⋯ d'un exercice dans l'éditeur : Réorganiser, Retirer du modèle.

### Maquette : réorganiser les exercices (séance et éditeur de modèle)

```
Appui long sur le nom d'un exercice (ou ⋯ → Réorganiser) :
┌──────────────────────────────────┐
│ Glisse les exercices pour   [OK] │
│ changer leur ordre               │
├──────────────────────────────────┤
│ ≡  Développé couché (barre)      │
│ ≡  Squat (barre)                 │
│ ≡  Tractions                     │
└──────────────────────────────────┘
OK → les séries réapparaissent
```

### Maquette : séance en cours

```
┌────────────────────────────────────────────┐
│ ⌄   Séance du matin            [Terminer]  │
│     Durée 00:42:17                         │
├────────────────────────────────────────────┤
│ Développé couché (barre)              ⋯    │
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
| `── ✓ 1:30 ──` | terminé | ✓, ligne surlignée de la même couleur que la série validée |

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
| EX-09 | **Onglet « À propos »** : image du mouvement (générique pour l'instant), groupe musculaire, catégorie, note (EX-11), instructions (fournies pour les exercices intégrés, saisies pour les exercices perso), préférences (EX-08). | M |
| EX-10 | **Onglet « Historique »** : un bloc par séance terminée où l'exercice a au moins une série validée, de la plus récente à la plus ancienne. Chaque bloc affiche le nom de la séance, la date et les séries validées (RG-02), avec la meilleure série marquée ★ (RG-13). | M |
| EX-11 | **Note d'exercice** : une note libre (réglage de la machine, sensations…) attachée à l'exercice lui-même, intégré ou perso. Elle s'ajoute ou se modifie depuis la fiche (section « Note »), depuis la séance ou depuis l'éditeur de modèle (menu ⋯), et elle est enregistrée tout de suite. Elle s'affiche sous le nom de l'exercice en séance et dans l'éditeur. | M |

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
| WO-16 | Ajouter une note à la séance (texte libre). | S |
| WO-17 | **Terminer la séance.** Une série non validée est dite *remplie* si toutes les valeurs de son type de suivi sont saisies (kg et reps, reps, ou durée). Les séries non validées vides ou incomplètes sont supprimées sans rien demander. S'il reste des séries remplies, une fenêtre simple, sans détail série par série, propose « Compléter » (les valider), « Jeter » (seulement s'il y a déjà au moins une série validée) ou « Annuler ». Les exercices qui n'ont plus aucune série sont retirés. S'il n'y a ni série validée ni série remplie, la séance ne peut pas être terminée : l'app propose de l'abandonner. | M |
| WO-18 | Après la fin, un **écran de résumé** affiche le nom, la date et les horaires (début → fin), la durée, le nombre d'exercices et de séries, et le volume total. Puis, pour chaque exercice : toutes ses séries validées (★ = meilleure, RG-13) et la **comparaison avec la dernière fois**, c'est-à-dire l'évolution du total (volume en kg, reps ou durée selon le type de suivi) avec son écart, et celle de la meilleure série (▲ / ▼ / =), avec la meilleure série de la dernière fois. « Première fois avec cet exercice » s'il n'y a pas de séance précédente. | M |
| WO-19 | Abandonner la séance (avec confirmation) la supprime définitivement. | M |
| WO-20 | Réduire la séance (« ˅ ») en une barre au-dessus des onglets, visible dans les trois tant que la séance est en cours : nom, chrono, compteur et barre de progression du repos en cours. La toucher rouvre la séance, à la hauteur du repos en cours s'il y en a un. | S |
| WO-21 | **Persistance :** chaque modification est enregistrée immédiatement. Si l'app est tuée, on retrouve la séance intacte au redémarrage, avec la barre de séance réduite (WO-20). | M |
| WO-22 | Toucher le nom d'un exercice en séance ouvre sa fiche (EX-07), pour revoir son historique entre deux séries. Le menu Modifier / Supprimer y est masqué, pour ne pas quitter la séance par erreur. | M |

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
| RT-09 | Dans le réglage de RT-07, une option « Enregistrer comme défaut pour cet exercice » met aussi à jour la bibliothèque. | C |

### 5.4 Modèles (TP)

| ID | Exigence | Prio |
|---|---|---|
| TP-01 | Créer un modèle : nom, exercices ordonnés (glisser-déposer, comme WO-15), séries prévues (kg, reps ou durée, **temps de repos**), toutes facultatives. L'éditeur a la présentation de la séance, sans « Précédent » ni case ✓. Il faut un nom et au moins un exercice ; chaque exercice garde au moins une série. Les modifications ne sont enregistrées qu'avec « Enregistrer » ; quitter avant demande confirmation. *La note de modèle est reportée avec la note de séance (WO-16).* | M |
| TP-02 | L'onglet Séance liste les modèles. Chaque carte affiche le nom, un aperçu des exercices, un par ligne (« 3 × Développé couché », « 4 × Squat »…) et la date de dernière utilisation (« Hier », « Il y a 3 jours », « Jamais utilisé »). | M |
| TP-03 | Modifier, renommer ou supprimer un modèle (avec confirmation), depuis le menu ⋯ de sa carte. Supprimer un modèle ne touche pas aux séances passées. | M |
| TP-04 | Dupliquer un modèle (« Push (copie) », en fin de liste). | S |
| TP-05 | **Démarrer une séance depuis un modèle** : toucher la carte ouvre un aperçu avec « Démarrer la séance » (WO-02 s'applique). La séance reprend le nom, les exercices et les séries (nombre, temps de repos) du modèle. Les kg/reps du modèle deviennent les placeholders (RG-11) ; ils sont copiés dans la séance, que modifier le modèle ensuite ne change pas. | M |
| ~~TP-06~~ | ~~Créer un modèle à partir d'une séance terminée.~~ *Supprimée (D14) : toute séance vient d'un modèle.* | — |
| TP-07 | Quand une séance issue d'un modèle diffère de ce modèle (exercices, ordre, nombre de séries, valeurs réalisées ou temps de repos), le résumé affiche « La séance diffère du modèle » avec un bouton « Mettre à jour le modèle ». Le modèle prend alors les séries validées de la séance. Sans action, il ne change pas. | S |
| TP-08 | Réordonner les modèles. | C |

### 5.5 Réglages (ST)

| ID | Exigence | Prio |
|---|---|---|
| ST-01 | Régler le temps de repos global par défaut (2:00 au départ, « Sans repos » possible). Il vaut pour les exercices sans temps de repos propre (RG-09). | M |
| ST-02 | Activer ou désactiver le son et la vibration de fin de repos (deux interrupteurs, activés au départ). Le changement vaut à partir du repos suivant. | M |
| ST-03 | Thème clair, sombre ou selon le système (au départ). | S |
| ST-04 | Garder l'écran allumé tant qu'une séance est en cours (désactivé au départ). | C |

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
| D13 | Modèles | Séries avec kg/reps prévus (comme Strong), copiés dans la séance au démarrage. Toucher une carte ouvre un aperçu avec « Démarrer » (pas de démarrage en 1 tap). La mise à jour du modèle se propose dans le résumé, sans fenêtre supplémentaire |
| D14 | Après les premiers essais du M5 | **Plus de séance vide** : toute séance démarre d'un modèle (WO-01), d'où la suppression de TP-06 et du nom selon l'heure (RG-05). Le **sélecteur d'exercices est l'onglet Exercices** en mode sélection, pour que les deux évoluent ensemble (WO-04). Réordonner les exercices par **glisser-déposer après réduction**, comme Strong (WO-15, TP-01). Carte de modèle : un exercice par ligne (TP-02) |
| D15 | M6 | La **note est attachée à l'exercice**, où qu'on la saisisse, et non plus à la séance (EX-11). La séance réduite remplace la carte « Séance en cours » de l'onglet Séance. Écran allumé désactivé au départ. **Pas d'APK release** pour l'instant : d'autres fonctionnalités passent avant |
