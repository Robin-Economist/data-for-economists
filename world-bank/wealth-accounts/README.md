# Wealth Accounts

**Wealth Accounts** measures the components of national wealth — going beyond GDP (a flow measure) to estimate the stock of assets that generate a country's income: produced capital, natural capital, human capital, and net foreign assets.

## Key figures

| | |
|---|---|
| Series (indicators) | 146 |
| Countries / regions | ~215 |
| Available period | 1995–2018 |
| DataBank link | [databank.worldbank.org/source/wealth-accounts](https://databank.worldbank.org/source/wealth-accounts/preview/on) |

## Conceptual framework

Wealth Accounts follows a clear accounting identity:

```
National Comprehensive Wealth = Domestic Comprehensive Wealth + Net Foreign Assets
Domestic Comprehensive Wealth = Produced Capital + Natural Capital + Human Capital
```

- **Produced Capital** — infrastructure, buildings, machinery, urban land
- **Natural Capital** — agricultural land, forests, minerals, fossil fuels, protected areas (the most granular category, broken down by resource type)
- **Human Capital** — the value of future earnings of the labor force, by gender
- **Net Foreign Assets** — foreign assets minus foreign liabilities

## Accessing Wealth Accounts in R

Same package and method as other World Bank databases — see [`world-bank/wdi/README.md`](../wdi/README.md) for general setup instructions.

```r
library(WDI)

meta <- WDIcache()
db_name <- "Wealth Accounts"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # 146

# Example: download total national wealth for a few countries
data <- WDI(indicator = "NW.TOW.TO.CD", country = c("FRA", "USA", "IND"),
            start = 1995, end = 2018)
```

## Indicator categories

The 146 indicators map onto the 7 components of the wealth accounting framework — this covers **100%** of the indicators.

| Category | Indicators | % of total | Description |
|---|---|---|---|
| **Natural Capital** | 112 | 76.7% | Agricultural land, forests, minerals, fossil fuels — broken down by resource type |
| **Human Capital** | 12 | 8.2% | Value of future labor earnings, by gender |
| **Produced Capital** | 6 | 4.1% | Infrastructure, buildings, machinery, urban land |
| **Domestic Comprehensive Wealth** | 4 | 2.7% | Produced + natural + human capital combined |
| **Net Foreign Assets** | 4 | 2.7% | Foreign assets |
| **Foreign Liabilities** | 4 | 2.7% | Foreign liabilities |
| **National Comprehensive Wealth (Total)** | 4 | 2.7% | The top-level aggregate: domestic wealth + net foreign assets |

Full indicator-to-category mapping: see [`wealth_accounts_categories.csv`](./wealth_accounts_categories.csv)

## Completeness audit

This folder contains an **exhaustive missing-values audit** of Wealth Accounts: for each series and each country, which years have no available data.

### Method

Same method as the other audits in this repo — full download by batch, long-format reshaping, and per (country, series) gap detection.

See the full script: [`audit_WealthAccounts.R`](./audit_WealthAccounts.R)

### Output

The report [`missing_values_report_WealthAccounts.csv`](./missing_values_report_WealthAccounts.csv) contains one row per (country, series) pair with at least one missing year, with the same column structure as the other audits in this repo.

### General findings

Wealth Accounts is a **fairly well-covered, methodologically mature database** — noticeably better than Education Statistics or WWBI, though not as complete as WDI or WGI.

**By series**
- Best-covered: several core capital components (e.g. `NW.PCA.TO`, `NW.NCA.PEAT`) reach **100%** completeness
- Worst-covered: narrow natural capital sub-components (e.g. `NW.NCA.CROP`, `NW.NCA.FOWL`, `NW.NCA.MINF` — specific crop, timber, or mineral types) at **51.7%**, since these are only estimated for countries where that particular resource is economically significant

**By country**
- Best-covered countries reach up to **82.8%** (e.g. Albania, Algeria, Angola)
- Least-covered are typically small or data-poor states where detailed natural capital estimation is not feasible

**By year**
- Coverage builds progressively from 1995 through the late 1990s and 2000s, reaching a broad plateau through the 2010s
- The database's methodology matured over this period, resulting in fairly consistent (rather than sharply peaking) completeness across most of the available years

## Files in this folder

- `README.md` — this document
- `wealthaccounts_ready_to_use.R` — ready-to-use script to download custom country/indicator/year selections
- `audit_WealthAccounts.R` — full script (download, processing, export)
- `missing_values_report_WealthAccounts.csv` — detailed missing-values report (country x series)
- `completeness_stats_by_series_WealthAccounts.csv` — % completeness by series
- `completeness_stats_by_country_WealthAccounts.csv` — % completeness by country
- `completeness_stats_by_year_WealthAccounts.csv` — % completeness by year
- `wealth_accounts_categories.csv` — indicator-to-category mapping
