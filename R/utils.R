# Hjälpfunktioner för att läsa skalära värden ur Valmyndighetens JSON.
# NULL och tomma värden omvandlas till typade NA.

as_chr_na <- \(x) {
  if (is.null(x) || length(x) == 0) {
    NA_character_
  } else {
    as.character(x[[1]])
  }
}

as_int_na <- \(x) {
  if (is.null(x) || length(x) == 0) {
    NA_integer_
  } else {
    as.integer(x[[1]])
  }
}

as_dbl_na <- \(x) {
  if (is.null(x) || length(x) == 0) {
    NA_real_
  } else {
    as.double(x[[1]])
  }
}

as_lgl_na <- \(x) {
  if (is.null(x) || length(x) == 0) {
    NA
  } else {
    as.logical(x[[1]])
  }
}

.normalisera_rakningstillfalle_2026 <- function(x) {
  x <- as_chr_na(x)
  if (identical(x, "prelimin\u00e4r")) "preliminar" else x
}

.normalisera_rakningsmetadata_2026 <- function(raw) {
  if (is.list(raw) && "rakningstillfalle" %in% names(raw)) {
    raw$rakningstillfalle <- .normalisera_rakningstillfalle_2026(
      raw$rakningstillfalle
    )
  }
  raw
}

.rostfordelning_tillganglig_2026 <- function(obj, namn = "omr\u00e5de") {
  if (!is.list(obj) || is.null(names(obj)) || anyDuplicated(names(obj)) ||
      !"rostfordelning" %in% names(obj)) {
    stop("Saknad nyckel `rostfordelning` i ", namn, ".", call. = FALSE)
  }
  !is.null(obj$rostfordelning)
}
