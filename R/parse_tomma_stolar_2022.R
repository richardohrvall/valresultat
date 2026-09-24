# I 2022 års slutliga mandatfiler upptar "Kunde inte utses" en plats i
# valda-listan. Kandidatnummer 0 är en platsmarkör, inte en vald person.
parse_tomma_stolar_2022 <- function(raw) {
  empty <- tibble::tibble(
    valtyp = character(), geografiniva = character(),
    valomradeskod = character(), valkretskod = character(),
    partikod = character(), antal_tomma_stolar = integer()
  )
  if (!identical(raw$rakningstillfalle, "slutlig")) return(empty)
  valtyp <- as_chr_na(raw$valtyp)
  omradesniva <- c(RD = "riket", RF = "region", KF = "kommun")[[valtyp]]
  valkretsniva <- c(RD = "riksdagsvalkrets", RF = "regionvalkrets",
                   KF = "kommunvalkrets")[[valtyp]]
  parse_nod <- function(obj, niva, valkretskod = NA_character_) {
    if (is.null(obj$valda) || is.null(obj$mandatfordelning) ||
        !is.list(obj$valda$partiLedamoterLista) ||
        !is.list(obj$mandatfordelning$partiLista) ||
        !length(obj$mandatfordelning$partiLista) ||
        !.personrost_heltal(obj$antalValdistriktRaknade) ||
        !.personrost_heltal(obj$antalValdistriktSomSkaRaknas) ||
        obj$antalValdistriktRaknade != obj$antalValdistriktSomSkaRaknas) {
      return(empty)
    }
    mandat <- obj$mandatfordelning$partiLista
    valda <- obj$valda$partiLedamoterLista
    if (!all(vapply(mandat, function(p) .personrost_id(p$partikod) &&
        .personrost_heltal(p$antalMandat), logical(1))) ||
        !all(vapply(valda, function(p) .personrost_id(p$partikod) &&
        is.list(p$ledamoter), logical(1)))) return(empty)
    mkod <- vapply(mandat, function(p) p$partikod, "")
    vkod <- vapply(valda, function(p) p$partikod, "")
    if (anyDuplicated(mkod) || anyDuplicated(vkod) ||
        any(!vkod %in% mkod)) return(empty)
    platser <- vapply(mandat, function(p) as.integer(p$antalMandat), 0L)
    if (any(platser[!mkod %in% vkod] > 0L)) return(empty)
    tomma <- integer(length(mandat))
    for (p in valda) {
      ids <- vapply(p$ledamoter, function(x) as_chr_na(x$kandidatnummer), "")
      markor <- ids == "0"
      namn_markor <- vapply(p$ledamoter, function(x) {
        identical(as_chr_na(x$namn), "Kunde inte utses")
      }, logical(1))
      if (anyNA(ids) || any(!nzchar(ids)) ||
          anyDuplicated(ids[!markor])) return(empty)
      if (any(markor != namn_markor)) {
        stop("Motstridig platsmark\u00f6r i ", niva, "/", as_chr_na(obj$kod),
             ".", call. = FALSE)
      }
      pos <- match(p$partikod, mkod)
      if (length(ids) > platser[[pos]]) {
        stop("Antal valda \u00f6verstiger partiets mandat i ", niva, "/",
             as_chr_na(obj$kod), ".", call. = FALSE)
      }
      if (length(ids) < platser[[pos]]) return(empty)
      tomma[[pos]] <- as.integer(platser[[pos]] - length(unique(ids[!markor])))
      if (tomma[[pos]] != sum(markor)) {
        stop("Platsmark\u00f6rer st\u00e4mmer inte med mandat och valda i ", niva,
             "/", as_chr_na(obj$kod), ".", call. = FALSE)
      }
    }
    tibble::tibble(
      valtyp = valtyp, geografiniva = niva,
      valomradeskod = as_chr_na(raw$valomrade$kod),
      valkretskod = valkretskod, partikod = mkod,
      antal_tomma_stolar = tomma
    )
  }
  omrade <- parse_nod(raw$valomrade, omradesniva)
  vk <- raw$valomrade$valkretsLista
  valkretsar <- purrr::map(vk, function(x) {
    parse_nod(x, valkretsniva, as_chr_na(x$kod))
  }) |> purrr::list_rbind()
  if (!nrow(omrade) && length(vk) &&
      all(vapply(vk, function(x) {
        sum(valkretsar$valkretskod == as_chr_na(x$kod)) ==
          length(x$mandatfordelning$partiLista)
      }, logical(1)))) {
    omradesmandat <- raw$valomrade$mandatfordelning$partiLista
    if (is.list(omradesmandat) && length(omradesmandat) &&
        all(vapply(omradesmandat, function(p) {
          .personrost_id(p$partikod) && .personrost_heltal(p$antalMandat)
        }, logical(1)))) {
      omradeskod <- vapply(omradesmandat, function(p) p$partikod, "")
      kretsmandat <- purrr::map(vk, function(x) {
        tibble::tibble(
          partikod = vapply(x$mandatfordelning$partiLista,
                            function(p) p$partikod, ""),
          antal_mandat = vapply(x$mandatfordelning$partiLista,
                                function(p) as.integer(p$antalMandat), 0L)
        )
      }) |> purrr::list_rbind()
      if (!anyDuplicated(omradeskod) &&
          setequal(omradeskod, unique(kretsmandat$partikod)) &&
          all(vapply(seq_along(omradeskod), function(i) {
            sum(kretsmandat$antal_mandat[kretsmandat$partikod == omradeskod[[i]]]) ==
              omradesmandat[[i]]$antalMandat
          }, logical(1)))) {
        utsedda <- lapply(omradeskod, function(id) {
          ids <- unlist(lapply(vk, function(x) {
            parti <- Filter(function(p) identical(p$partikod, id),
                            x$valda$partiLedamoterLista)
            if (!length(parti)) return(character())
            vapply(parti[[1]]$ledamoter,
                   function(person) as_chr_na(person$kandidatnummer), "")
          }), use.names = FALSE)
          ids[ids != "0"]
        })
        if (all(vapply(utsedda, function(ids) !anyDuplicated(ids), logical(1)))) {
          tomma_omrade <- vapply(seq_along(omradeskod), function(i) {
            as.integer(omradesmandat[[i]]$antalMandat - length(unique(utsedda[[i]])))
          }, 0L)
          if (all(tomma_omrade == vapply(omradeskod, function(id) {
            sum(valkretsar$antal_tomma_stolar[valkretsar$partikod == id])
          }, 0L))) {
            omrade <- tibble::tibble(
              valtyp = valtyp, geografiniva = omradesniva,
              valomradeskod = as_chr_na(raw$valomrade$kod),
              valkretskod = NA_character_, partikod = omradeskod,
              antal_tomma_stolar = tomma_omrade
            )
          }
        }
      }
    }
  }
  dplyr::bind_rows(empty, omrade, valkretsar)
}
