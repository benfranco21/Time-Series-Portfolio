# Check that the data files the portfolio needs are in place.
# Run from the project root: Rscript check_data.R
# It never downloads anything and never changes the existing data files.

sp500_csv  <- file.path("data", "sp500_stocks.csv")
eskom_csv  <- file.path("data", "ESK19847.csv")
eskom_rds  <- file.path("data", "eskom_daily_peak.rds")
prep_script <- file.path("projects", "project-03-eskom-demand", "R", "load_eskom.R")

ok <- TRUE

if (file.exists(sp500_csv)) {
  cat("OK      ", sp500_csv, "\n")
} else {
  ok <- FALSE
  cat("MISSING ", sp500_csv, "\n")
  cat("  Needed by Projects 1 and 2 and the fundamentals practical.\n")
  cat("  1. Sign in to Kaggle.\n")
  cat("  2. Open https://www.kaggle.com/datasets/darkmatternet/s-and-p-500-stocks-25-years-of-data-updated-daily\n")
  cat("  3. Choose version 140, download and unzip it.\n")
  cat("  4. Save the daily prices file as", sp500_csv, "\n")
}

if (file.exists(eskom_csv)) {
  cat("OK      ", eskom_csv, "\n")
} else {
  cat("MISSING ", eskom_csv, "\n")
  cat("  Only needed to rebuild", eskom_rds, "from the raw data.\n")
  cat("  1. Request file ESK19847 (hourly RSA Contracted Demand and RSA Contracted Forecast,\n")
  cat("     1 April 2022 to 27 September 2026) through https://www.eskom.co.za/dataportal/data-request-form/\n")
  cat("  2. Save it as", eskom_csv, "\n")
}

if (file.exists(eskom_rds)) {
  cat("OK      ", eskom_rds, "\n")
} else if (file.exists(eskom_csv) && file.exists(prep_script)) {
  cat("MISSING ", eskom_rds, "- building it with", prep_script, "\n")
  source(prep_script)
  if (file.exists(eskom_rds)) cat("OK      ", eskom_rds, "built\n")
} else {
  ok <- FALSE
  cat("MISSING ", eskom_rds, "\n")
  cat("  Needed by Projects 3 and 4. It is in the repository, so restore it with git,\n")
  cat("  or place", eskom_csv, "and run this script again to rebuild it.\n")
}

if (ok) {
  cat("\nAll data needed to render the site is in place. Run quarto render.\n")
} else {
  cat("\nSome data is missing. Follow the steps above, then run this script again.\n")
}
