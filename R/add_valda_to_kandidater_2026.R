add_valda_to_kandidater_2026 <- function(
    kandidater,
    valda
) {

  required_kandidater <- c(
    "kandidatnummer",
    "valtyp",
    "partikod"
  )

  required_valda <- c(
    "kandidatnummer",
    "valtyp",
    "partikod",
    "valomradeskod",
    "valomradesnamn",
    "valkretskod",
    "valkretsnamn",
    "invalsordning",
    "valgrund_id",
    "valgrund_text",
    "ersattargrupp"
  )

  missing_kandidater <- setdiff(
    required_kandidater,
    names(kandidater)
  )

  missing_valda <- setdiff(
    required_valda,
    names(valda)
  )

  if (length(missing_kandidater) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i kandidater: ",
      paste(missing_kandidater, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(missing_valda) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i valda: ",
      paste(missing_valda, collapse = ", "),
      call. = FALSE
    )
  }

  # Om filen ännu inte innehåller uppgifter om valda är utfallet okänt,
  # inte FALSE. Detta inträffar bland annat innan resultatet fastställts.
  if (nrow(valda) == 0) {
    return(
      kandidater |>
        dplyr::mutate(
          invald = NA,
          invald_valomradeskod = NA_character_,
          invald_valomradesnamn = NA_character_,
          invald_valkretskod = NA_character_,
          invald_valkretsnamn = NA_character_,
          invalsordning = NA_integer_,
          valgrund_id = NA_character_,
          valgrund_text = NA_character_,
          ersattargrupp = NA_character_
        )
    )
  }

  dubbla_inval <- valda |>
    dplyr::count(
      kandidatnummer,
      valtyp,
      partikod,
      name = "n"
    ) |>
    dplyr::filter(n > 1)

  if (nrow(dubbla_inval) > 0) {
    stop(
      "Minst en kandidat \u00e4r vald mer \u00e4n en g\u00e5ng inom samma valtyp och parti. ",
      "Det kr\u00e4ver en mer detaljerad kandidatmodell.",
      call. = FALSE
    )
  }

  valda_join <- valda |>
    dplyr::transmute(
      kandidatnummer,
      valtyp,
      partikod,
      invald = TRUE,
      invald_valomradeskod = valomradeskod,
      invald_valomradesnamn = valomradesnamn,
      invald_valkretskod = valkretskod,
      invald_valkretsnamn = valkretsnamn,
      invalsordning,
      valgrund_id,
      valgrund_text,
      ersattargrupp
    )

  kandidater |>
    dplyr::left_join(
      valda_join,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::mutate(
      invald = dplyr::coalesce(invald, FALSE)
    )
}
