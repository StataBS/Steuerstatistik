# Install packages

# Function that automatically installs and downloads packages
install_and_load <- function(packages) {
  # Set the repository for package installation
  options(repos = "https://cloud.r-project.org")

  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      cat(sprintf("📦 Installiere fehlendes Paket: %s\n", pkg))
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
    } else {
      cat(sprintf("✅ Paket bereits installiert: %s\n", pkg))
    }
    library(pkg, character.only = TRUE)
    cat(sprintf("library(%s)\n", pkg))
  }
}

# List of required packages
required_packages <- c(
  "DBI",
  "httr",
  "data.table",
  "dplyr",
  "odbc",
  "stringr",
  "tidyr",
  "readr"
)

# Install and download all required packages
install_and_load(required_packages)
