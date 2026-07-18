# World Bank

The World Bank Group is one of the leading sources of economic and development data in the world. Its data is accessible through several complementary portals, and grouped into **87 different databases** on its DataBank platform.

## Access portals

| Portal | Description | Link |
|---|---|---|
| **World Bank Open Data** | Public-facing portal, general entry point with visualizations. | [data.worldbank.org](https://data.worldbank.org/) |
| **DataBank** | Data exploration and analysis tool — lists the 87 available databases, allows building custom queries, exporting to Excel/CSV. | [databank.worldbank.org](https://databank.worldbank.org/databases/page/1/orderby/popularity/direction/desc) |
| **World Bank API** | Programmatic access to the same data (used by this repo for the WDI audit, see the `wdi/` folder). | [api.worldbank.org](https://api.worldbank.org/v2/) |

## Vocabulary

- **Database**: a thematic container (e.g. World Development Indicators, Doing Business, Gender Statistics). The World Bank hosts 87 of them.
- **Series / Indicator**: a specific measure within a database (e.g. "GDP per capita"). Each database contains anywhere from a few series to several thousand.

## Notable databases

Among the 87 available databases, here are the most significant by number of series:

| Database | Approx. number of series | Description |
|---|---|---|
| **World Development Indicators (WDI)** | ~1,510 | The most widely used and general-purpose database — GDP, population, education, health, environment, etc. See [wdi/](./wdi/) for details. |
| **Education Statistics** | ~8,300 | Detailed education data by country. See [education-statistics/](./education-statistics/) for details. |
| **The Atlas of Social Protection** | ~3,560 | Indicators of resilience and equity. |
| **Global Findex database** | ~2,950 | Financial inclusion (access to bank accounts, savings, credit). |
| **International Debt Statistics** | ~530 | External debt of developing countries. |
| **Doing Business** | ~190 | Ease of doing business by country (regulatory indicators). |
| **Gender Statistics** | ~930 | Data disaggregated by gender. |
| **Worldwide Governance Indicators** | ~36 | Governance quality by country. |

*Non-exhaustive list — see the DataBank link above for all 87 databases.*

## Subfolders in this section

- [`wdi/`](./wdi/) — World Development Indicators: detailed presentation, the R package used, and a completeness audit (which data is missing, for which countries and years).
- [`education-statistics/`](./education-statistics/) — Education Statistics: detailed presentation and completeness audit *(in progress)*.

## Usage notes

- Some World Bank data has **redistribution restrictions** — check the terms before resharing raw extracts.
- The R package `WDI` is recommended for querying the WDI database programmatically (`wbstats`, an alternative, was archived in August 2025).
