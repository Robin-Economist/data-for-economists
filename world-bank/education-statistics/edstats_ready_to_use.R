# ==============================================================================
# EDUCATION STATISTICS - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the Education Statistics database, without having to know the WDI
# package syntax by heart.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# education_statistics_categories.csv in this folder to browse
# indicators by theme (enrollment, test scores, expenditure, etc.)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: Education Statistics codes. A few common examples are
# pre-filled below — replace them with the ones you need.
INDICATORS <- c(
  "SE.PRM.ENRR",        # Primary school enrollment (% gross)
  "SE.SEC.ENRR",        # Secondary school enrollment (% gross)
  "SE.TER.ENRR",        # Tertiary school enrollment (% gross)
  "SE.ADT.LITR.ZS",     # Adult literacy rate (% ages 15+)
  "SE.XPD.TOTL.GD.ZS",  # Government expenditure on education (% of GDP)
  "SE.PRM.CMPT.ZS",     # Primary completion rate (% of relevant age group)
  "LO.PISA.MAT"         # PISA mean performance on the mathematics scale
)

# Years: start and end (WDI requires start >= 1960)
START_YEAR <- 2000
END_YEAR   <- 2023

# Output file name
OUTPUT_FILE <- "my_education_data.csv"

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
# with a topic (e.g. "literacy", "PISA", "expenditure", "teacher"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by theme using the category mapping built for this
# database. Uncomment and run:
#
# categories <- read.csv("education_statistics_categories.csv")
# unique(categories$category)                                    # list all themes
# subset(categories, category == "Learning Outcomes & Test Scores") # browse one theme


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
