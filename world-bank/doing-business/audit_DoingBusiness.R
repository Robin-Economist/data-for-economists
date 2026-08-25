# ==============================================================================
# COMPLETENESS AUDIT - Doing Business, World Bank
# ==============================================================================
#
# Same method as the WDI and Education Statistics audits (see
# world-bank/wdi/audit_WDI_final_en.R and
# world-bank/education-statistics/audit_EdStats_final.R), applied to the
# "Doing Business" database (~190 series — ease of doing business
# indicators by country).
#
# GENERAL STRATEGY (reminder)
# No step loads the full dataset into memory at once:
#   - Download in batches of 20 series
#   - Each processing step handles one batch at a time, saves its
#     intermediate result, then clears memory (rm + gc)
#   - Every step resumes automatically where it left off
#     (`if (file.exists(out_path)) next`)
#
# ==============================================================================

library(WDI)
library(dplyr)
library(tidyr)

# ===== 1. Load metadata and target the Doing Business database =====
meta <- WDIcache()
db_name <- "Doing Business"
series_codes <- meta$series$indicator[meta$series$sourceDatabase == db_name]

length(series_codes)  # expect ~190


# ===== 2. Download raw data, in batches =====
folder <- "audit_DoingBusiness"
dir.create(folder, showWarnings = FALSE)

batch_size <- 20
n_batches <- ceiling(length(series_codes) / batch_size)

options(timeout = 120)

cat("Total batches to process:", n_batches, "\n")
cat("Batches already present:", length(list.files(folder)), "/", n_batches, "\n")

for (i in 1:n_batches) {
  out_path <- paste0(folder, "/batch_", i, ".rds")
  if (file.exists(out_path)) next

  start_idx <- (i - 1) * batch_size + 1
  end_idx <- min(i * batch_size, length(series_codes))
  batch_codes <- series_codes[start_idx:end_idx]

  cat(as.character(Sys.time()), "- Batch", i, "/", n_batches, "\n")

  result <- tryCatch({
    WDI(indicator = batch_codes, country = "all", start = 1960, end = 2025, extra = FALSE)
  }, error = function(e) {
    cat("  Error:", conditionMessage(e), "\n")
    return(NULL)
  })

  if (!is.null(result)) saveRDS(result, out_path)
  Sys.sleep(3)
}

cat("Batches downloaded:", length(list.files(folder)), "/", n_batches, "\n")

# ----- Safety check: identify and retry any still-missing batches -----
batches_present <- as.numeric(gsub("[^0-9]", "",
                                    gsub("batch_|\\.rds", "", list.files(folder))))
batches_missing <- setdiff(1:n_batches, batches_present)

if (length(batches_missing) > 0) {
  cat("Retrying", length(batches_missing), "missing batch(es):", batches_missing, "\n")

  for (i in batches_missing) {
    out_path <- paste0(folder, "/batch_", i, ".rds")
    if (file.exists(out_path)) next

    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, length(series_codes))
    batch_codes <- series_codes[start_idx:end_idx]

    cat(as.character(Sys.time()), "- Retry batch", i, "/", n_batches, "\n")

    result <- tryCatch({
      WDI(indicator = batch_codes, country = "all", start = 1960, end = 2025, extra = FALSE)
    }, error = function(e) {
      cat("  Error:", conditionMessage(e), "\n")
      return(NULL)
    })

    if (!is.null(result)) saveRDS(result, out_path)
    Sys.sleep(3)
  }
}

cat("Final batch count:", length(list.files(folder)), "/", n_batches, "\n")


# ===== 3. Compute full detail: indicator x country x year x status =====
raw_files <- list.files("audit_DoingBusiness", full.names = TRUE)
dir.create("audit_detail_DoingBusiness", showWarnings = FALSE)

for (f in raw_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- paste0("audit_detail_DoingBusiness/", batch_name, "_detail.rds")

  if (file.exists(out_path)) next

  cat("Detail:", batch_name, "\n")

  batch_data <- readRDS(f)

  long_data <- batch_data %>%
    pivot_longer(
      cols = -c(country, iso2c, iso3c, year),
      names_to = "indicator",
      values_to = "value"
    )

  detail_batch <- long_data %>%
    mutate(missing = is.na(value)) %>%
    select(indicator, country, iso3c, year, missing)

  saveRDS(detail_batch, out_path)

  rm(batch_data, long_data, detail_batch)
  gc()
}

cat("Detail files:", length(list.files("audit_detail_DoingBusiness")), "\n")


# ===== 4. Utility function: group years into compact ranges =====
group_years <- function(years) {
  years <- sort(unique(years))
  if (length(years) == 0) return("")

  diffs <- c(1, diff(years))
  group_id <- cumsum(diffs != 1)
  groups <- split(years, group_id)

  ranges <- sapply(groups, function(g) {
    if (length(g) == 1) as.character(g) else paste0(min(g), "-", max(g))
  })

  paste(ranges, collapse = ", ")
}


# ===== 5. Build the final report: one row per (country, series) =====
detail_files <- list.files("audit_detail_DoingBusiness", full.names = TRUE)
dir.create("missing_report_DoingBusiness", showWarnings = FALSE)

for (f in detail_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- paste0("missing_report_DoingBusiness/", batch_name, "_report.rds")

  if (file.exists(out_path)) next

  cat("Report:", batch_name, "\n")

  d <- readRDS(f)

  report_batch <- d %>%
    filter(missing == TRUE) %>%
    group_by(indicator, country, iso3c) %>%
    summarise(
      missing_years = group_years(year),
      nb_missing_years = n(),
      .groups = "drop"
    )

  saveRDS(report_batch, out_path)

  rm(d, report_batch)
  gc()
}

cat("Report files:", length(list.files("missing_report_DoingBusiness")), "\n")


# ===== 6. Export the consolidated report as a single CSV =====
report_files <- list.files("missing_report_DoingBusiness", full.names = TRUE)

output_csv <- "missing_values_report_DoingBusiness.csv"
if (file.exists(output_csv)) file.remove(output_csv)

for (f in report_files) {
  d <- readRDS(f)
  write.table(
    d, output_csv, sep = ",", row.names = FALSE,
    col.names = !file.exists(output_csv), append = TRUE
  )
  rm(d)
  gc()
}

cat("Export complete:", output_csv, "\n")


# ==============================================================================
# COMPLETENESS STATISTICS
# ==============================================================================

dir.create("completeness_stats_DoingBusiness", showWarnings = FALSE)

# ----- By series -----
for (f in detail_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- paste0("completeness_stats_DoingBusiness/", batch_name, "_by_series.rds")
  if (file.exists(out_path)) next

  d <- readRDS(f)

  by_series <- d %>%
    group_by(indicator) %>%
    summarise(
      total_obs = n(),
      missing_obs = sum(missing),
      .groups = "drop"
    )

  saveRDS(by_series, out_path)
  rm(d, by_series)
  gc()
}

by_series_files <- list.files("completeness_stats_DoingBusiness", pattern = "_by_series.rds", full.names = TRUE)

completeness_by_series <- bind_rows(lapply(by_series_files, readRDS)) %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)

write.csv(completeness_by_series, "completeness_stats_by_series_DoingBusiness.csv", row.names = FALSE)

# ----- By country -----
for (f in detail_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- paste0("completeness_stats_DoingBusiness/", batch_name, "_by_country.rds")
  if (file.exists(out_path)) next

  d <- readRDS(f)

  by_country <- d %>%
    group_by(country, iso3c) %>%
    summarise(
      total_obs = n(),
      missing_obs = sum(missing),
      .groups = "drop"
    )

  saveRDS(by_country, out_path)
  rm(d, by_country)
  gc()
}

by_country_files <- list.files("completeness_stats_DoingBusiness", pattern = "_by_country.rds", full.names = TRUE)

completeness_by_country <- bind_rows(lapply(by_country_files, readRDS)) %>%
  group_by(country, iso3c) %>%
  summarise(
    total_obs = sum(total_obs),
    missing_obs = sum(missing_obs),
    .groups = "drop"
  ) %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(completeness_rate)

write.csv(completeness_by_country, "completeness_stats_by_country_DoingBusiness.csv", row.names = FALSE)

# ----- By year -----
for (f in detail_files) {
  batch_name <- tools::file_path_sans_ext(basename(f))
  out_path <- paste0("completeness_stats_DoingBusiness/", batch_name, "_by_year.rds")
  if (file.exists(out_path)) next

  d <- readRDS(f)

  by_year <- d %>%
    group_by(year) %>%
    summarise(
      total_obs = n(),
      missing_obs = sum(missing),
      .groups = "drop"
    )

  saveRDS(by_year, out_path)
  rm(d, by_year)
  gc()
}

by_year_files <- list.files("completeness_stats_DoingBusiness", pattern = "_by_year.rds", full.names = TRUE)

completeness_by_year <- bind_rows(lapply(by_year_files, readRDS)) %>%
  group_by(year) %>%
  summarise(
    total_obs = sum(total_obs),
    missing_obs = sum(missing_obs),
    .groups = "drop"
  ) %>%
  mutate(completeness_rate = round(100 * (1 - missing_obs / total_obs), 1)) %>%
  arrange(year)

write.csv(completeness_by_year, "completeness_stats_by_year_DoingBusiness.csv", row.names = FALSE)


# ----- Quick previews -----
cat("\n--- Top 10 LEAST complete series ---\n")
print(head(completeness_by_series, 10))

cat("\n--- Top 10 MOST complete series ---\n")
print(tail(completeness_by_series, 10))

cat("\n--- Top 10 LEAST complete countries ---\n")
print(head(completeness_by_country, 10))

cat("\n--- Top 10 MOST complete countries ---\n")
print(tail(completeness_by_country, 10))

cat("\n--- Completeness by year (preview) ---\n")
print(completeness_by_year, n = 66)
