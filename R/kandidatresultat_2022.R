# 2022 saknar summeradePersonroster. Den officiella personvalsomradesnivans
# listRoster ar darfor primarkalla; distriktsrader summeras inte en gang till.
.kandidatresultat_raw_2022 <- function(raw, kandidaturer) {
  raw <- .normalisera_resultat_2022(raw)
  valtyp <- as_chr_na(raw$valtyp)
  area <- raw$valomrade
  omrades_kod <- as_chr_na(area$kod)
  valkretsar <- area$valkretsLista
  indelad <- length(valkretsar) > 0L
  noder <- if (indelad) valkretsar else list(area)
  giltiga <- kandidaturer |>
    dplyr::filter(giltig %in% TRUE, valtyp == .env$valtyp,
                  valomradeskod == .env$omrades_kod)

  personrader <- vector("list", length(noder))
  personvalrader <- vector("list", length(noder))
  nodstatus <- logical(length(noder))
  for (i in seq_along(noder)) {
    nod <- noder[[i]]
    kod <- as_chr_na(nod$kod)
    if (!.personrost_heltal(nod$antalValdistriktRaknade) ||
        !.personrost_heltal(nod$antalValdistriktSomSkaRaknas) ||
        nod$antalValdistriktRaknade != nod$antalValdistriktSomSkaRaknas ||
        !.personrost_array(nod$kvalificeradeForPersonvalLista) ||
        !.personrost_objekt(nod$valda) ||
        !.personrost_array(nod$valda$partiLedamoterLista) ||
        !.personrost_array(nod$mandatfordelning$partiLista)) {
      stop("Ofullst\u00e4ndigt slutligt kandidatresultat 2022 i omr\u00e5de ", kod, ".",
           call. = FALSE)
    }
    nodstatus[[i]] <- TRUE
    mandat <- nod$mandatfordelning$partiLista
    valda <- nod$valda$partiLedamoterLista
    for (p in mandat) {
      if (!.personrost_id(p$partikod) || !.personrost_heltal(p$antalMandat)) {
        stop("Ogiltig mandatf\u00f6rdelning 2022.", call. = FALSE)
      }
      matchande <- valda[vapply(valda, function(x) identical(x$partikod,
                                                             p$partikod), logical(1))]
      if (p$antalMandat > 0L && (length(matchande) != 1L ||
          !.personrost_array(matchande[[1]]$ledamoter) ||
          length(matchande[[1]]$ledamoter) != p$antalMandat)) {
        stop("Valda 2022 st\u00e4mmer inte med mandatf\u00f6rdelningen.", call. = FALSE)
      }
    }
    for (p in valda) for (ledamot in p$ledamoter) {
      if (identical(as_chr_na(ledamot$kandidatnummer), "0") &&
          !identical(as_chr_na(ledamot$namn), "Kunde inte utses")) {
        stop("Ok\u00e4nd platsh\u00e5llare bland valda 2022.", call. = FALSE)
      }
    }

    k <- giltiga
    if (indelad) k <- dplyr::filter(k, valkretskod == .env$kod)
    universum <- k |>
      dplyr::distinct(kandidatnummer, valtyp, partikod)
    valda_ids <- purrr::map_dfr(valda, function(p) {
      purrr::map_dfr(p$ledamoter, function(x) tibble::tibble(
        kandidatnummer = as_chr_na(x$kandidatnummer), valtyp = valtyp,
        partikod = as_chr_na(p$partikod)
      ))
    })
    if (nrow(valda_ids)) {
      valda_ids <- dplyr::filter(valda_ids, kandidatnummer != "0")
      if (nrow(dplyr::anti_join(valda_ids, universum,
          by = dplyr::join_by(kandidatnummer, valtyp, partikod)))) {
        stop("Valda 2022 saknar giltig kandidatur i personvalsomr\u00e5det.",
             call. = FALSE)
      }
    }
    partier <- c(nod$rostfordelning$rosterPaverkaMandat$partiRoster,
                 nod$rostfordelning$rosterEjPaverkaMandat$partiRoster)
    ovriga <- nod$rostfordelning$rosterPaverkaMandat$rosterOvrigaPartier
    saknade_partier_kompletta <-
      .personrost_array(nod$rostfordelning$rosterPaverkaMandat$partiRoster) &&
      .personrost_objekt(ovriga) && .personrost_heltal(ovriga$antalRoster)
    if (anyDuplicated(vapply(partier, function(p) as_chr_na(p$partikod), ""))) {
      stop("Dubbla partirader i 2022 \u00e5rs personvalsomr\u00e5de.", call. = FALSE)
    }
    rost <- list()
    komplett <- list()
    for (p in partier) {
      if (!.personrost_id(p$partikod) || !.personrost_heltal(p$antalRoster) ||
          !.personrost_array(p$listRoster) || !length(p$listRoster)) {
        stop("Ofullst\u00e4ndiga omr\u00e5deslistor 2022.", call. = FALSE)
      }
      listor <- p$listRoster
      listkod <- vapply(listor, function(l) as_chr_na(l$listnummer), "")
      if (anyNA(listkod) || anyDuplicated(listkod)) {
        stop("Ogiltiga eller dubbla listnummer 2022.", call. = FALSE)
      }
      list_roster <- integer(length(listor))
      for (j in seq_along(listor)) {
        l <- listor[[j]]
        if (!.personrost_heltal(l$antalRoster) ||
            !.personrost_heltal(l$antalRosterMedPersonrost) ||
            !.personrost_array(l$personroster)) {
          stop("Ofullst\u00e4ndigt listvist personr\u00f6stmaterial 2022.", call. = FALSE)
        }
        list_roster[[j]] <- l$antalRoster
        poster <- l$personroster
        ids <- vapply(poster, function(z) as_chr_na(z$kandidatNummer), "")
        tal <- vapply(poster, function(z) as_int_na(z$antalPersonroster), 0L)
        if (anyNA(ids) || anyDuplicated(ids) || anyNA(tal) || any(tal < 0L) ||
            sum(tal) != l$antalRosterMedPersonrost) {
          stop("Personr\u00f6sterna st\u00e4mmer inte inom 2022 \u00e5rs lista.", call. = FALSE)
        }
        if (grepl("-90000$", listkod[[j]]) && length(poster)) {
          stop("Partir\u00f6stlistan 90000 inneh\u00e5ller kandidatpersonr\u00f6ster 2022.",
               call. = FALSE)
        }
        if (length(ids)) rost[[length(rost) + 1L]] <- tibble::tibble(
          kandidatnummer = ids, valtyp = valtyp, partikod = p$partikod,
          antal_personroster_lista = tal
        )
      }
      if (sum(list_roster) != p$antalRoster) {
        stop("Listornas r\u00f6ster st\u00e4mmer inte med partiets r\u00f6ster 2022.",
             call. = FALSE)
      }
      komplett[[length(komplett) + 1L]] <- tibble::tibble(
        partikod = p$partikod, komplett = TRUE
      )
    }
    komplett <- purrr::list_rbind(komplett)
    if (is.null(komplett)) komplett <- tibble::tibble(
      partikod = character(), komplett = logical()
    )
    rost <- purrr::list_rbind(rost)
    if (is.null(rost)) rost <- tibble::tibble(
      kandidatnummer = character(), valtyp = character(), partikod = character(),
      antal_personroster_lista = integer()
    )
    summerat <- rost |>
      dplyr::summarise(antal_personroster_listor = as.integer(
        sum(antal_personroster_lista)),
        .by = c(kandidatnummer, valtyp, partikod))
    officiella <- if (length(nod$kvalificeradeForPersonvalLista)) {
      purrr::map_dfr(nod$kvalificeradeForPersonvalLista,
        function(p) tibble::tibble(
          kandidatnummer = as_chr_na(p$kandidatnummer), valtyp = valtyp,
          partikod = as_chr_na(p$partikod),
          antal_personroster_officiellt = as_int_na(p$antalPersonroster)
        ))
    } else {
      tibble::tibble(
        kandidatnummer = character(), valtyp = character(),
        partikod = character(), antal_personroster_officiellt = integer()
      )
    }
    if (nrow(officiella)) {
      if (anyDuplicated(officiella[c("kandidatnummer", "valtyp", "partikod")])) {
        stop("Dubbla officiella personvalsposter 2022.", call. = FALSE)
      }
      kontroll <- dplyr::left_join(officiella, summerat,
        by = dplyr::join_by(kandidatnummer, valtyp, partikod))
      if (anyNA(kontroll$antal_personroster_officiellt) ||
          anyNA(kontroll$antal_personroster_listor) ||
          any(kontroll$antal_personroster_officiellt !=
              kontroll$antal_personroster_listor)) {
        stop("Officiella personvalsr\u00f6ster st\u00e4mmer inte med omr\u00e5dets listor.",
             call. = FALSE)
      }
    }
    personvalrader[[i]] <- dplyr::mutate(officiella,
      valomradeskod = omrades_kod,
      valkretskod = if (indelad) kod else NA_character_)
    personrader[[i]] <- universum |>
      dplyr::left_join(komplett, by = dplyr::join_by(partikod)) |>
      dplyr::left_join(summerat,
        by = dplyr::join_by(kandidatnummer, valtyp, partikod)) |>
      dplyr::left_join(officiella,
        by = dplyr::join_by(kandidatnummer, valtyp, partikod)) |>
      dplyr::mutate(
        komplett = dplyr::coalesce(komplett, saknade_partier_kompletta),
        antal_personroster = dplyr::case_when(
          !is.na(antal_personroster_officiellt) ~
            antal_personroster_officiellt,
          komplett %in% TRUE ~
            dplyr::coalesce(antal_personroster_listor, 0L),
          .default = NA_integer_
        ),
        valomradeskod = omrades_kod,
        personvalsomradeskod = kod
      ) |>
      dplyr::select(kandidatnummer, valtyp, partikod, valomradeskod,
                    personvalsomradeskod, antal_personroster)
  }
  valda <- parse_valda_ersattare_2026(raw)$valda |>
    dplyr::filter(kandidatnummer != "0")
  giltiga_nycklar <- giltiga |>
    dplyr::distinct(kandidatnummer, valtyp, partikod)
  if (nrow(dplyr::anti_join(valda, giltiga_nycklar,
      by = dplyr::join_by(kandidatnummer, valtyp, partikod)))) {
    stop("Valda 2022 saknar giltig kandidatur.", call. = FALSE)
  }
  list(
    status = tibble::tibble(
      valtyp = valtyp, valomradeskod = omrades_kod,
      valomradesnamn = as_chr_na(area$namn),
      valda_available = all(nodstatus),
      personval_available = all(nodstatus)
    ),
    personrostomraden = purrr::list_rbind(personrader),
    personval = purrr::list_rbind(personvalrader),
    valda = valda
  )
}

.add_kandidatresultat_2022 <- function(kandidater, kandidaturer, val, source,
                                        data_dir, update, archive, progress) {
  index <- .read_resultatindex(2022L, source, data_dir, update, archive)
  paths <- .resultat_paths_2026(index, val)
  parsed <- purrr::map(paths$path, function(path) {
    file <- .resultat_file(2022L, path, source, data_dir, update, archive)
    raw <- read_raw_json_zip_2026(file, type = "mandatfordelning")
    .kandidatresultat_raw_2022(raw, kandidaturer)
  }, .progress = progress)
  .add_kandidatresultat_fran_parsade_2026(
    kandidater, kandidaturer, val, parsed
  )
}
