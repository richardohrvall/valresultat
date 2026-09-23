.personrostomraden_avstamda_2026 <- function(raw, omraden,
                                               mandatlistor = NULL,
                                               distriktsunderlag = NULL) {
  koder <- omraden$personvalsomradeskod
  avstamda <- stats::setNames(rep(FALSE, length(koder)), koder)
  vd <- raw$valdistrikt
  antal <- raw$antalValdistriktSomSkaRaknas
  raknade <- raw$antalValdistriktRaknade
  if (!identical(.normalisera_rakningstillfalle_2026(raw$rakningstillfalle),
                 "slutlig") || !.personrost_array(vd) || !length(vd) ||
      !.personrost_heltal(antal) || !.personrost_heltal(raknade) ||
      length(vd) != antal || raknade != antal ||
      !all(vapply(vd, .personrost_objekt, logical(1)))) return(avstamda)

  indelad <- all(!is.na(omraden$valkretskod))
  distriktsomrade <- if (indelad) {
    vapply(vd, function(d) as_chr_na(d$kretskod), "")
  } else {
    vapply(vd, function(d) as_chr_na(d$valomradeskod), "")
  }
  if (anyNA(distriktsomrade) || any(!distriktsomrade %in% koder)) {
    return(avstamda)
  }

  for (i in seq_along(koder)) {
    distrikt <- vd[distriktsomrade == koder[[i]]]
    nod <- omraden$.personval_nod[[i]]
    roster <- nod$rostfordelning$rosterPaverkaMandat
    partier <- roster$partiRoster
    ovriga <- roster$rosterOvrigaPartier$antalRoster
    if (!length(distrikt) ||
        !.personrost_heltal(nod$antalValdistriktRaknade) ||
        !.personrost_heltal(nod$antalValdistriktSomSkaRaknas) ||
        nod$antalValdistriktRaknade != length(distrikt) ||
        nod$antalValdistriktSomSkaRaknas != length(distrikt) ||
        !all(vapply(distrikt, function(d) {
          .personrost_objekt(d$rostfordelning) &&
            .personrost_array(d$rostfordelning$rosterPaverkaMandat$partiRoster)
        }, logical(1))) ||
        !.personrost_array(partier) ||
        !.personrost_heltal(roster$antalRoster) ||
        !.personrost_heltal(ovriga) || ovriga != 0L ||
        !all(vapply(partier, function(p) {
          .personrost_objekt(p) && .personrost_id(p$partikod) &&
            .personrost_heltal(p$antalRoster)
        }, logical(1)))) next
    partikoder <- vapply(partier, function(p) p$partikod, "")
    if (anyDuplicated(partikoder)) {
      stop("Dubbla partirader i personvalsomr\u00e5det.", call. = FALSE)
    }
    partiroster <- sum(vapply(partier, function(p) as_int_na(p$antalRoster), 0L))
    if (partiroster != roster$antalRoster) {
      stop("Partir\u00f6sterna st\u00e4mmer inte med omr\u00e5dets giltiga r\u00f6ster.",
           call. = FALSE)
    }
    avstamda[[i]] <- TRUE
  }
  if (!any(avstamda)) return(avstamda)

  if (is.null(mandatlistor)) mandatlistor <- .personroster_mandatlistor_2026(omraden)
  if (is.null(distriktsunderlag)) {
    distriktsunderlag <- .personroster_distriktsunderlag_2026(raw, omraden)
  }
  listnyckel <- c("personvalsomradeskod", "partikod", "listnummer_raw")
  personnyckel <- c(listnyckel, "kandidatnummer")
  d_listor <- distriktsunderlag$listroster |>
    dplyr::rename(listnummer_raw = listnummer) |>
    dplyr::summarise(
      antal_lista_distrikt = as.integer(sum(antal_roster_lista)),
      antal_personval_distrikt = as.integer(sum(antal_roster_med_personrost)),
      alla_kompletta = all(list_complete %in% TRUE), .by = dplyr::all_of(listnyckel)
    )
  d_person <- distriktsunderlag$personroster |>
    dplyr::mutate(personvalsomradeskod = if (indelad) kretskod else valomradeskod,
                  listnummer_raw = listnummer) |>
    dplyr::summarise(
      antal_personroster_distrikt = as.integer(sum(antal_personroster)),
      .by = dplyr::all_of(personnyckel)
    )

  for (i in which(avstamda)) {
    kod <- koder[[i]]
    ml <- dplyr::filter(mandatlistor$listor, personvalsomradeskod == kod)
    dl <- dplyr::filter(d_listor, personvalsomradeskod == kod)
    if (any(!ml$list_complete %in% TRUE) ||
        any(!dl$alla_kompletta %in% TRUE)) {
      avstamda[[i]] <- FALSE
      next
    }
    listor <- dplyr::full_join(ml, dl, by = dplyr::join_by(
      personvalsomradeskod, partikod, listnummer_raw))
    if (anyNA(listor$antal_listroster) || anyNA(listor$antal_lista_distrikt) ||
        any(listor$antal_listroster != listor$antal_lista_distrikt) ||
        any(listor$antal_roster_med_personrost_lista !=
              listor$antal_personval_distrikt)) {
      stop("Omr\u00e5dets och distriktens listr\u00f6ster st\u00e4mmer inte.", call. = FALSE)
    }
    partier <- omraden$.personval_nod[[i]]$rostfordelning$rosterPaverkaMandat$partiRoster
    partiroster <- sum(vapply(partier, function(p) as_int_na(p$antalRoster), 0L))
    if (sum(ml$antal_listroster) != partiroster) {
      stop("Listornas r\u00f6ster st\u00e4mmer inte med partiernas r\u00f6ster.", call. = FALSE)
    }
    mp <- dplyr::filter(mandatlistor$roster, personvalsomradeskod == kod)
    dp <- dplyr::filter(d_person, personvalsomradeskod == kod)
    person <- dplyr::full_join(mp, dp, by = dplyr::join_by(
      personvalsomradeskod, partikod, listnummer_raw, kandidatnummer))
    if (anyNA(person$antal_personroster_lista) ||
        anyNA(person$antal_personroster_distrikt) ||
        any(person$antal_personroster_lista !=
              person$antal_personroster_distrikt)) {
      stop("Omr\u00e5dets och distriktens personr\u00f6ster st\u00e4mmer inte.",
           call. = FALSE)
    }
  }
  avstamda
}

.personroster_summerade_omrade_2026 <- function(omraden) {
  out <- purrr::map2_dfr(omraden$personvalsomradeskod, omraden$.personval_nod,
    function(kod, nod) {
      partier <- nod$rostfordelning$rosterPaverkaMandat$partiRoster
      if (is.null(partier)) return(NULL)
      purrr::map_dfr(partier, function(p) {
        rader <- p$summeradePersonroster
        if (is.null(rader)) return(NULL)
        roster <- .personrost_rader(rader, "kandidatnummer")
        if (is.null(roster)) {
          stop("Ogiltiga summerade personr\u00f6ster i personvalsomr\u00e5det.",
               call. = FALSE)
        }
        tibble::tibble(
          personvalsomradeskod = kod, partikod = as_chr_na(p$partikod),
          kandidatnummer = names(roster),
          antal_personroster_omrade = unname(roster)
        )
      })
    })
  if (!ncol(out)) out <- tibble::tibble(
    personvalsomradeskod = character(), partikod = character(),
    kandidatnummer = character(), antal_personroster_omrade = integer())
  out
}
