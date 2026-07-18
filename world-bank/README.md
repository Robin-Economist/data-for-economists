# World Bank

La Banque mondiale (World Bank Group) est l'une des principales sources de données économiques et de développement au monde. Ses données sont accessibles via plusieurs portails complémentaires, et regroupées en **87 bases de données** différentes sur sa plateforme DataBank.

## Portails d'accès

| Portail | Description | Lien |
|---|---|---|
| **World Bank Open Data** | Portail public grand public, point d'entrée général avec visualisations. | [data.worldbank.org](https://data.worldbank.org/) |
| **DataBank** | Outil d'exploration et d'analyse — liste les 87 bases de données disponibles, permet de construire des requêtes personnalisées, exporter en Excel/CSV. | [databank.worldbank.org](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |
| **API Banque mondiale** | Accès programmatique aux mêmes données (utilisé par ce repo pour l'audit WDI, voir dossier `wdi/`). | [api.worldbank.org](https://api.worldbank.org/v2/) |

## Vocabulaire

- **Database** : un conteneur thématique (ex: World Development Indicators, Doing Business, Gender Statistics). La Banque mondiale en héberge 87.
- **Series / Indicator** : une mesure précise à l'intérieur d'une base (ex: "PIB par habitant"). Chaque base contient de quelques séries à plusieurs milliers.

## Bases de données notables

Parmi les 87 bases disponibles, voici les plus importantes en nombre de séries :

| Base de données | Nb de séries (ordre de grandeur) | Description |
|---|---|---|
| **World Development Indicators (WDI)** | ~1510 | La base la plus utilisée et la plus généraliste — PIB, population, éducation, santé, environnement, etc. Voir [wdi/](./wdi/) pour le détail. |
| **Education Statistics** | ~8300 | Données détaillées sur l'éducation par pays. |
| **The Atlas of Social Protection** | ~3560 | Indicateurs de résilience et d'équité sociale. |
| **Global Findex database** | ~2950 | Inclusion financière (accès aux comptes bancaires, épargne, crédit). |
| **International Debt Statistics** | ~530 | Dette extérieure des pays en développement. |
| **Doing Business** | ~190 | Facilité de faire des affaires par pays (indicateurs réglementaires). |
| **Gender Statistics** | ~930 | Données désagrégées par genre. |
| **Worldwide Governance Indicators** | ~36 | Qualité de la gouvernance par pays. |

*Liste non exhaustive — voir le lien DataBank ci-dessus pour l'ensemble des 87 bases.*

## Sous-dossiers de cette section

- [`wdi/`](./wdi/) — World Development Indicators : présentation détaillée, package R utilisé, et audit de complétude (quelles données manquent, pour quels pays et quelles années).

## Notes d'usage

- Certaines données de la Banque mondiale ont des **restrictions de redistribution** — vérifier les conditions avant de repartager des extraits bruts.
- Le package R `WDI` est recommandé pour interroger la base WDI par programmation (`wbstats`, une alternative, a été archivé en août 2025).
