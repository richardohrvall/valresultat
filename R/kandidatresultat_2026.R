.resultatsamling_2026 <- function() {
  getOption(
    "valresultat.resultatsamling_2026",
    "genrep2026"
  )
}


.read_resultatindex_2026 <- function(
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE
) {

  source <- match.arg(source)
  samling <- .resultatsamling_2026()

  index_file <- .resolve_val_file(
    path = "index.md5", ar = 2026, samling = samling, source = source,
    data_dir = data_dir, update = update, archive = archive
  )

  readLines(
    index_file,
    warn = FALSE,
    encoding = "UTF-8"
  ) |>
    parse_index_2026()
}


.resultat_paths_2026 <- function(index, val) {

  purrr::map_dfr(
    val,
    \(valtyp) {

      pattern <- dplyr::recode_values(
        valtyp,
        "RD" ~ "^s/rd/.*_00_RD\\.zip$",
        "RF" ~ "^s/rf/.*_[0-9]{2}_RF\\.zip$",
        "KF" ~ "^s/kf/.*_[0-9]{4}_KF\\.zip$"
      )

      index |>
        dplyr::filter(stringr::str_detect(path, pattern)) |>
        dplyr::transmute(
          valtyp = valtyp,
          path
        )
    }
  )
}


.resultat_file_2026 <- function(
    path,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE
) {

  source <- match.arg(source)
  samling <- .resultatsamling_2026()

  .resolve_val_file(
    path = path, ar = 2026, samling = samling, source = source,
    data_dir = data_dir, update = update, archive = archive
  )
}


.valda_available_2026 <- function(raw) {

  valomrade <- raw$valomrade

  valomrade_available <-
    "valda" %in% names(valomrade) &&
    !is.null(valomrade$valda)

  valkretsar <- valomrade$valkretsLista

  valkrets_available <- FALSE

  if (!is.null(valkretsar) && length(valkretsar) > 0) {
    valkrets_available <- purrr::some(
      valkretsar,
      \(vk) {
        "valda" %in% names(vk) &&
          !is.null(vk$valda)
      }
    )
  }

  valomrade_available || valkrets_available
}


.parse_kandidatresultat_fil_2026 <- function(
    path,
    valtyp,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE
) {

  source <- match.arg(source)

  file <- .resultat_file_2026(
    path = path,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  rost_raw <- read_raw_json_zip_2026(
    file,
    type = "rostfordelning"
  )

  mandat_raw <- read_raw_json_zip_2026(
    file,
    type = "mandatfordelning"
  )

  persondata <- parse_personroster_2026(rost_raw)
  personval <- parse_personval_2026(mandat_raw)
  valda_data <- parse_valda_ersattare_2026(mandat_raw)

  valomradeskod <- as_chr_na(mandat_raw$valomrade$kod)
  valomradesnamn <- as_chr_na(mandat_raw$valomrade$namn)

  personroster <- persondata$personroster_summerade |>
    dplyr::summarise(
      antal_personroster = sum(
        antal_personroster,
        na.rm = TRUE
      ),
      .by = c(
        kandidatnummer,
        valtyp,
        partikod
      )
    )

  list(
    status = tibble::tibble(
      valtyp = valtyp,
      valomradeskod = valomradeskod,
      valomradesnamn = valomradesnamn,
      valda_available = .valda_available_2026(mandat_raw),
      personval_available =
        isTRUE(attr(personval, "personval_available"))
    ),
    personroster = personroster,
    personval = personval,
    valda = valda_data$valda
  )
}


.add_kandidatresultat_2026 <- function(
    kandidater,
    kandidaturer,
    val,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {

  source <- match.arg(source)

  index <- .read_resultatindex_2026(
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  paths <- .resultat_paths_2026(
    index = index,
    val = val
  )

  if (nrow(paths) == 0) {
    stop(
      "Hittade inga slutliga resultatfiler f\u00f6r vald valtyp.",
      call. = FALSE
    )
  }

  parsed <- purrr::map2(
    paths$path,
    paths$valtyp,
    \(path, valtyp) {
      .parse_kandidatresultat_fil_2026(
        path = path,
        valtyp = valtyp,
        source = source,
        data_dir = data_dir,
        update = update,
        archive = archive
      )
    },
    .progress = progress
  )

  status <- parsed |>
    purrr::map("status") |>
    purrr::list_rbind()

  personroster <- parsed |>
    purrr::map("personroster") |>
    purrr::list_rbind() |>
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

  personval <- parsed |>
    purrr::map("personval") |>
    purrr::list_rbind()

  valda <- parsed |>
    purrr::map("valda") |>
    purrr::list_rbind()

  kandidatomraden <- kandidaturer |>
    dplyr::filter(
      giltig %in% TRUE,
      valtyp %in% val
    ) |>
    dplyr::distinct(
      kandidatnummer,
      valtyp,
      partikod,
      valomradeskod
    ) |>
    dplyr::left_join(
      status,
      by = dplyr::join_by(
        valtyp,
        valomradeskod
      )
    ) |>
    dplyr::mutate(
      valda_available = dplyr::coalesce(
        valda_available,
        FALSE
      ),
      personval_available = dplyr::coalesce(
        personval_available,
        FALSE
      )
    ) |>
    dplyr::summarise(
      valda_available = all(valda_available),
      personval_available = all(personval_available),
      .by = c(
        kandidatnummer,
        valtyp,
        partikod
      )
    )

  if (nrow(personval) > 0) {
    personval_summary <- personval |>
      dplyr::mutate(
        .personvalsomrade = paste(
          valomradeskod,
          valkretskod,
          sep = "/"
        )
      ) |>
      dplyr::summarise(
        kvalificerad_personval_found = TRUE,
        antal_personvalsomraden =
          dplyr::n_distinct(.personvalsomrade),
        .by = c(
          kandidatnummer,
          valtyp,
          partikod
        )
      )
  } else {
    personval_summary <- tibble::tibble(
      kandidatnummer = character(),
      valtyp = character(),
      partikod = character(),
      kvalificerad_personval_found = logical(),
      antal_personvalsomraden = integer()
    )
  }

  if (nrow(valda) > 0) {

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

    valda_summary <- valda |>
      dplyr::transmute(
        kandidatnummer,
        valtyp,
        partikod,
        invald_found = TRUE,
        invald_valomradeskod = valomradeskod,
        invald_valomradesnamn = valomradesnamn,
        invald_valkretskod = valkretskod,
        invald_valkretsnamn = valkretsnamn,
        invalsordning,
        valgrund_id,
        valgrund_text,
        ersattargrupp
      )
  } else {
    valda_summary <- tibble::tibble(
      kandidatnummer = character(),
      valtyp = character(),
      partikod = character(),
      invald_found = logical(),
      invald_valomradeskod = character(),
      invald_valomradesnamn = character(),
      invald_valkretskod = character(),
      invald_valkretsnamn = character(),
      invalsordning = integer(),
      valgrund_id = character(),
      valgrund_text = character(),
      ersattargrupp = character()
    )
  }

  kandidater |>
    dplyr::left_join(
      kandidatomraden,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::left_join(
      personroster,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::left_join(
      personval_summary,
      by = dplyr::join_by(
        kandidatnummer,
        valtyp,
        partikod
      )
    ) |>
    dplyr::left_join(
      valda_summary,
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
      ),
      kvalificerad_personval = dplyr::case_when(
        kvalificerad_personval_found %in% TRUE ~ TRUE,
        personval_available %in% TRUE ~ FALSE,
        .default = NA
      ),
      antal_personvalsomraden = dplyr::case_when(
        kvalificerad_personval_found %in% TRUE ~
          antal_personvalsomraden,
        personval_available %in% TRUE ~ 0L,
        .default = NA_integer_
      ),
      invald = dplyr::case_when(
        invald_found %in% TRUE ~ TRUE,
        valda_available %in% TRUE ~ FALSE,
        .default = NA
      )
    ) |>
    dplyr::select(
      -valda_available,
      -personval_available,
      -kvalificerad_personval_found,
      -invald_found
    )
}
