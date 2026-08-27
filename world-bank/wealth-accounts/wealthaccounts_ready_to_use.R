# ==============================================================================
# WEALTH ACCOUNTS - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the Wealth Accounts database, without having to know the WDI
# package syntax by heart.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# wealth_accounts_categories.csv in this folder to browse indicators by
# wealth component (natural capital, human capital, produced capital...)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: Wealth Accounts codes. A few top-level totals and a
# natural capital example are pre-filled below — replace as needed.
INDICATORS <- c(
  "NW.TOW.TO.CD",   # National comprehensive wealth (current US$)
  "NW.DOW.TO.CD",   # Domestic comprehensive wealth (current US$)
  "NW.PCA.TO",      # Produced capital (real chained 2019 US$)
  "NW.HCA.TO",      # Human capital (real chained 2019 US$)
  "NW.NFA.TO.CD"    # Net foreign assets (current US$)
)

# Years: Wealth Accounts covers 1995-2018
START_YEAR <- 1995
END_YEAR   <- 2018

# Output file name
OUTPUT_FILE <- "my_wealth_accounts_data.csv"

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
# with a topic (e.g. "natural capital", "produced capital", "human capital"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by wealth component using the category mapping built
# for this database. Uncomment and run:
#
# categories <- read.csv("wealth_accounts_categories.csv")
# unique(categories$category)                            # list all 7 components
# subset(categories, category == "Natural Capital")       # browse one component


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
