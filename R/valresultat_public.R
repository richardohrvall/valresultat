.valresultat_lannamn_2026 <- function(lankod) {
  # Fast 2026-indelning enligt Valmyndighetens \u00f6verordnade KF-summering.
  namn <- c(
    "01" = "Stockholms l\u00e4n", "03" = "Uppsala l\u00e4n",
    "04" = "S\u00f6dermanlands l\u00e4n", "05" = "\u00d6sterg\u00f6tlands l\u00e4n",
    "06" = "J\u00f6nk\u00f6pings l\u00e4n", "07" = "Kronobergs l\u00e4n",
    "08" = "Kalmar l\u00e4n", "09" = "Gotlands l\u00e4n",
    "10" = "Blekinge l\u00e4n", "12" = "Sk\u00e5ne l\u00e4n",
    "13" = "Hallands l\u00e4n", "14" = "V\u00e4stra G\u00f6talands l\u00e4n",
    "17" = "V\u00e4rmlands l\u00e4n", "18" = "\u00d6rebro l\u00e4n",
    "19" = "V\u00e4stmanlands l\u00e4n", "20" = "Dalarnas l\u00e4n",
    "21" = "G\u00e4vleborgs l\u00e4n", "22" = "V\u00e4sternorrlands l\u00e4n",
    "23" = "J\u00e4mtlands l\u00e4n", "24" = "V\u00e4sterbottens l\u00e4n",
    "25" = "Norrbottens l\u00e4n"
  )
  unname(namn[lankod])
}

.valresultat_public_geo_2026 <- function(niva) {
  switch(niva,
    valdistrikt = c(
      "valdistriktskod", "valdistriktsnamn", "valdistriktstyp",
      "kommunkod", "kommunnamn", "kommunnamn_officiellt", "lankod", "lannamn",
      "valomradeskod", "valomradesnamn", "valkretskod", "valkretsnamn",
      "kommunvalkretskod", "kommunvalkretsnamn"
    ),
    kommun = c(
      "lankod", "lannamn", "kommunkod", "kommunnamn",
      "kommunnamn_officiellt"
    ),
    kommunvalkrets = c(
      "lankod", "lannamn", "kommunkod", "kommunnamn",
      "kommunnamn_officiellt",
      "kommunvalkretskod", "kommunvalkretsnamn"
    ),
    lan = c("lankod", "lannamn"),
    region = c("valomradeskod", "valomradesnamn"),
    regionvalkrets = c(
      "valomradeskod", "valomradesnamn", "valkretskod", "valkretsnamn"
    ),
    riksdagsvalkrets = c(
      "valomradeskod", "valomradesnamn", "valkretskod", "valkretsnamn"
    ),
    riket = character()
  )
}

.valresultat_public_columns_2026 <- function(niva) {
  metadata <- c(
    "valtillfalle", "valklass", "valtyp", "rakningstillfalle",
    "valdatum", "valdatum_fg", "test", "geografiniva"
  )
  filstatus <- c(
    "senaste_uppdateringstid", "antal_uppdateringar",
    "antal_valdistrikt_raknade", "antal_valdistrikt_som_ska_raknas"
  )
  omradesstatus <- switch(niva,
    valdistrikt = c("raknat", "rapporteringstid"),
    kommun = c(
      "rapporteringstid", "senaste_uppdateringstid_omrade",
      "antal_valdistrikt_raknade_omrade",
      "antal_valdistrikt_som_ska_raknas_omrade",
      "antal_rostberattigade_raknade"
    ),
    kommunvalkrets = c(
      "rapporteringstid", "senaste_uppdateringstid_omrade",
      "antal_valdistrikt_raknade_omrade",
      "antal_valdistrikt_som_ska_raknas_omrade",
      "antal_rostberattigade_raknade"
    ),
    lan = c(
      "rapporteringstid", "antal_valdistrikt_raknade_omrade",
      "antal_valdistrikt_som_ska_raknas_omrade",
      "antal_rostberattigade_raknade"
    ),
    region = c("rapporteringstid", "antal_rostberattigade_raknade"),
    regionvalkrets = c(
      "rapporteringstid", "antal_valdistrikt_raknade_omrade",
      "antal_valdistrikt_som_ska_raknas_omrade",
      "antal_rostberattigade_raknade"
    ),
    riksdagsvalkrets = c(
      "rapporteringstid", "antal_valdistrikt_raknade_omrade",
      "antal_valdistrikt_som_ska_raknas_omrade",
      "antal_rostberattigade_raknade"
    ),
    riket = c("rapporteringstid", "antal_rostberattigade_raknade")
  )
  parti <- c(
    "partibeteckning", "partiforkortning", "partikod", "fargkod",
    "ordningsnummer", "ovriga_partier", "over_sparr"
  )
  sparr <- switch(niva,
    riket = c("valomradessparr", "valkretssparr"),
    riksdagsvalkrets = c("valomradessparr", "valkretssparr"),
    region = "valomradessparr",
    regionvalkrets = "valomradessparr",
    kommun = "valomradessparr",
    kommunvalkrets = "valomradessparr",
    character()
  )
  resultat <- names(.valresultat_schema())[41:83]
  c(
    metadata, .valresultat_public_geo_2026(niva),
    omradesstatus, filstatus, parti, sparr, resultat
  )
}

.publika_andelar_0_1_2026 <- function(data, columns) {
  for (column in intersect(columns, names(data))) {
    data[[column]] <- data[[column]] / 100
  }
  data
}

.exakt_andel_2026 <- function(taljare, namnare, tillaten = TRUE) {
  tillaten <- rep_len(tillaten, length(taljare))
  out <- rep(NA_real_, length(taljare))
  ok <- tillaten %in% TRUE & !is.na(taljare) & !is.na(namnare) & namnare > 0
  out[ok] <- as.double(taljare[ok]) / as.double(namnare[ok])
  out
}

.andelsskillnad_2026 <- function(aktuell, foregaende) {
  out <- rep(NA_real_, length(aktuell))
  ok <- !is.na(aktuell) & !is.na(foregaende)
  out[ok] <- aktuell[ok] - foregaende[ok]
  out
}

.jamforelse_tillaten_2026 <- function(status) {
  status <- tolower(trimws(status))
  nekad <- !is.na(status) & grepl("^(ej|kan ej)\\s", status)
  !nekad
}

.valresultat_public_andelar_2026 <- function(data) {
  jamforbar <- .jamforelse_tillaten_2026(data$status_jamforelse)

  data$andel_roster <- .exakt_andel_2026(data$antal_roster, data$giltiga_roster)
  data$andel_roster_fg <- .exakt_andel_2026(
    data$antal_roster_fg, data$giltiga_roster_fg, jamforbar
  )
  data$diff_andel_roster <- .andelsskillnad_2026(
    data$andel_roster, data$andel_roster_fg
  )

  is_distrikt <- data$geografiniva == "valdistrikt"
  raknat <- rep(TRUE, nrow(data))
  if ("raknat" %in% names(data)) raknat[is_distrikt] <- data$raknat[is_distrikt] %in% TRUE
  uppsamling <- is_distrikt & !is.na(data$valdistriktstyp) &
    tolower(data$valdistriktstyp) == "uppsamlingsdistrikt"
  aktuell_tillaten <- !is_distrikt | (raknat & !uppsamling)
  foregaende_tillaten <- jamforbar
  aktuell_namnare <- data$antal_rostberattigade_raknade
  aktuell_namnare[is_distrikt] <- data$antal_rostberattigade[is_distrikt]
  data$valdel <- .exakt_andel_2026(
    data$totalt_antal_roster, aktuell_namnare, aktuell_tillaten
  )
  data$valdel_fg <- .exakt_andel_2026(
    data$totalt_antal_roster_fg, data$antal_rostberattigade_fg,
    foregaende_tillaten
  )
  data$diff_valdel <- .andelsskillnad_2026(data$valdel, data$valdel_fg)

  andelspar <- list(
    c("andel_ogiltiga", "ogiltiga_roster", "andel_ogiltiga_fg",
      "ogiltiga_roster_fg", "diff_andel_ogiltiga"),
    c("andel_ej_anmalt_deltagande", "roster_ej_anmalt_deltagande",
      "andel_ej_anmalt_deltagande_fg", "roster_ej_anmalt_deltagande_fg",
      "diff_andel_ej_anmalt_deltagande"),
    c("andel_blanka", "blanka_roster", "andel_blanka_fg",
      "blanka_roster_fg", "diff_andel_blanka"),
    c("andel_ovriga_ogiltiga", "ovriga_ogiltiga", "andel_ovriga_ogiltiga_fg",
      "ovriga_ogiltiga_fg", "diff_andel_ovriga_ogiltiga")
  )
  for (par in andelspar) {
    data[[par[1]]] <- .exakt_andel_2026(data[[par[2]]], data$totalt_antal_roster)
    data[[par[3]]] <- .exakt_andel_2026(
      data[[par[4]]], data$totalt_antal_roster_fg, jamforbar
    )
    data[[par[5]]] <- .andelsskillnad_2026(data[[par[1]]], data[[par[3]]])
  }

  data <- .publika_andelar_0_1_2026(
    data, c("valomradessparr_procent", "valkretssparr_procent")
  )
  names(data)[names(data) == "valomradessparr_procent"] <- "valomradessparr"
  names(data)[names(data) == "valkretssparr_procent"] <- "valkretssparr"
  data
}

.valresultat_id_2026 <- function(data, columns) {
  if (!length(columns)) return(rep("riket", nrow(data)))
  x <- lapply(data[columns], function(value) {
    value[is.na(value)] <- ""
    value
  })
  do.call(paste, c(unname(x), sep = "\r"))
}

.valresultat_partiuniversum_2026 <- function(obj) {
  if (!.rostfordelning_tillganglig_2026(obj, "mandatfilens omr\u00e5de")) {
    stop("Partiuniversum saknas i mandatfilens r\u00f6stf\u00f6rdelning.", call. = FALSE)
  }
  har_ovriga <- .valresultat_votes(obj)
  partier <- obj$rostfordelning$rosterPaverkaMandat$partiRoster
  if (is.null(partier)) partier <- list()
  out <- if (length(partier)) {
    tibble::tibble(
      partibeteckning = purrr::map_chr(partier, \(x) as_chr_na(x$partibeteckning)),
      partiforkortning = purrr::map_chr(partier, \(x) as_chr_na(x$partiforkortning)),
      partikod = purrr::map_chr(partier, \(x) as_chr_na(x$partikod)),
      fargkod = purrr::map_chr(partier, \(x) as_chr_na(x$fargkod)),
      ordningsnummer = purrr::map_int(partier, \(x) as_int_na(x$ordningsnummer)),
      ovriga_partier = FALSE
    )
  } else {
    tibble::tibble(
      partibeteckning = character(), partiforkortning = character(),
      partikod = character(), fargkod = character(), ordningsnummer = integer(),
      ovriga_partier = logical()
    )
  }
  if (har_ovriga) {
    out <- dplyr::bind_rows(out, tibble::tibble(
      partibeteckning = "\u00d6vriga partier", partiforkortning = NA_character_,
      partikod = NA_character_, fargkod = NA_character_,
      ordningsnummer = NA_integer_, ovriga_partier = TRUE
    ))
  }
  if (!nrow(out)) {
    stop("Partiuniversum saknas i mandatfilens r\u00f6stf\u00f6rdelning.", call. = FALSE)
  }
  if (anyDuplicated(out[c("partikod", "ovriga_partier")])) {
    stop("Duplicerat parti i mandatfilens partiuniversum.", call. = FALSE)
  }
  out
}

.valresultat_distrikt_meta_2026 <- function(raw, context) {
  mandat <- .normalisera_rakningsmetadata_2026(context$mandat)
  summering <- .normalisera_rakningsmetadata_2026(context$summering)
  .valresultat_object(mandat, "mandatfil")
  .valresultat_object(mandat$valomrade, "mandatfilens valomrade")
  if (!identical(mandat$valtyp, raw$valtyp) ||
      !identical(mandat$rakningstillfalle, raw$rakningstillfalle)) {
    stop("Mandatfilens metadata st\u00e4mmer inte med distriktsfilen.", call. = FALSE)
  }
  valomrade <- mandat$valomrade
  kretsar <- valomrade$valkretsLista
  if (is.null(kretsar)) kretsar <- list()
  .valresultat_array(kretsar, "mandatfilens valkretsLista", tom = TRUE)
  kretskoder <- vapply(kretsar, function(x) as_chr_na(x$kod), character(1))
  if (anyNA(kretskoder) || any(!nzchar(kretskoder)) || anyDuplicated(kretskoder)) {
    stop("Ogiltiga eller duplicerade valkretskoder i mandatfilen.", call. = FALSE)
  }

  kommunnamn <- character()
  if (!is.null(summering)) {
    .valresultat_object(summering, "summeringsfil")
    if (!identical(summering$valtyp, raw$valtyp) ||
        !identical(summering$rakningstillfalle, raw$rakningstillfalle)) {
      stop("Summeringsfilens metadata st\u00e4mmer inte med distriktsfilen.", call. = FALSE)
    }
    kommuner <- .valresultat_array(summering$kommuner, "summeringsfilens kommuner")
    kommunkoder <- vapply(kommuner, function(x) as_chr_na(x$kommunkod), character(1))
    kommunnamn <- vapply(kommuner, function(x) as_chr_na(x$namn), character(1))
    if (anyNA(kommunkoder) || any(!nzchar(kommunkoder)) || anyDuplicated(kommunkoder)) {
      stop("Ogiltiga eller duplicerade kommunkoder i summeringsfilen.", call. = FALSE)
    }
    names(kommunnamn) <- kommunkoder
  }

  distrikt <- .valresultat_array(raw$valdistrikt, "valdistrikt")
  for (obj in distrikt) {
    .valresultat_object(obj, "valdistrikt")
    .valresultat_values(obj)
  }
  raknat <- vapply(
    distrikt, function(x) .rostfordelning_tillganglig_2026(x, "valdistrikt"),
    logical(1)
  )
  kretskod <- purrr::map_chr(distrikt, \(x) as_chr_na(x$kretskod))
  kretsindex <- match(kretskod, kretskoder)
  if (length(kretsar) && anyNA(kretsindex)) {
    stop("Valdistriktets kretskod saknas i mandatfilen.", call. = FALSE)
  }
  universum_area <- .valresultat_partiuniversum_2026(valomrade)
  universum_krets <- lapply(kretsar, .valresultat_partiuniversum_2026)
  universum <- if (length(kretsar)) {
    universum_krets[kretsindex]
  } else {
    rep(list(universum_area), length(distrikt))
  }
  for (i in which(raknat)) {
      faktiska <- distrikt[[i]]$rostfordelning$rosterPaverkaMandat$partiRoster
      if (is.null(faktiska)) faktiska <- list()
      faktiska_koder <- vapply(faktiska, function(x) as_chr_na(x$partikod), character(1))
      giltiga_koder <- universum[[i]]$partikod[!universum[[i]]$ovriga_partier]
      if (any(!faktiska_koder %in% giltiga_koder)) {
        stop("Distriktsfilens parti saknas i mandatfilens partiuniversum.", call. = FALSE)
      }
  }
  kommunkod <- purrr::map_chr(distrikt, \(x) as_chr_na(x$kommunkod))
  namn_kommun <- unname(kommunnamn[kommunkod])
  if (identical(raw$valtyp, "KF")) {
    samma <- kommunkod == as_chr_na(valomrade$kod)
    namn_kommun[samma] <- as_chr_na(valomrade$namn)
  }
  tibble::tibble(
      valdistriktsnamn = purrr::map_chr(distrikt, \(x) as_chr_na(x$namn)),
      valdistriktstyp = purrr::map_chr(distrikt, \(x) as_chr_na(x$valdistriktstyp)),
      valdistriktskod = purrr::map_chr(distrikt, \(x) as_chr_na(x$valdistriktskod)),
      kommunkod = kommunkod, kommunnamn = namn_kommun,
      lankod = purrr::map_chr(distrikt, \(x) as_chr_na(x$lankod)),
      lannamn = .valresultat_lannamn_2026(
        purrr::map_chr(distrikt, \(x) as_chr_na(x$lankod))
      ),
      valomradeskod = purrr::map_chr(distrikt, \(x) as_chr_na(x$valomradeskod)),
      valomradesnamn = as_chr_na(valomrade$namn),
      kretskod = kretskod,
      valkretskod = if (length(kretsar)) kretskoder[kretsindex] else NA_character_,
      valkretsnamn = if (length(kretsar)) {
        vapply(kretsar[kretsindex], \(x) as_chr_na(x$namnValkrets), character(1))
      } else {
        NA_character_
      },
      kommunvalkretskod = purrr::map_chr(distrikt, \(x) as_chr_na(x$kommunvalkretsKod)),
      kommunvalkretsnamn = purrr::map_chr(distrikt, \(x) as_chr_na(x$kommunvalkretsNamn)),
      raknat = raknat,
      rapporteringstid = dplyr::na_if(
        purrr::map_chr(distrikt, \(x) as_chr_na(x$rapporteringsTid)), ""
      ),
      antal_rostberattigade = purrr::map_int(distrikt, \(x) as_int_na(x$antalRostberattigade)),
      totalt_antal_roster_fg = purrr::map_int(distrikt, \(x) as_int_na(x$totaltAntalRosterForegaendeVal)),
      antal_rostberattigade_fg = purrr::map_int(distrikt, \(x) as_int_na(x$antalRostberattigadeForegaendeVal)),
      valdel_fg = purrr::map_dbl(distrikt, \(x) as_dbl_na(x$valdeltagandeForegaendeVal)),
      diff_antal_rostberattigade = purrr::map_int(distrikt, \(x) as_int_na(x$forandringAntalRostberattigade)),
      status_jamforelse = purrr::map_chr(distrikt, \(x) as_chr_na(x$statusJamforelse)),
      universum = universum
    )
}

.valresultat_orapporterade_2026 <- function(raw, meta) {
  orapporterade <- meta[!meta$raknat, , drop = FALSE]
  if (!nrow(orapporterade)) return(.valresultat_schema())
  schema <- .valresultat_schema()
  antal <- vapply(orapporterade$universum, nrow, integer(1))
  distriktsindex <- rep(seq_len(nrow(orapporterade)), antal)
  parti <- purrr::list_rbind(orapporterade$universum)
  out <- schema[rep(NA_integer_, nrow(parti)), , drop = FALSE]
  out$valtillfalle <- as_chr_na(raw$valtillfalle)
  out$valklass <- as_chr_na(raw$valklass)
  out$rakningstillfalle <- .normalisera_rakningstillfalle_2026(raw$rakningstillfalle)
  out$valtyp <- as_chr_na(raw$valtyp)
  out$valdatum <- as_chr_na(raw$valdatum)
  out$valdatum_fg <- as_chr_na(raw$tidigareValdatum)
  out$test <- as_lgl_na(raw$test)
  out$senaste_uppdateringstid <- as_chr_na(raw$senasteUppdateringstid)
  out$antal_uppdateringar <- as_int_na(raw$antalUppdateringar)
  out$antal_valdistrikt_raknade <- as_int_na(raw$antalValdistriktRaknade)
  out$antal_valdistrikt_som_ska_raknas <- as_int_na(raw$antalValdistriktSomSkaRaknas)
  out$antal_rostberattigade_raknade <- as_int_na(raw$antalRostberattigadeIRaknadeValdistrikt)
  out$geografiniva <- "valdistrikt"
  for (namn in intersect(names(meta), names(schema))) {
    out[[namn]] <- orapporterade[[namn]][distriktsindex]
  }
  for (namn in names(parti)) out[[namn]] <- parti[[namn]]
  out
}

.valresultat_public_2026 <- function(data, niva, raw = NULL) {
  if (niva == "valdistrikt") {
    context <- attr(raw, "valresultat_distrikt_context", exact = TRUE)
    if (is.null(context)) {
      stop("Internt distriktskontext saknas f\u00f6r det publika resultatet.", call. = FALSE)
    }
    raw <- .normalisera_rakningsmetadata_2026(raw)
    meta <- .valresultat_distrikt_meta_2026(raw, context)
    nyckel <- .valresultat_geo_key("valdistrikt")
    if (anyDuplicated(.valresultat_id_2026(meta, nyckel))) {
      stop("Duplicerad distriktsidentitet i k\u00e4llan.", call. = FALSE)
    }
    if (nrow(data)) {
      index <- match(
        .valresultat_id_2026(data, nyckel),
        .valresultat_id_2026(meta, nyckel)
      )
      if (anyNA(index) || any(!meta$raknat[index])) {
        stop("Parserns rapporterade distrikt matchar inte k\u00e4llan.", call. = FALSE)
      }
      for (namn in c(
        "kommunnamn", "lannamn", "valomradesnamn", "valkretskod", "valkretsnamn"
      )) data[[namn]] <- meta[[namn]][index]
      data$raknat <- rep(TRUE, nrow(data))
    } else {
      data$raknat <- logical()
    }
    rapporterade <- unique(.valresultat_id_2026(data, nyckel))
    if (length(rapporterade) != sum(meta$raknat)) {
      stop("Ett rapporterat valdistrikt saknar partirader.", call. = FALSE)
    }
    orapporterade <- .valresultat_orapporterade_2026(raw, meta)
    orapporterade$raknat <- rep(FALSE, nrow(orapporterade))
    data <- dplyr::bind_rows(data, orapporterade)
  }
  if ("lankod" %in% names(data)) {
    saknas <- is.na(data$lannamn) | !nzchar(data$lannamn)
    data$lannamn[saknas] <- .valresultat_lannamn_2026(data$lankod[saknas])
  }
  data <- .komplettera_kommunnamn_2026(data, data$kommunnamn)
  data <- .valresultat_public_andelar_2026(data)
  columns <- .valresultat_public_columns_2026(niva)
  data[columns]
}
