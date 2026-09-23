.personroster_listnummer_2026 <- function(listnummer, partikod) {
  prefix <- paste0(partikod, "-")
  if (!.personrost_id(listnummer) || !startsWith(listnummer, prefix) ||
      !nzchar(substring(listnummer, nchar(prefix) + 1L))) {
    stop("Listnummer st\u00e4mmer inte med partikod.", call. = FALSE)
  }
  substring(listnummer, nchar(prefix) + 1L)
}

.personroster_validera_listor_2026 <- function(parti, summering = TRUE) {
  listor <- parti$listRoster
  if (is.null(listor)) return(logical())
  if (!.personrost_array(listor)) stop("Ogiltig listRoster-struktur.", call. = FALSE)
  nummer <- vapply(listor, function(l) {
    if (!.personrost_objekt(l)) stop("Ogiltig listRoster-struktur.", call. = FALSE)
    .personroster_listnummer_2026(l$listnummer, parti$partikod)
    as_chr_na(l$listnummer)
  }, "")
  if (anyDuplicated(nummer)) stop("Dubbla listnummer i partirad.", call. = FALSE)
  status <- vapply(listor, function(l) {
    if (!.personrost_heltal(l$antalRoster)) {
      stop("Ogiltigt r\u00f6stetal p\u00e5 lista.", call. = FALSE)
    }
    if (is.null(l$personroster) || is.null(l$antalRosterMedPersonrost)) return(NA)
    detalj <- .personrost_rader(l$personroster, "kandidatNummer")
    if (is.null(detalj) || !.personrost_heltal(l$antalRosterMedPersonrost)) {
      stop("Ogiltiga personr\u00f6ster p\u00e5 lista.", call. = FALSE)
    }
    if (sum(detalj) != l$antalRosterMedPersonrost) {
      stop("Listans personr\u00f6ster st\u00e4mmer inte med antalRosterMedPersonrost.", call. = FALSE)
    }
    TRUE
  }, logical(1))
  if (.personrost_heltal(parti$antalRoster) &&
      sum(vapply(listor, function(l) as_int_na(l$antalRoster), integer(1))) !=
        parti$antalRoster) {
    stop("Listornas r\u00f6ster st\u00e4mmer inte med partir\u00f6sterna.", call. = FALSE)
  }
  if (summering && all(status %in% TRUE) && !is.null(parti$summeradePersonroster)) {
    summerade <- .personrost_rader(parti$summeradePersonroster, "kandidatnummer")
    if (is.null(summerade)) stop("Ogiltiga summerade personr\u00f6ster.", call. = FALSE)
    detalj <- unlist(lapply(listor, function(l) {
      .personrost_rader(l$personroster, "kandidatNummer")
    }))
    summerat <- if (length(detalj)) tapply(detalj, names(detalj), sum) else numeric()
    alla <- union(names(summerade), names(summerat))
    a <- summerade[match(alla, names(summerade))]
    b <- summerat[match(alla, names(summerat))]
    a[is.na(a)] <- 0
    b[is.na(b)] <- 0
    if (!identical(unname(as.numeric(a)), unname(as.numeric(b)))) {
      stop("Listvisa personr\u00f6ster st\u00e4mmer inte med summeradePersonroster.", call. = FALSE)
    }
  }
  status
}

.personroster_distriktsunderlag_2026 <- function(raw, omraden) {
  parsed <- parse_personroster_2026(raw)
  status <- logical(nrow(parsed$listroster))
  partiroster <- integer(nrow(parsed$listroster))
  i <- 0L
  distrikt_id <- character()
  for (d in raw$valdistrikt) {
    if (!.personrost_objekt(d) || !.personrost_id(d$valdistriktskod) ||
        !.personrost_id(d$kommunkod) ||
        !identical(as_chr_na(d$valomradeskod), omraden$valomradeskod[[1]])) {
      stop("Ogiltig distriktsidentitet i personr\u00f6stfilen.", call. = FALSE)
    }
    distrikt_id <- c(distrikt_id, paste(d$valomradeskod, d$kommunkod,
      d$valdistriktskod, as_chr_na(d$valdistriktstyp), sep = "/"))
    if (is.null(d$rostfordelning)) next
    partier <- d$rostfordelning$rosterPaverkaMandat$partiRoster
    if (!.personrost_array(partier)) stop("Ogiltiga partirader i distrikt.", call. = FALSE)
    koder <- vapply(partier, function(p) as_chr_na(p$partikod), "")
    if (anyNA(koder) || anyDuplicated(koder)) {
      stop("Dubbla eller ogiltiga partirader i distrikt.", call. = FALSE)
    }
    for (p in partier) {
      valid <- .personroster_validera_listor_2026(p)
      n <- length(valid)
      if (n) {
        index <- seq.int(i + 1L, length.out = n)
        status[index] <- valid
        partiroster[index] <- as_int_na(p$antalRoster)
        i <- i + n
      }
    }
  }
  if (anyDuplicated(distrikt_id) || i != nrow(parsed$listroster)) {
    stop("Dubbla distrikt eller felaktig listordning i personr\u00f6stfilen.", call. = FALSE)
  }
  listor <- parsed$listroster
  listor$list_complete <- status
  listor$antal_partiroster <- partiroster
  indelad <- all(!is.na(omraden$valkretskod))
  listor$personvalsomradeskod <- if (indelad) listor$kretskod else listor$valomradeskod
  if (any(!listor$personvalsomradeskod %in% omraden$personvalsomradeskod)) {
    stop("Distriktet saknar personvalsomr\u00e5de i mandatfilen.", call. = FALSE)
  }
  parsed$listroster <- listor
  parsed
}

.personroster_mandatlistor_2026 <- function(omraden) {
  lista <- vector("list", nrow(omraden))
  roster <- vector("list", nrow(omraden))
  for (i in seq_len(nrow(omraden))) {
    partier <- omraden$.personval_nod[[i]]$rostfordelning$rosterPaverkaMandat$partiRoster
    if (is.null(partier)) next
    if (!.personrost_array(partier)) stop("Ogiltiga partirader i mandatfilen.", call. = FALSE)
    lista[[i]] <- purrr::map_dfr(partier, function(p) {
      valid <- .personroster_validera_listor_2026(p, summering = TRUE)
      if (!length(valid)) return(NULL)
      tibble::tibble(
        personvalsomradeskod = omraden$personvalsomradeskod[[i]],
        partikod = as_chr_na(p$partikod),
        listnummer_raw = vapply(p$listRoster, function(l) as_chr_na(l$listnummer), ""),
        antal_listroster = vapply(p$listRoster, function(l) as_int_na(l$antalRoster), 0L),
        antal_roster_med_personrost_lista = vapply(p$listRoster,
          function(l) as_int_na(l$antalRosterMedPersonrost), 0L),
        list_complete = valid
      )
    })
    roster[[i]] <- purrr::map_dfr(partier, function(p) {
      purrr::map_dfr(p$listRoster, function(l) {
        if (is.null(l$personroster)) return(NULL)
        tibble::tibble(
          personvalsomradeskod = omraden$personvalsomradeskod[[i]],
          partikod = as_chr_na(p$partikod),
          listnummer_raw = as_chr_na(l$listnummer),
          kandidatnummer = vapply(l$personroster,
            function(r) as_chr_na(r$kandidatNummer), ""),
          antal_personroster_lista = vapply(l$personroster,
            function(r) as_int_na(r$antalPersonroster), 0L)
        )
      })
    })
  }
  listor <- purrr::list_rbind(lista)
  roster <- purrr::list_rbind(roster)
  if (!ncol(listor)) listor <- tibble::tibble(
    personvalsomradeskod = character(), partikod = character(),
    listnummer_raw = character(), antal_listroster = integer(),
    antal_roster_med_personrost_lista = integer(), list_complete = logical())
  if (!ncol(roster)) roster <- tibble::tibble(
    personvalsomradeskod = character(), partikod = character(),
    listnummer_raw = character(), kandidatnummer = character(),
    antal_personroster_lista = integer())
  list(listor = listor, roster = roster)
}

.personroster_distrikt_summerade_2026 <- function(
    kandidaturer, giltiga, kandidater_id, lista, detalj, summerad,
    omraden, valtyp, indelad, komplettera_nollor) {
  valomradeskod <- omraden$valomradeskod[[1]]
  listnyckel <- c("valtyp", "valomradeskod", "personvalsomradeskod",
                 "partikod", "listnummer_raw")
  geonyckel <- c("valtyp", "valomradeskod", "personvalsomradeskod",
                "partikod", "kommunkod", "valdistriktskod", "valdistriktstyp")
  nyckel <- c(geonyckel, "kandidatnummer")
  giltiga_kandidater <- kandidaturer |>
    dplyr::filter(giltig %in% TRUE, valtyp == .env$valtyp,
                  valomradeskod == .env$valomradeskod) |>
    dplyr::mutate(personvalsomradeskod = if (indelad) valkretskod else valomradeskod) |>
    dplyr::distinct(valtyp, valomradeskod, personvalsomradeskod,
                    partikod, kandidatnummer)
  giltiga_listor <- dplyr::select(giltiga, dplyr::all_of(listnyckel), kandidatnummer)
  geo <- lista |>
    dplyr::select(dplyr::all_of(geonyckel), valdistriktsnamn, lankod,
                  antal_partiroster) |>
    dplyr::distinct()
  if (anyDuplicated(geo[geonyckel])) {
    stop("Mots\u00e4gelsefull distriktsgeografi eller partir\u00f6stetal.", call. = FALSE)
  }
  observerade <- summerad |>
    dplyr::mutate(personvalsomradeskod = if (indelad) kretskod else valomradeskod) |>
    dplyr::inner_join(giltiga_kandidater,
      by = dplyr::join_by(valtyp, valomradeskod, personvalsomradeskod,
                          partikod, kandidatnummer), relationship = "many-to-one") |>
    dplyr::select(dplyr::all_of(nyckel), antal_personroster,
                  valdistriktsnamn, lankod)
  if (anyDuplicated(observerade[nyckel])) {
    stop("Dubbla summerade personr\u00f6stnycklar i distrikt.", call. = FALSE)
  }
  observerade <- dplyr::left_join(observerade,
    dplyr::select(geo, dplyr::all_of(geonyckel), antal_partiroster),
    by = geonyckel, relationship = "many-to-one")

  # Bara kandidater pa ofullstandiga observerade listor behover kontrolleras.
  ofullstandiga <- lista |>
    dplyr::filter(!list_complete %in% TRUE) |>
    dplyr::select(dplyr::all_of(geonyckel), listnummer_raw) |>
    dplyr::inner_join(giltiga_listor, by = listnyckel,
                      relationship = "many-to-many") |>
    dplyr::select(dplyr::all_of(nyckel)) |>
    dplyr::distinct() |>
    dplyr::mutate(underlag_ofullstandigt = TRUE)
  observerade <- observerade |>
    dplyr::left_join(ofullstandiga, by = nyckel, relationship = "many-to-one") |>
    dplyr::select(-underlag_ofullstandigt)

  if (komplettera_nollor) {
    population <- lista |>
      dplyr::select(dplyr::all_of(geonyckel), listnummer_raw) |>
      dplyr::inner_join(giltiga_listor, by = listnyckel,
                        relationship = "many-to-many") |>
      dplyr::select(dplyr::all_of(nyckel)) |>
      dplyr::distinct()
    positiva_detaljer <- detalj |>
      dplyr::filter(antal_personroster_lista > 0L) |>
      dplyr::mutate(personvalsomradeskod = if (indelad) kretskod else valomradeskod) |>
      dplyr::select(dplyr::all_of(nyckel)) |>
      dplyr::distinct() |>
      dplyr::mutate(detalj_positiv = TRUE)
    nollor <- population |>
      dplyr::anti_join(observerade, by = nyckel) |>
      dplyr::left_join(ofullstandiga, by = nyckel, relationship = "many-to-one") |>
      dplyr::left_join(positiva_detaljer, by = nyckel, relationship = "many-to-one") |>
      dplyr::mutate(antal_personroster = dplyr::if_else(
        underlag_ofullstandigt %in% TRUE | detalj_positiv %in% TRUE,
        NA_integer_, 0L)) |>
      dplyr::filter(antal_personroster == 0L) |>
      dplyr::select(dplyr::all_of(nyckel), antal_personroster) |>
      dplyr::left_join(geo, by = geonyckel, relationship = "many-to-one")
    observerade <- dplyr::bind_rows(observerade, nollor)
  }
  dplyr::left_join(observerade, kandidater_id,
    by = dplyr::join_by(kandidatnummer, valtyp, partikod),
    relationship = "many-to-one")
}

.personroster_utokad_2026 <- function(kandidaturer, kandidater, rost_raw,
                                      mandat_raw, niva, per_lista,
                                      komplettera_nollor = FALSE) {
  omraden <- .personvalsomraden_mandat_2026(mandat_raw)
  valtyp <- as_chr_na(mandat_raw$valtyp)
  if (!identical(as_chr_na(rost_raw$valtyp), valtyp)) {
    stop("R\u00f6st- och mandatfilen avser olika valtyper.", call. = FALSE)
  }
  indelad <- all(!is.na(omraden$valkretskod))
  giltiga <- kandidaturer |>
    dplyr::filter(giltig %in% TRUE, valtyp == .env$valtyp,
                  valomradeskod == omraden$valomradeskod[[1]]) |>
    dplyr::mutate(
      personvalsomradeskod = if (indelad) valkretskod else valomradeskod,
      listnummer_raw = paste0(partikod, "-", listnummer)
    ) |>
    dplyr::filter(!is.na(listnummer), listnummer != "90000") |>
    dplyr::distinct(valtyp, valomradeskod, personvalsomradeskod,
                    partikod, listnummer_raw, listnummer, kandidatnummer)
  if (anyDuplicated(giltiga[c("personvalsomradeskod", "partikod",
                              "listnummer_raw", "kandidatnummer")])) {
    stop("Dubbla giltiga kandidatlistnycklar.", call. = FALSE)
  }
  kandidater_id <- dplyr::select(kandidater, kandidatnummer, valtyp, partikod,
                                  namn, partiforkortning, partibeteckning)
  giltiga <- dplyr::left_join(giltiga, kandidater_id,
    by = dplyr::join_by(kandidatnummer, valtyp, partikod), relationship = "many-to-one")
  parsed <- .personroster_distriktsunderlag_2026(rost_raw, omraden)
  lista <- parsed$listroster |>
    dplyr::rename(listnummer_raw = listnummer,
                  antal_listroster = antal_roster_lista) |>
    dplyr::select(valtyp, valomradeskod, personvalsomradeskod, partikod,
      listnummer_raw, antal_listroster, antal_roster_med_personrost,
      list_complete, antal_partiroster, valdistriktskod, valdistriktsnamn,
      valdistriktstyp, kommunkod, lankod)
  detalj <- parsed$personroster |>
    dplyr::rename(listnummer_raw = listnummer,
                  antal_personroster_lista = antal_personroster)
  summerad <- parsed$personroster_summerade
  for (data in list(lista, detalj, summerad)) {
    krav <- intersect(c("valomradeskod", "partikod", "valdistriktskod",
                        "kommunkod", "kandidatnummer"), names(data))
    if (nrow(data) && anyNA(data[krav])) {
      stop("Saknad identitet i personr\u00f6stfilen.", call. = FALSE)
    }
  }
  distrikt_nyckel <- c("valomradeskod", "kommunkod", "valdistriktskod",
                       "valdistriktstyp", "partikod", "listnummer_raw")
  if (anyDuplicated(lista[distrikt_nyckel])) {
    stop("Dubbla listor i personr\u00f6stfilen.", call. = FALSE)
  }
  if (niva == "valdistrikt") {
    if (per_lista) {
      detalj <- dplyr::select(detalj, dplyr::all_of(distrikt_nyckel),
                              valtyp, kretskod, kandidatnummer,
                              antal_personroster_lista)
      if (anyDuplicated(detalj[c(distrikt_nyckel, "kandidatnummer")])) {
        stop("Dubbla kandidatrader p\u00e5 lista.", call. = FALSE)
      }
      if (komplettera_nollor) {
        out <- dplyr::inner_join(lista, giltiga,
          by = dplyr::join_by(valtyp, valomradeskod, personvalsomradeskod,
                              partikod, listnummer_raw), relationship = "many-to-many") |>
          dplyr::left_join(detalj,
            by = dplyr::join_by(valtyp, valomradeskod, kommunkod,
              valdistriktskod, valdistriktstyp, partikod,
              listnummer_raw, kandidatnummer), relationship = "one-to-one") |>
          dplyr::mutate(antal_personroster = dplyr::if_else(list_complete %in% TRUE,
            dplyr::coalesce(antal_personroster_lista, 0L), NA_integer_),
            .before = antal_personroster_lista) |>
          dplyr::filter(!is.na(antal_personroster_lista) |
                          antal_personroster == 0L)
      } else {
        out <- detalj |>
          dplyr::mutate(personvalsomradeskod = if (indelad) kretskod else valomradeskod) |>
          dplyr::inner_join(giltiga,
            by = dplyr::join_by(valtyp, valomradeskod, personvalsomradeskod,
              partikod, listnummer_raw, kandidatnummer),
            relationship = "many-to-one") |>
          dplyr::left_join(lista,
            by = dplyr::join_by(valtyp, valomradeskod, personvalsomradeskod,
              partikod, listnummer_raw, kommunkod, valdistriktskod,
              valdistriktstyp), relationship = "many-to-one") |>
          dplyr::mutate(antal_personroster = dplyr::if_else(list_complete %in% TRUE,
            antal_personroster_lista, NA_integer_),
            .before = antal_personroster_lista)
      }
    } else {
      out <- .personroster_distrikt_summerade_2026(
        kandidaturer, giltiga, kandidater_id, lista, detalj, summerad,
        omraden, valtyp, indelad, komplettera_nollor)
    }
    out <- dplyr::left_join(out,
      dplyr::select(omraden, personvalsomradeskod,
                    personvalsomradesnamn, valomradesnamn,
                    valkretskod, valkretsnamn),
      by = dplyr::join_by(personvalsomradeskod), relationship = "many-to-one")
    out$geografiniva <- "valdistrikt"
    out$kommunnamn <- kommunnamn_2026$kommunnamn[
      match(out$kommunkod, kommunnamn_2026$kommunkod)]
    out$lannamn <- .valresultat_lannamn_2026(out$lankod)
  } else {
    mandatlistor <- .personroster_mandatlistor_2026(omraden)
    underlag <- .personrostomradesunderlag_2026(
      rost_raw, omraden$valomradeskod[[1]], omraden)
    avstamda <- .personrostomraden_avstamda_2026(
      rost_raw, omraden, mandatlistor, parsed)
    # J\u00e4mf\u00f6r de officiella listresultaten med r\u00e5a distriktsresultat innan
    # ogiltiga kandidaturer filtreras bort.
    d_list <- lista |>
      dplyr::summarise(
        antal_lista_distrikt = as.integer(sum(antal_listroster)),
        antal_personval_distrikt = as.integer(sum(antal_roster_med_personrost)),
        .by = c(personvalsomradeskod, partikod, listnummer_raw)
      )
    check <- dplyr::full_join(mandatlistor$listor, d_list,
      by = dplyr::join_by(personvalsomradeskod, partikod, listnummer_raw))
    kompletta <- dplyr::filter(underlag$status, personroster_available %in% TRUE)
    check <- dplyr::inner_join(check, kompletta,
      by = dplyr::join_by(personvalsomradeskod, partikod))
    if (anyNA(check$antal_listroster) || anyNA(check$antal_lista_distrikt) ||
        any(check$antal_listroster != check$antal_lista_distrikt) ||
        any(check$antal_roster_med_personrost_lista !=
            check$antal_personval_distrikt)) {
      stop("Distriktens listr\u00f6ster st\u00e4mmer inte med mandatfilen.", call. = FALSE)
    }
    d_person <- detalj |>
      dplyr::mutate(personvalsomradeskod = if (indelad) kretskod else valomradeskod) |>
      dplyr::summarise(
        antal_personroster_distrikt = as.integer(sum(antal_personroster_lista)),
        .by = c(personvalsomradeskod, partikod, listnummer_raw, kandidatnummer))
    person_check <- dplyr::full_join(mandatlistor$roster, d_person,
      by = dplyr::join_by(personvalsomradeskod, partikod,
        listnummer_raw, kandidatnummer)) |>
      dplyr::inner_join(kompletta,
        by = dplyr::join_by(personvalsomradeskod, partikod))
    if (anyNA(person_check$antal_personroster_lista) ||
        anyNA(person_check$antal_personroster_distrikt) ||
        any(person_check$antal_personroster_lista !=
            person_check$antal_personroster_distrikt)) {
      stop("Distriktens listvisa personr\u00f6ster st\u00e4mmer inte med mandatfilen.",
           call. = FALSE)
    }
    out <- dplyr::left_join(giltiga, mandatlistor$listor,
      by = dplyr::join_by(personvalsomradeskod, partikod, listnummer_raw),
      relationship = "many-to-one") |>
      dplyr::left_join(mandatlistor$roster,
        by = dplyr::join_by(personvalsomradeskod, partikod,
                            listnummer_raw, kandidatnummer),
        relationship = "one-to-one") |>
      dplyr::left_join(dplyr::select(underlag$status,
         personvalsomradeskod, partikod, personroster_available),
         by = dplyr::join_by(personvalsomradeskod, partikod),
         relationship = "many-to-one") |>
      dplyr::mutate(
        .avstamt = avstamda[match(personvalsomradeskod, names(avstamda))] %in% TRUE,
        antal_personroster = dplyr::if_else(
          .avstamt | (personroster_available %in% TRUE &
                        list_complete %in% TRUE),
          dplyr::coalesce(antal_personroster_lista, 0L), NA_integer_)
      )
    out <- dplyr::left_join(out,
      dplyr::select(omraden, personvalsomradeskod, geografiniva,
                    personvalsomradesnamn, valomradesnamn,
                    valkretskod, valkretsnamn),
      by = dplyr::join_by(personvalsomradeskod), relationship = "many-to-one")
    out$antal_listroster <- dplyr::if_else(
      out$.avstamt, dplyr::coalesce(out$antal_listroster, 0L),
      dplyr::if_else(out$personroster_available %in% TRUE,
                     out$antal_listroster, NA_integer_))
    out <- dplyr::filter(out,
      !is.na(antal_personroster_lista) |
        (komplettera_nollor & antal_personroster == 0L))
    partiroster <- .personval_partiroster_2026(omraden)
    out$antal_partiroster <- partiroster$antal_partiroster[
      match(paste(out$personvalsomradeskod, out$partikod),
            paste(partiroster$personvalsomradeskod, partiroster$partikod))]
  }
  officiella <- .personval_officiella_2026(omraden)
  okanda <- dplyr::anti_join(officiella, giltiga,
    by = dplyr::join_by(kandidatnummer, partikod, personvalsomradeskod))
  if (nrow(okanda)) {
    stop("Officiell personvalskandidat saknar giltig kandidatur.", call. = FALSE)
  }
  kval <- dplyr::distinct(officiella, kandidatnummer, partikod,
                           personvalsomradeskod)
  kval$officiell <- TRUE
  out <- dplyr::left_join(out, kval,
    by = dplyr::join_by(kandidatnummer, partikod, personvalsomradeskod),
    relationship = "many-to-one")
  out$kvalificerad_personval <- dplyr::case_when(
    out$officiell %in% TRUE ~ TRUE,
    omraden$personval_available[
      match(out$personvalsomradeskod, omraden$personvalsomradeskod)] %in% TRUE ~ FALSE,
    .default = NA
  )
  out$valtillfalle <- as_chr_na(mandat_raw$valtillfalle)
  out$rakningstillfalle <- .normalisera_rakningstillfalle_2026(
    mandat_raw$rakningstillfalle)
  out$valdatum <- as_chr_na(mandat_raw$valdatum)
  out$test <- as_lgl_na(mandat_raw$test)
  out$andel_personroster <- dplyr::if_else(
    !is.na(out$antal_personroster) & !is.na(out$antal_partiroster) &
      out$antal_partiroster > 0L,
    out$antal_personroster / out$antal_partiroster, NA_real_)
  if (per_lista) {
    out$andel_personroster_lista <- dplyr::if_else(
      !is.na(out$antal_personroster) & !is.na(out$antal_listroster) &
        out$antal_listroster > 0L,
      out$antal_personroster / out$antal_listroster, NA_real_)
    out$listnummer <- substring(out$listnummer_raw, nchar(out$partikod) + 2L)
  }
  if (niva == "personvalsomrade") {
    out <- .kort_kommunnamn_2026(out)
    out <- .kort_kommunnamn_2026(out,
      kodkolumn = "personvalsomradeskod", namnkolumn = "personvalsomradesnamn",
      rader = out$geografiniva == "kommun")
  } else {
    out <- .kort_kommunnamn_2026(out)
    out <- .kort_kommunnamn_2026(out,
      kodkolumn = "personvalsomradeskod", namnkolumn = "personvalsomradesnamn",
      rader = out$valtyp == "KF" & is.na(out$valkretskod))
  }
  kolumner <- c("valtillfalle", "valtyp", "kandidatnummer", "namn", "partikod",
    if (per_lista) "listnummer", "partiforkortning", "partibeteckning",
    "geografiniva", if (niva == "valdistrikt") c("valdistriktskod",
      "valdistriktsnamn", "valdistriktstyp", "kommunkod", "kommunnamn",
      "lankod", "lannamn"), "personvalsomradeskod", "personvalsomradesnamn",
    "valomradeskod", "valomradesnamn", "valkretskod", "valkretsnamn",
    "antal_personroster", "antal_partiroster", "andel_personroster",
    if (per_lista) c("antal_listroster", "andel_personroster_lista"),
    "kvalificerad_personval", "rakningstillfalle", "valdatum", "test")
  out <- dplyr::select(out, dplyr::all_of(kolumner))
  nyckel <- c("valtillfalle", "valtyp", "rakningstillfalle",
    "valomradeskod", "personvalsomradeskod", "partikod", "kandidatnummer",
    if (niva == "valdistrikt") c("kommunkod", "valdistriktskod", "valdistriktstyp"),
    if (per_lista) "listnummer")
  if (anyDuplicated(out[nyckel])) {
    stop("Dubbla personr\u00f6stnycklar i resultatet.", call. = FALSE)
  }
  out
}
