add_personroster_to_kandidater_2026 <- function(
    kandidater,
    personroster_summerade,
    personval
) {

  required_kandidater <- c(
    "kandidatnummer",
    "valtyp",
    "partikod"
  )

  required_personroster <- c(
    "kandidatnummer",
    "valtyp",
    "partikod",
    "antal_personroster"
  )

  required_personval <- c(
    "kandidatnummer",
    "valtyp",
    "partikod"
  )

  missing_kandidater <- setdiff(
    required_kandidater,
    names(kandidater)
  )

  missing_personroster <- setdiff(
    required_personroster,
    names(personroster_summerade)
  )

  missing_personval <- setdiff(
    required_personval,
    names(personval)
  )

  if (length(missing_kandidater) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i kandidater: ",
      paste(missing_kandidater, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(missing_personroster) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i personroster_summerade: ",
      paste(missing_personroster, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(missing_personval) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i personval: ",
      paste(missing_personval, collapse = ", "),
      call. = FALSE
    )
  }

  personroster_totalt <- personroster_summerade |>
    dplyr::summarise(
      antal_personroster_totalt = sum(
        antal_personroster,
        na.rm = TRUE
      ),
      .by = c(
        kandidatnummer,
        valtyp,
        partikod
      )
    )

  out <- kandidater |>
    dplyr::left_join(
      personroster_totalt,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::mutate(
      antal_personroster_totalt = dplyr::coalesce(
        antal_personroster_totalt,
        0L
      )
    )

  personval_available <- attr(
    personval,
    "personval_available",
    exact = TRUE
  )

  # Om mandatfilen ännu inte innehåller information om vilka som
  # kvalificerat sig för personval är utfallet okänt, inte FALSE.
  if (identical(personval_available, FALSE)) {
    return(
      out |>
        dplyr::mutate(
          kvalificerad_personval = NA,
          antal_personvalsomraden = NA_integer_
        )
    )
  }

  personval_summary <- personval |>
    dplyr::summarise(
      kvalificerad_personval = TRUE,
      antal_personvalsomraden = dplyr::n(),
      .by = c(
        kandidatnummer,
        valtyp,
        partikod
      )
    )

  out |>
    dplyr::left_join(
      personval_summary,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::mutate(
      kvalificerad_personval = dplyr::coalesce(
        kvalificerad_personval,
        FALSE
      ),
      antal_personvalsomraden = dplyr::coalesce(
        antal_personvalsomraden,
        0L
      )
    )
}
