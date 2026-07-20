# ==============================================================================
# DOING BUSINESS - READY-TO-USE DOWNLOAD SCRIPT
# ==============================================================================
#
# Purpose: download exactly the countries, indicators, and years you need
# from the Doing Business database, without having to know the WDI
# package syntax by heart.
#
# Note: Doing Business was discontinued by the World Bank in 2021 — data
# only covers 2003-2019. See this folder's README.md for context.
#
# HOW TO USE
# 1. Edit the three lists below (COUNTRIES, INDICATORS, YEARS)
# 2. Run the whole script
# 3. Your data appears in the `my_data` dataframe, and is also saved
#    as a CSV file
#
# TIP: to find indicator codes, use WDIsearch("keyword"), or check
# doing_business_categories.csv in this folder to browse indicators
# by theme (starting a business, paying taxes, trading across borders, etc.)
#
# ==============================================================================

library(WDI)

# ===== PARAMETERS — edit this section =====

# Countries: use ISO 3-letter codes (e.g. "FRA" for France, "USA" for
# United States). Set COUNTRIES <- "all" to include every country.
# Note: some entries in this database are major cities rather than
# countries (e.g. Beijing, Delhi, Lahore) for certain indicators.
COUNTRIES <- c("FRA", "DEU", "ITA", "ESP", "GBR", "USA", "JPN", "CHN", "IND", "BRA")

# Indicators: Doing Business codes. A few common examples are
# pre-filled below — replace them with the ones you need.
INDICATORS <- c(
  "IC.REG.DURS",        # Time required to start a business (days)
  "IC.REG.COST.PC.ZS",  # Cost of business start-up procedures (% of GNI per capita)
  "IC.TAX.TOTL.CP.ZS",  # Total tax and contribution rate (% of profit)
  "IC.CRED.INFO.XQ",    # Depth of credit information index
  "IC.LGL.CRED.XQ",     # Strength of legal rights index
  "IC.EXP.TMDR",        # Time to export, border compliance (hours)
  "IC.ISV.DURS"         # Time to resolve insolvency (years)
)

# Years: Doing Business only covers 2003-2019 (program discontinued in 2021)
START_YEAR <- 2003
END_YEAR   <- 2019

# Output file name
OUTPUT_FILE <- "my_doing_business_data.csv"

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
# with a topic (e.g. "tax", "insolvency", "credit", "construction"):
#
# WDIsearch("keyword")
#
# Option 2 — browse by theme using the category mapping built for this
# database. Uncomment and run:
#
# categories <- read.csv("doing_business_categories.csv")
# unique(categories$category)                                  # list all themes
# subset(categories, category == "Paying Taxes")                # browse one theme


# ==============================================================================
# HOW TO FIND COUNTRY CODES
# ==============================================================================
# Uncomment and run the lines below to see the full list of country
# names and their ISO codes:
#
# meta <- WDIcache()
# View(meta$country)
