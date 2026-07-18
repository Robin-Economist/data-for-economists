# WDI Completeness Audit — Summary Report

> **World Bank &bull; World Development Indicators**
> A data-quality map of the WDI database: which countries, which series, and which years have missing data — and how much.

## Key figures

| Metric | Value |
|---|---|
| Series analyzed | 1,510 |
| Countries / regions | 265 |
| Years covered | 1960 – 2025 (66 years) |
| Country–series pairs with a gap | 347,097 |
| Series with at least one gap | 1,397 / 1,510 |
| Series 100% complete | ~113 |

*data-for-economists project — audit produced with the R package `WDI`, via exhaustive batch download of the full database.*

---

## Methodology

The entire World Development Indicators database was downloaded via the World Bank API (R package `WDI`), in batches of 20 series to work around API instability on large volumes. For each indicator × country × year combination, a present/missing status was computed, then grouped by (country, series) pair to precisely identify missing year ranges.

> ⚠️ **Important methodological note**
>
> Completeness rates in this report are calculated over the full 1960–2025 window. Many WDI series only started being collected several decades after 1960 (environmental, governance, or recent financial indicators). A rate of 50% therefore does **not** mean that half of the *relevant* data is missing — it mechanically reflects this extended time window. For illustration, even Peru, one of the best-covered countries, has only 77 out of 1,397 series that are completely empty; most series have partial rather than zero coverage, concentrated in recent decades.

**Processing steps:**
1. Download all ~1,510 series × all countries × 1960–2025, in batches of 20 series
2. Reshape to long format: one row = indicator × country × year
3. Flag each combination as present or missing
4. Group missing years into readable ranges per (country, series) pair

---

## Completeness by series

Out of 1,510 series, 1,397 have at least one missing value. The least complete concern very specific construction-permit indicators, almost never reported; the most complete concern basic demographic breakdowns collected almost systematically.

**10 least complete series**

| Rank | Series | % completeness |
|---|---|---|
| 1 | IC.BRE.BE.OS — Building permits, other | 0.3% |
| 2 | IC.BRE.BE.P1 — Building permits, procedure 1 | 0.3% |
| 3 | IC.BRE.BE.P2 — Building permits, procedure 2 | 0.3% |
| 4 | IC.BRE.BE.P3 — Building permits, procedure 3 | 0.3% |
| 5 | IC.BRE.BI.OS — Building permits (index), other | 0.3% |
| 6 | IC.BRE.BI.P1 — Building permits (index), proc. 1 | 0.3% |
| 7 | IC.BRE.BI.P2 — Building permits (index), proc. 2 | 0.3% |
| 8 | IC.BRE.BI.P3 — Building permits (index), proc. 3 | 0.3% |
| 9 | IC.BRE.BL.OS — Building permits (list), other | 0.3% |
| 10 | IC.BRE.BL.P1 — Building permits (list), proc. 1 | 0.3% |

**10 most complete series**

| Rank | Series | % completeness |
|---|---|---|
| 1 | SP.POP.65UP.MA.ZS — Population 65+, male (%) | 99.6% |
| 2 | SP.POP.65UP.TO.ZS — Population 65+, total (%) | 99.6% |
| 3 | SP.POP.7074.FE.5Y — Population female 70–74 | 99.6% |
| 4 | SP.POP.7074.MA.5Y — Population male 70–74 | 99.6% |
| 5 | SP.POP.7579.FE.5Y — Population female 75–79 | 99.6% |
| 6 | SP.POP.7579.MA.5Y — Population male 75–79 | 99.6% |
| 7 | SP.POP.80UP.FE.5Y — Population female 80+ | 99.6% |
| 8 | SP.POP.80UP.MA.5Y — Population male 80+ | 99.6% |
| 9 | SP.POP.TOTL.FE.ZS — Population, female (%) | 99.6% |
| 10 | SP.RUR.TOTL.ZS — Rural population (%) | 99.6% |

Full detail for all 1,510 series: see [`completeness_stats_by_series.csv`](./completeness_stats_by_series.csv)

---

## Completeness by country

The least complete entities are very small territories or special classification cases. Among large countries, the maximum completeness observed plateaus around 50% (see methodological note) — Latin American and Southeast Asian countries dominate this ranking.

**10 least complete countries / regions**

| Rank | Country / region | % completeness |
|---|---|---|
| 1 | Not classified | 0% |
| 2 | St. Martin (French part) | 6.3% |
| 3 | Channel Islands | 8.6% |
| 4 | Isle of Man | 8.6% |
| 5 | Sint Maarten (Dutch part) | 9% |
| 6 | Northern Mariana Islands | 9.2% |
| 7 | Gibraltar | 10.3% |
| 8 | Curaçao | 10.7% |
| 9 | American Samoa | 11% |
| 10 | Liechtenstein | 11.3% |

**10 most complete countries**

| Rank | Country | % completeness |
|---|---|---|
| 1 | Peru | 49.8% |
| 2 | Mexico | 49.5% |
| 3 | Colombia | 49.3% |
| 4 | India | 48% |
| 5 | Indonesia | 47.8% |
| 6 | Ecuador | 47.7% |
| 7 | Dominican Republic | 47.6% |
| 8 | Brazil | 47.6% |
| 9 | Egypt, Arab Rep. | 47.5% |
| 10 | Thailand | 47.3% |

Full detail for all 265 countries/regions: see [`completeness_stats_by_country.csv`](./completeness_stats_by_country.csv)

---

## Completeness by year

Overall completeness improves over time: few series existed in the 1960s, and coverage broadened as new indicators were created and data collection expanded to more countries.

| Year | % completeness |
|---|---|
| 1960 | 9.4% |
| 1961 | 10.9% |
| 1962 | 11.2% |
| 1965 | 12.1% |
| 1969 | 12.6% |
| ... | ... |

Full detail for all 66 years: see [`completeness_stats_by_year.csv`](./completeness_stats_by_year.csv)

---

## Going further

This document summarizes general trends. For a fine-grained exploration — exactly which years are missing for a given country and series — see [`missing_values_report_WDI.csv`](./missing_values_report_WDI.csv), which details, for each of the 347,097 affected country–series combinations, the exact list of years without data. The full R script behind this audit ([`audit_WDI_final_en.R`](./audit_WDI_final_en.R)) is also available in this folder to reproduce or extend this analysis.
