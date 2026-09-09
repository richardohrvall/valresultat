parse_index_2026 <- function(index) {

  match <- stringr::str_match(
    index,
    "^([[:xdigit:]]{32})\\s+\\./(.+)$"
  )

  tibble::tibble(
    md5 = tolower(match[, 2]),
    path = match[, 3]
  ) |>
    dplyr::filter(!is.na(path))
}
