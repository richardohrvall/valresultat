parse_personval_2026 <- function(raw) {

  valtyp <- as_chr_na(raw$valtyp)
  valomrade <- raw$valomrade

  geografiniva_valomrade <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riket",
    "RF" ~ "region",
    "KF" ~ "kommun",
    default = NA_character_
  )

  geografiniva_valkrets <- dplyr::recode_values(
    valtyp,
    "RD" ~ "riksdagsvalkrets",
    "RF" ~ "regionvalkrets",
    "KF" ~ "kommunvalkrets",
    default = NA_character_
  )

  empty_personval <- function() {
    tibble::tibble(
      valtillfalle = character(),
      valklass = character(),
      rakningstillfalle = character(),
      valtyp = character(),
      valdatum = character(),
      valdatum_fg = character(),
      test = logical(),
      geografiniva = character(),
      valomradeskod = character(),
      valomradesnamn = character(),
      valkretskod = character(),
      valkretsnamn = character(),
      partikod = character(),
      partiforkortning = character(),
      partifarg = character(),
      kandidatnummer = character(),
      namn = character(),
      antal_personroster = integer(),
      andel_personroster = double()
    )
  }

  parse_lista <- function(
      lista,
      geografiniva,
      valkretskod = NA_character_,
      valkretsnamn = NA_character_
  ) {

    if (is.null(lista) || length(lista) == 0) {
      return(empty_personval())
    }

    purrr::map_dfr(
      lista,
      \(x) tibble::tibble(
        valtillfalle = as_chr_na(raw$valtillfalle),
        valklass = as_chr_na(raw$valklass),
        rakningstillfalle = as_chr_na(raw$rakningstillfalle),
        valtyp = valtyp,
        valdatum = as_chr_na(raw$valdatum),
        valdatum_fg = as_chr_na(raw$tidigareValdatum),
        test = as_lgl_na(raw$test),
        geografiniva = geografiniva,
        valomradeskod = as_chr_na(valomrade$kod),
        valomradesnamn = as_chr_na(valomrade$namn),
        valkretskod = dplyr::coalesce(
          as_chr_na(x$valkretskod),
          valkretskod
        ),
        valkretsnamn = valkretsnamn,
        partikod = as_chr_na(x$partikod),
        partiforkortning = as_chr_na(x$partiforkortning),
        partifarg = as_chr_na(x$partifarg),
        kandidatnummer = as_chr_na(x$kandidatnummer),
        namn = as_chr_na(x$namn),
        antal_personroster = as_int_na(x$antalPersonroster),
        andel_personroster = as_dbl_na(x$andelPersonroster)
      )
    )
  }

  valkretsar <- valomrade$valkretsLista

  if (!is.null(valkretsar) && length(valkretsar) > 0) {

    available <- purrr::some(
      valkretsar,
      \(vk) {
        "kvalificeradeForPersonvalLista" %in% names(vk) &&
          !is.null(vk$kvalificeradeForPersonvalLista)
      }
    )

    out <- valkretsar |>
      purrr::map(
        \(vk) parse_lista(
          lista = vk$kvalificeradeForPersonvalLista,
          geografiniva = geografiniva_valkrets,
          valkretskod = as_chr_na(vk$kod),
          valkretsnamn = as_chr_na(vk$namnValkrets)
        )
      ) |>
      purrr::list_rbind()

    attr(out, "personval_available") <- available
    return(out)
  }

  available <-
    "kvalificeradeForPersonvalLista" %in% names(valomrade) &&
    !is.null(valomrade$kvalificeradeForPersonvalLista)

  out <- parse_lista(
    lista = valomrade$kvalificeradeForPersonvalLista,
    geografiniva = geografiniva_valomrade
  )

  attr(out, "personval_available") <- available
  out
}
