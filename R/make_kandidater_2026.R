.normalisera_kandidatnamn <- function(x) {

  x <- stringr::str_squish(x)

  dplyr::if_else(
    !is.na(x) &
      stringr::str_detect(x, "^[^,]+,\\s*[^,]+$"),
    stringr::str_replace(
      x,
      "^([^,]+),\\s*(.+)$",
      "\\2 \\1"
    ),
    x
  )
}


make_kandidater_2026 <- function(kandidaturer) {

  required <- c(
    "valtillfalle",
    "valtyp",
    "valomradeskod",
    "valomradesnamn",
    "valkretskod",
    "valkretsnamn",
    "partibeteckning",
    "partiforkortning",
    "partikod",
    "listnummer",
    "kandidatnummer",
    "namn",
    "alder_pa_valdagen",
    "kon",
    "folkbokforingskommun",
    "giltig"
  )

  missing <- setdiff(required, names(kandidaturer))

  if (length(missing) > 0) {
    stop(
      "F\u00f6ljande kolumner saknas i kandidaturdata: ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  first_non_na <- function(x) {
    x[which(!is.na(x))[1]]
  }

  unique_or_na <- function(x) {
    x <- unique(x[!is.na(x)])

    if (length(x) == 1) {
      x[[1]]
    } else {
      NA_character_
    }
  }

  giltiga <- kandidaturer |>
    dplyr::filter(giltig %in% TRUE) |>
    dplyr::mutate(
      .valkrets_id = dplyr::if_else(
        is.na(valkretskod) | is.na(valomradeskod) |
          !nzchar(valkretskod) | !nzchar(valomradeskod),
        NA_character_,
        paste(valomradeskod, valkretskod, sep = "/")
      ),
      .lista_id = dplyr::if_else(
        is.na(listnummer),
        NA_character_,
        paste(valomradeskod, listnummer, sep = "/")
      )
    )

  if (nrow(giltiga) == 0) {
    stop(
      "Det finns inga giltiga kandidaturer i data.",
      call. = FALSE
    )
  }

  namn_underlag <- giltiga |>
    dplyr::mutate(
      namn_normaliserat = .normalisera_kandidatnamn(namn)
    ) |>
    dplyr::filter(!is.na(namn_normaliserat)) |>
    dplyr::distinct(
      kandidatnummer,
      valtyp,
      partikod,
      valomradeskod,
      listnummer,
      namn_normaliserat
    )

  namn_val <- namn_underlag |>
    dplyr::count(
      kandidatnummer,
      valtyp,
      partikod,
      namn_normaliserat,
      name = "n_namn"
    ) |>
    dplyr::arrange(
      kandidatnummer,
      valtyp,
      partikod,
      dplyr::desc(n_namn),
      namn_normaliserat
    ) |>
    dplyr::summarise(
      namn = dplyr::first(namn_normaliserat),
      antal_namn = dplyr::n(),
      namn_varierar = dplyr::n() > 1,
      .by = c(kandidatnummer, valtyp, partikod)
    )

  kandidat_overblick <- giltiga |>
    dplyr::summarise(
      antal_valtyper = dplyr::n_distinct(valtyp),
      .by = kandidatnummer
    ) |>
    dplyr::mutate(
      flera_valtyper = antal_valtyper > 1
    )

  parti_overblick <- giltiga |>
    dplyr::summarise(
      antal_partier = dplyr::n_distinct(partikod),
      .by = c(kandidatnummer, valtyp)
    ) |>
    dplyr::mutate(
      flera_partier = antal_partier > 1
    )

  kandidater <- giltiga |>
    dplyr::summarise(
      valtillfalle = first_non_na(valtillfalle),
      partibeteckning = first_non_na(partibeteckning),
      partiforkortning = first_non_na(partiforkortning),
      kon = first_non_na(kon),
      alder_pa_valdagen = first_non_na(alder_pa_valdagen),
      folkbokforingskommun = first_non_na(folkbokforingskommun),
      antal_valomraden = dplyr::n_distinct(
        valomradeskod,
        na.rm = TRUE
      ),
      antal_valkretsar = if (anyNA(.valkrets_id)) NA_integer_ else
        as.integer(dplyr::n_distinct(.valkrets_id)),
      antal_listor = dplyr::n_distinct(
        .lista_id,
        na.rm = TRUE
      ),
      valomradeskod = unique_or_na(valomradeskod),
      valomradesnamn = unique_or_na(valomradesnamn),
      valkretskod = unique_or_na(valkretskod),
      valkretsnamn = unique_or_na(valkretsnamn),
      .by = c(kandidatnummer, valtyp, partikod)
    ) |>
    dplyr::mutate(
      valkretskod = dplyr::if_else(
        antal_valkretsar > 1L, NA_character_, valkretskod),
      valkretsnamn = dplyr::if_else(
        antal_valkretsar > 1L, NA_character_, valkretsnamn),
      flera_valomraden = antal_valomraden > 1,
      flera_valkretsar = antal_valkretsar > 1,
      flera_listor = antal_listor > 1
    ) |>
    dplyr::left_join(
      namn_val,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::left_join(
      parti_overblick,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp
      )
    ) |>
    dplyr::left_join(
      kandidat_overblick,
      by = dplyr::join_by(kandidatnummer)
    ) |>
    dplyr::select(
      valtillfalle,
      kandidatnummer,
      valtyp,
      partikod,
      partiforkortning,
      partibeteckning,
      namn,
      kon,
      alder_pa_valdagen,
      folkbokforingskommun,
      valomradeskod,
      valomradesnamn,
      valkretskod,
      valkretsnamn,
      antal_valkretsar,
      namn_varierar,
      antal_namn,
      antal_valomraden,
      flera_valomraden,
      flera_valkretsar,
      antal_listor,
      flera_listor,
      antal_partier,
      flera_partier,
      antal_valtyper,
      flera_valtyper
    )

  .kort_kommunnamn_2026(kandidater)
}
