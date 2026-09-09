# Optional setup; installs only into the repository-local development library.
local_lib <- file.path(getwd(), ".r-lib")
dir.create(local_lib, showWarnings = FALSE)
.libPaths(c(local_lib, .libPaths()))
repos <- "https://cloud.r-project.org"
packages <- c("roxygen2", "testthat", "dplyr", "janitor", "jsonlite", "purrr", "readr", "stringr", "tibble")
available <- available.packages(repos = repos, type = "binary")
dependencies <- tools::package_dependencies(
  packages, db = available, which = c("Depends", "Imports", "LinkingTo"), recursive = TRUE
)
needed <- intersect(unique(c(packages, unlist(dependencies))), rownames(available))
needed <- setdiff(needed, rownames(installed.packages(lib.loc = local_lib)))
if (length(needed)) install.packages(needed, lib = local_lib, repos = repos, type = "binary")
