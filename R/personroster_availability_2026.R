.personrost_array <- function(x) is.list(x) && is.null(names(x))
.personrost_objekt <- function(x) is.list(x) && !is.null(names(x)) && !anyDuplicated(names(x))
.personrost_heltal <- function(x) is.numeric(x) && length(x) == 1L &&
  !is.na(x) && is.finite(x) && x >= 0 && x == trunc(x) && x <= .Machine$integer.max
.personrost_id <- function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)

.personrost_status <- function(x) {
  if (!length(x) || anyNA(x)) return(NA)
  if (all(x)) TRUE else if (all(!x)) FALSE else NA
}

.personrost_rader <- function(x, id) {
  if (!.personrost_array(x)) return(NULL)
  if (!all(vapply(x, function(r) .personrost_objekt(r) &&
    (.personrost_id(r[[id]]) || .personrost_heltal(r[[id]])) &&
    .personrost_heltal(r$antalPersonroster), logical(1)))) return(NULL)
  koder <- vapply(x, function(r) as_chr_na(r[[id]]), "")
  if (anyDuplicated(koder)) return(NULL)
  antal <- vapply(x, function(r) as_int_na(r$antalPersonroster), integer(1))
  names(antal) <- koder
  antal
}

.personrost_partistatus <- function(p) {
  if (!.personrost_objekt(p)) return(NA)
  summering <- p[["summeradePersonroster"]]
  listor <- p[["listRoster"]]
  if (!is.null(listor) && !.personrost_array(listor)) return(NA)
  if (!is.null(summering) && !.personrost_array(summering)) return(NA)
  if (!all(vapply(listor, .personrost_objekt, logical(1)))) return(NA)
  verifierad_nolla <- is.null(summering) && length(listor) > 0L &&
    all(vapply(listor, function(l) {
      .personrost_heltal(l[["antalRosterMedPersonrost"]]) &&
        l[["antalRosterMedPersonrost"]] == 0L &&
        .personrost_array(l[["personroster"]]) &&
        length(l[["personroster"]]) == 0L
    }, logical(1)))
  if (verifierad_nolla) return(TRUE)
  information <- any(vapply(listor, function(l) !is.null(l[["personroster"]]) ||
                             !is.null(l[["antalRosterMedPersonrost"]]), logical(1)))
  if (is.null(summering) && !information) return(FALSE)
  summa <- .personrost_rader(summering, "kandidatnummer")
  if (is.null(summa) || !.personrost_array(listor)) return(NA)
  if (!length(listor) && !length(summa)) {
    return(if (.personrost_heltal(p$antalRoster) && p$antalRoster == 0) TRUE else NA)
  }
  nummer <- vapply(listor, function(l) as_chr_na(l$listnummer), "")
  if (!all(vapply(listor, function(l) .personrost_id(l$listnummer), logical(1))) ||
      anyDuplicated(nummer)) return(NA)
  roster <- lapply(listor, function(l) .personrost_rader(l[["personroster"]], "kandidatNummer"))
  for (i in seq_along(listor)) {
    if (is.null(roster[[i]]) || !.personrost_heltal(listor[[i]]$antalRosterMedPersonrost) ||
        sum(roster[[i]]) != listor[[i]]$antalRosterMedPersonrost) return(NA)
  }
  flat <- unlist(roster, use.names = FALSE)
  ids <- unlist(lapply(roster, names), use.names = FALSE)
  summerat <- if (length(flat)) tapply(flat, ids, sum) else numeric()
  alla <- union(names(summa), names(summerat))
  a <- summa[match(alla, names(summa))]
  b <- summerat[match(alla, names(summerat))]
  a[is.na(a)] <- 0
  b[is.na(b)] <- 0
  if (all(a == b)) TRUE else NA
}

.personrostunderlag_2026 <- function(raw, valomradeskod) {
  status <- tibble::tibble(valtyp = character(), valomradeskod = character(),
                          partikod = character(), personroster_available = logical())
  roster <- tibble::tibble(kandidatnummer = character(), valtyp = character(),
                          valomradeskod = character(), partikod = character(), antal_personroster = integer())
  tom <- list(status = status, roster = roster)
  if (!.personrost_objekt(raw) || !.personrost_array(raw$valdistrikt) ||
      !length(raw$valdistrikt) || !.personrost_id(valomradeskod)) return(tom)
  vd <- raw$valdistrikt
  if (!all(vapply(vd, .personrost_objekt, logical(1)))) return(tom)
  partier <- lapply(vd, function(d) {
    if (!.personrost_objekt(d$rostfordelning) ||
        !.personrost_objekt(d$rostfordelning$rosterPaverkaMandat)) return(NULL)
    d$rostfordelning$rosterPaverkaMandat$partiRoster
  })
  giltiga_partier <- vapply(partier, function(ps) .personrost_array(ps) &&
    all(vapply(ps, function(p) .personrost_objekt(p) && .personrost_id(p$partikod), logical(1))), logical(1))
  koder <- lapply(seq_along(partier), function(i) {
    if (!giltiga_partier[i]) character() else vapply(partier[[i]], function(p) p$partikod, "")
  })
  alla <- sort(unique(unlist(koder)))
  if (!length(alla)) return(tom)
  # Identitet omfattar även typ för uppsamlingsdistrikt.
  identitet_ok <- all(vapply(vd, function(d) .personrost_id(d$valdistriktskod) &&
    .personrost_id(d$kommunkod) && identical(d$valomradeskod, valomradeskod), logical(1)))
  identiteter <- vapply(vd, function(d) paste(as_chr_na(d$valomradeskod), as_chr_na(d$kommunkod),
    as_chr_na(d$valdistriktskod), as_chr_na(d$valdistriktstyp), sep = "/"), "")
  antal <- raw$antalValdistriktSomSkaRaknas
  raknade <- raw$antalValdistriktRaknade
  tackning <- identitet_ok && !anyDuplicated(identiteter) && .personrost_heltal(antal) &&
    antal > 0 && length(vd) == antal && .personrost_heltal(raknade) && raknade <= antal
  for (kod in alla) {
    noder <- lapply(seq_along(vd), function(i) {
      j <- which(koder[[i]] == kod)
      if (length(j) == 1L) partier[[i]][[j]] else NULL
    })
    states <- vapply(noder, .personrost_partistatus, logical(1))
    available <- .personrost_status(states)
    if (!tackning || !as_chr_na(raw$valtyp) %in% c("RD", "RF", "KF") ||
        !.normalisera_rakningstillfalle_2026(raw$rakningstillfalle) %in%
          c("slutlig", "preliminar")) available <- NA
    if (isTRUE(available) &&
        (.normalisera_rakningstillfalle_2026(raw$rakningstillfalle) != "slutlig" ||
         raknade != antal)) available <- NA
    status <- dplyr::bind_rows(status, tibble::tibble(valtyp = as_chr_na(raw$valtyp),
      valomradeskod = valomradeskod, partikod = kod, personroster_available = available))
    if (isTRUE(available)) {
      rader <- lapply(noder, function(p) {
        x <- .personrost_rader(p$summeradePersonroster, "kandidatnummer")
        if (is.null(x) || !length(x)) {
          return(tibble::tibble(
            kandidatnummer = character(),
            antal_personroster = integer()
          ))
        }
        tibble::tibble(kandidatnummer = names(x), antal_personroster = unname(x))
      }) |> purrr::list_rbind()
      if (nrow(rader)) {
        rader <- dplyr::summarise(rader, antal_personroster = sum(antal_personroster), .by = kandidatnummer)
        rader$valtyp <- raw$valtyp
        rader$valomradeskod <- valomradeskod
        rader$partikod <- kod
        roster <- dplyr::bind_rows(roster, rader)
      }
    }
  }
  list(status = status, roster = roster)
}

.personrosttotaler_2026 <- function(kandidaturer, status, roster) {
  roster$.personrost_rad <- rep(TRUE, nrow(roster))
  omraden <- kandidaturer |>
    dplyr::filter(giltig %in% TRUE) |>
    dplyr::distinct(kandidatnummer, valtyp, partikod, valomradeskod) |>
    dplyr::left_join(status, by = dplyr::join_by(valtyp, valomradeskod, partikod), relationship = "many-to-one") |>
    dplyr::left_join(roster, by = dplyr::join_by(kandidatnummer, valtyp, valomradeskod, partikod), relationship = "many-to-one")
  omraden |>
    dplyr::summarise(
      antal_personroster_totalt = if (isTRUE(.personrost_status(personroster_available))) {
        sum(ifelse(is.na(.personrost_rad), 0L, antal_personroster))
      } else NA_integer_,
      .by = c(kandidatnummer, valtyp, partikod)
    )
}
