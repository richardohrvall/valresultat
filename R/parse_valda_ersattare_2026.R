parse_valda_ersattare_2026 <- function(raw) {

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

  empty_valda <- function() {
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
      partibeteckning = character(),
      partiforkortning = character(),
      partikod = character(),
      partifarg = character(),
      kandidatnummer = character(),
      namn = character(),
      invalsordning = integer(),
      valgrund_id = character(),
      valgrund_text = character(),
      ersattargrupp = character()
    )
  }

  empty_ersattare <- function() {
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
      partibeteckning = character(),
      partiforkortning = character(),
      partikod = character(),
      partifarg = character(),
      ledamot_kandidatnummer = character(),
      ledamot_namn = character(),
      ersattargrupp = character(),
      ersattare_kandidatnummer = character(),
      ersattare_namn = character(),
      ersattarordning = integer(),
      valgrund_id = character(),
      valgrund_text = character()
    )
  }

  parse_niva <- function(
      valda,
      geografiniva,
      valkretskod = NA_character_,
      valkretsnamn = NA_character_
  ) {

    if (is.null(valda) ||
        is.null(valda$partiLedamoterLista) ||
        length(valda$partiLedamoterLista) == 0) {
      return(list(
        valda = empty_valda(),
        ersattare = empty_ersattare()
      ))
    }

    parti_list <- valda$partiLedamoterLista

    valda_rows <- purrr::map_dfr(
      parti_list,
      \(parti) {

        ledamoter <- parti$ledamoter

        if (is.null(ledamoter) || length(ledamoter) == 0) {
          return(empty_valda())
        }

        purrr::map_dfr(
          ledamoter,
          \(ledamot) tibble::tibble(
            valtillfalle = as_chr_na(raw$valtillfalle),
            valklass = as_chr_na(raw$valklass),
            rakningstillfalle = .normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
            valtyp = valtyp,
            valdatum = as_chr_na(raw$valdatum),
            valdatum_fg = as_chr_na(raw$tidigareValdatum),
            test = as_lgl_na(raw$test),
            geografiniva = geografiniva,
            valomradeskod = as_chr_na(valomrade$kod),
            valomradesnamn = as_chr_na(valomrade$namn),
            valkretskod = valkretskod,
            valkretsnamn = valkretsnamn,
            partibeteckning = as_chr_na(parti$partibeteckning),
            partiforkortning = as_chr_na(parti$partiforkortning),
            partikod = as_chr_na(parti$partikod),
            partifarg = as_chr_na(parti$partiFarg),
            kandidatnummer = as_chr_na(ledamot$kandidatnummer),
            namn = as_chr_na(ledamot$namn),
            invalsordning = as_int_na(ledamot$invalsordning),
            valgrund_id = as_chr_na(ledamot$valgrundId),
            valgrund_text = as_chr_na(ledamot$valgrundText),
            ersattargrupp = as_chr_na(ledamot$ersattargrupp)
          )
        )
      }
    )

    ersattare_rows <- purrr::map_dfr(
      parti_list,
      \(parti) {

        ledamoter <- parti$ledamoter

        if (is.null(ledamoter) || length(ledamoter) == 0) {
          return(empty_ersattare())
        }

        purrr::map_dfr(
          ledamoter,
          \(ledamot) {

            ersattare <- ledamot$ersattareList

            if (is.null(ersattare) || length(ersattare) == 0) {
              return(empty_ersattare())
            }

            purrr::map_dfr(
              ersattare,
              \(ers) tibble::tibble(
                valtillfalle = as_chr_na(raw$valtillfalle),
                valklass = as_chr_na(raw$valklass),
                rakningstillfalle = .normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
                valtyp = valtyp,
                valdatum = as_chr_na(raw$valdatum),
                valdatum_fg = as_chr_na(raw$tidigareValdatum),
                test = as_lgl_na(raw$test),
                geografiniva = geografiniva,
                valomradeskod = as_chr_na(valomrade$kod),
                valomradesnamn = as_chr_na(valomrade$namn),
                valkretskod = valkretskod,
                valkretsnamn = valkretsnamn,
                partibeteckning = as_chr_na(parti$partibeteckning),
                partiforkortning = as_chr_na(parti$partiforkortning),
                partikod = as_chr_na(parti$partikod),
                partifarg = as_chr_na(parti$partiFarg),
                ledamot_kandidatnummer =
                  as_chr_na(ledamot$kandidatnummer),
                ledamot_namn = as_chr_na(ledamot$namn),
                ersattargrupp = as_chr_na(ledamot$ersattargrupp),
                ersattare_kandidatnummer =
                  as_chr_na(ers$kandidatnummer),
                ersattare_namn = as_chr_na(ers$namn),
                ersattarordning = as_int_na(ers$ersattarordning),
                valgrund_id = as_chr_na(ers$valgrundId),
                valgrund_text = as_chr_na(ers$valgrundText)
              )
            )
          }
        )
      }
    )

    list(
      valda = valda_rows,
      ersattare = ersattare_rows
    )
  }

  valkretsar <- valomrade$valkretsLista
  kallval <- .valda_kallval_2026(raw)

  if (identical(kallval$niva, "valkrets")) {

    parsed <- purrr::map(
      valkretsar,
      \(vk) parse_niva(
        valda = vk$valda,
        geografiniva = geografiniva_valkrets,
        valkretskod = as_chr_na(vk$kod),
        valkretsnamn = as_chr_na(vk$namnValkrets)
      )
    )

    valda_valkrets <- parsed |>
      purrr::map("valda") |>
      purrr::list_rbind()

    ersattare_valkrets <- parsed |>
      purrr::map("ersattare") |>
      purrr::list_rbind()

    return(list(valda = valda_valkrets, ersattare = ersattare_valkrets))
  }

  # Annars använder vi valområdesnivån. Om även den saknar valda
  # returneras schema-stabila tomma tabeller.
  parse_niva(
    valda = valomrade$valda,
    geografiniva = geografiniva_valomrade
  )
}
