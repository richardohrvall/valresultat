read_kandidaturer_2026 <- function(file) {

  readr::read_delim(
    file,
    delim = ";",
    col_types = readr::cols(.default = readr::col_character()),
    na = "",
    trim_ws = FALSE,
    show_col_types = FALSE,
    progress = FALSE
  ) |>
    janitor::clean_names() |>
    parse_kandidaturer_2026()
}
