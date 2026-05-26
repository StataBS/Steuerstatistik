cat("🔍 Starte bootstrap_packages.R\n")

install_and_load <- function(packages) {

  options(repos = c(CRAN = "https://cloud.r-project.org"))

  if (.Platform$OS.type == "windows") {
    options(download.file.method = "wininet")
  }

  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat(sprintf("📦 Installiere fehlendes Paket: %s\n", pkg))
      ok <- tryCatch(
        {
          install.packages(
            pkg,
            dependencies = TRUE,
            quiet = TRUE,
            type = if (.Platform$OS.type == "windows") "binary" else "source"
          )
          TRUE
        },
        error = function(e) {
          cat(sprintf("❌ Installation fehlgeschlagen (%s): %s\n", pkg, conditionMessage(e)))
          FALSE
        }
      )

      # Wenn Installation fehlgeschlagen: nicht sofort library() versuchen
      if (!ok || !requireNamespace(pkg, quietly = TRUE)) {
        stop(sprintf("Paket konnte nicht installiert werden und ist nicht verfügbar: %s", pkg))
      }
    } else {
      cat(sprintf("✅ Paket bereits installiert: %s\n", pkg))
    }

    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    cat(sprintf("library(%s)\n", pkg))
  }
}

required_packages <- c("tidyverse", "later", "DBI", "odbc", "openxlsx")
install_and_load(required_packages)
