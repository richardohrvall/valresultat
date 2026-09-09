# Run from the repository root with Rscript --vanilla development/check.R.
# Keep temporary files and optional development dependencies inside the repo.
local_lib <- file.path(getwd(), ".r-lib")
if (dir.exists(local_lib)) .libPaths(c(local_lib, .libPaths()))

roxygen2::roxygenise(".")
testthat::test_local(".", reporter = "summary", stop_on_failure = TRUE)
