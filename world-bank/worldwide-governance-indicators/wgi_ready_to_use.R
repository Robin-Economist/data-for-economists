# ==============================================================================
# WORLDWIDE GOVERNANCE INDICATORS (WGI) - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the WGI database, without having to know the WDI package syntax
# by heart.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# wgi_categories.csv in this folder to browse indicators by governance
# dimension (Voice and Accountability, Rule of Law, etc.)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: WGI codes. The 6 "estimate" variants (one per governance
# dimension) are pre-filled below — replace them with the ones you need.
INDICATORS <- c(
  "GOV_WGI_VA.EST",  # Voice and Accountability
  "GOV_WGI_PV.EST",  # Political Stability
  "GOV_WGI_GE.EST",  # Government Effectiveness
  "GOV_WGI_RQ.EST",  # Regulatory Quality
  "GOV_WGI_RL.EST",  # Rule of Law
  "GOV_WGI_CC.EST"   # Control of Corruption
)

# Years: WGI covers 1996-2024 (biannual until 2002, annual from 2003)
START_YEAR <- 1996
END_YEAR   <- 2024

# Output file name
OUTPUT_FILE <- "my_wgi_data.csv"

# ===== END OF PARAMETERS — no need to edit below this line =====


# ----- Download -----
cat("Downloading", length(INDICATORS), "indicator(s) for",
    ifelse(length(COUNTRIES) == 1 && COUNTRIES == "all", "all countries", paste(length(COUNTRIES), "countries")),
    "from", START_YEAR, "to", END_YEAR, "...\n")

my_data <- WDI(
  indicator = INDICATORS,
  country = COUNTRIES,
  start = START_YEAR,
  end = END_YEAR,
  extra = FALSE
)

cat("Done. Rows downloaded:", nrow(my_data), "\n")

# ----- Preview -----
head(my_data)

# ----- Save to CSV -----
write.csv(my_data, OUTPUT_FILE, row.names = FALSE)
cat("Saved to:", OUTPUT_FILE, "\n")


# ==============================================================================
# HOW TO FIND INDICATOR CODES
# ==============================================================================
# Option 1 — search by keyword. Uncomment and run, replacing "keyword"
# with a topic (e.g. "corruption", "rule of law", "regulatory"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by governance dimension using the category mapping
# built for this database. Uncomment and run:
#
# categories <- read.csv("wgi_categories.csv")
# unique(categories$category)                                     # list all 6 dimensions
# subset(categories, category == "Rule of Law (RL)")               # browse one dimension


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
