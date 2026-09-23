# 2022 saknar antalTommaStolar. En härledning kräver mandat och valda i
# samma fullständigt räknade resultatnod. Valområden utan egen valda-nod
# får därför NA även när valkretsarna har valda.
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
    utsedda <- integer(length(mandat))
    for (p in valda) {
      ids <- vapply(p$ledamoter, function(x) as_chr_na(x$kandidatnummer), "")
      if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids)) return(empty)
      utsedda[[match(p$partikod, mkod)]] <- length(ids)
    }
    tomma <- platser - utsedda
    if (any(tomma < 0L)) {
      stop("Antal valda \u00f6verstiger partiets mandat i ", niva, "/",
           as_chr_na(obj$kod), ".", call. = FALSE)
    }
    tibble::tibble(
      valtyp = valtyp, geografiniva = niva,
      valomradeskod = as_chr_na(raw$valomrade$kod),
      valkretskod = valkretskod, partikod = mkod,
      antal_tomma_stolar = as.integer(tomma)
    )
  }
  omrade <- parse_nod(raw$valomrade, omradesniva)
  valkretsar <- purrr::map(raw$valomrade$valkretsLista, function(vk) {
    parse_nod(vk, valkretsniva, as_chr_na(vk$kod))
  }) |> purrr::list_rbind()
  dplyr::bind_rows(empty, omrade, valkretsar)
}
