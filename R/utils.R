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
