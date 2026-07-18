# World Development Indicators (WDI)

**World Development Indicators** est la base de données la plus utilisée et la plus généraliste de la Banque mondiale. Elle compile des indicateurs de développement pour la quasi-totalité des pays du monde.

## Chiffres clés

| | |
|---|---|
| Séries (indicateurs) | ~1510 |
| Pays / régions | ~265 (dont agrégats régionaux et groupes de revenu) |
| Période disponible | 1960 – 2025 (variable selon les séries) |
| Lien DataBank | [databank.worldbank.org/source/world-development-indicators](https://databank.worldbank.org/source/world-development-indicators) |

## Thématiques couvertes

Les indicateurs sont organisés en grandes catégories : politique économique et dette, éducation, environnement, secteur financier, santé, infrastructure, travail et protection sociale, pauvreté, secteur privé et commerce, secteur public.

## Accès en R

Le package [`WDI`](https://cran.r-project.org/package=WDI) (v2.7.10) permet d'interroger WDI par programmation.

> ⚠️ Le package `wbstats`, autrefois recommandé pour le même usage, a été **archivé en août 2025**. Utiliser `WDI` à la place.

```r
library(WDI)

# Chercher un indicateur par mot-clé
WDIsearch("gdp per capita")

# Télécharger un indicateur pour tous les pays, sur une période donnée
data <- WDI(indicator = "NY.GDP.PCAP.KD", country = "all", start = 1960, end = 2025)
```

**Contraintes de l'API à connaître :**
- `start` doit être ≥ 1960
- Les noms de variables R ne peuvent pas contenir de tiret (`data_wdi`, pas `data-wdi`)
- Pas d'option `"all"` pour les indicateurs — il faut lister les codes explicitement
- L'API est instable par moments (erreurs `400`, `502`, timeouts) — prévoir des tentatives par petits lots plutôt qu'une requête unique massive

## Audit de complétude

Ce dossier contient un **audit exhaustif des valeurs manquantes** de WDI : pour chaque série et chaque pays, quelles années n'ont pas de donnée disponible.

### Méthode

1. Téléchargement de l'intégralité des ~1510 séries, tous pays, 1960–2025, par lots de 20 séries (pour contourner l'instabilité de l'API)
2. Passage des données au format long (une ligne = indicateur × pays × année)
3. Calcul du statut manquant/présent pour chaque combinaison
4. Regroupement des années manquantes en plages lisibles par couple (pays, série)

Voir le script complet : [`audit_WDI_final.R`](./audit_WDI_final.R)

### Résultat

Le rapport [`rapport_missing_values_WDI.csv`](./rapport_missing_values_WDI.csv) contient une ligne par couple (pays, série) ayant au moins une année manquante, avec :

| Colonne | Description |
|---|---|
| `indicateur` | Code de la série WDI (ex: `NY.GDP.PCAP.KD`) |
| `country` | Nom du pays ou de la région |
| `iso3c` | Code ISO à 3 lettres |
| `annees_manquantes` | Plages d'années sans donnée (ex: `1960-1962, 1970`) |
| `nb_annees_manquantes` | Nombre total d'années manquantes |

**Exemple d'utilisation** (dans R, Python ou Excel) :
```r
rapport <- read.csv("rapport_missing_values_WDI.csv")

# Tout ce qui manque pour un pays donné
rapport %>% filter(country == "France")

# Tous les pays manquants pour une série donnée
rapport %>% filter(indicateur == "NY.GDP.PCAP.KD")
```

### Constats généraux

- Sur ~1510 séries, environ 1397 ont au moins une valeur manquante quelque part (les autres sont donc complètes à 100%).
- Les années **2024-2025** et **1960** concentrent une grande partie des manques, probablement pour des raisons structurelles (données les plus récentes pas encore collectées pour tous les pays ; 1960 comme année de démarrage incomplète pour beaucoup de séries) plutôt qu'un vrai problème de qualité des séries.
- Certaines séries (ex: plusieurs indicateurs liés à l'aide publique au développement, `DT.ODA.*`) sont totalement vides pour de nombreux pays développés (normal : ces indicateurs ne s'appliquent qu'aux pays bénéficiaires).

## Fichiers de ce dossier

- `README.md` — ce document
- `audit_WDI_final.R` — script complet (téléchargement, traitement, export)
- `rapport_missing_values_WDI.csv` — rapport final des valeurs manquantes
