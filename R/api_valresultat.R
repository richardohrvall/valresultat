#' Officiella valresultat för 2026
#'
#' Läser en valtyp, en räkning och en geografisk nivå från Valmyndighetens
#' officiella primärkälla. Ingen geografisk aggregering eller automatisk
#' reservkälla används om den valda källan saknas.
#'
#' @param ar Valår. Endast 2026 stöds.
#' @param val Exakt en valtyp: `"RD"`, `"RF"` eller `"KF"`. Inte `NULL`.
#' @param rakning Exakt en räkning: `"slutlig"` (default) eller `"preliminar"`.
#' @param niva En geografisk nivå. `NULL` ger valets huvudnivå: RD `"riket"`,
#'   RF `"region"`, KF `"kommun"`. Se nivåerna nedan.
#' @inheritParams mandat
#'
#' @details
#' RD stöder valdistrikt, kommun, kommunvalkrets, riksdagsvalkrets och riket.
#' RF stöder valdistrikt, kommun, kommunvalkrets, region, regionvalkrets och
#' riket. KF stöder valdistrikt, kommun, kommunvalkrets, lan och riket.
#' RD/lan stöds inte. RF/lan är dokumenterat i OS-formatet men ännu inte
#' aktiverat, eftersom faktisk slutlig källa inte är verifierad.
#'
#' Distriktsresultat läses ur individuell röstfördelning. RD/RF:s kommuner
#' och kommunvalkretsar läses ur underordnad summering. Valområden och deras
#' mandatvalkretsar läses ur mandatfilens röstfördelning. RF/KF:s riksresultat
#' och KF:s länsresultat läses ur överordnad summering (OS), om filen finns
#' i valt index. Räkningstillfället bevaras i `rakningstillfalle`.
#'
#' En rad avser val, geografiskt område och parti/kategori. Områdestotaler
#' upprepas på partiraderna och ska inte summeras över partier. Samtliga
#' källor ger samma 83 kolumner. Datum, tidsstämplar och geografiska koder
#' är character, antal integer, andelar double i procent och indikatorer
#' logical. Saknade eller ej tillämpliga fält är typade `NA`.
#' Historik och differenser bevaras endast där källan publicerar dem.
#'
#' `antal_valdistrikt_raknade` och `antal_valdistrikt_som_ska_raknas` avser
#' filpopulationen; motsvarigheterna med suffix `_omrade` avser radens område
#' och är `NA` för valdistrikt. Distriktens `valdel` kommer från
#' `valdeltagandeVallokal`, övriga nivåers från `valdeltagande`.
#' `over_sparr` fylls bara från ett uttryckligt relevant besked i mandatkällan.
#' Övriga partier får en rad endast om källnoden finns; explicit noll behålls.
#' Verifierat tom valkretsindelning ger en typad tom tabell, medan saknad
#' röstfördelning för ett existerande område ger fel.
#'
#' `data_dir` går före optionen `valresultat.data_dir`. Resultatsamlingen
#' väljs med optionen `valresultat.resultatsamling_2026` (default `"val2026"`).
#' Test-/utvecklingssamlingen `"genrep2026"` kan väljas uttryckligen.
#' `source = "local"` använder aldrig nätet. Lokal arkivering kopierar endast
#' befintliga filer; en snapshot från samma datum får ersättas.
#' @return En tibble med 83 kolumner, en geografisk nivå och unika
#'   val-/områdes-/partinycklar. Inga mandat eller personröster ingår.
#' @seealso [mandat()], [valresultat-package]
#' @examples
#' \dontrun{
#' valresultat(val = "RD", source = "local", data_dir = "mitt_arkiv")
#' valresultat(val = "KF", niva = "kommun", rakning = "preliminar")
#' }
#' @export
valresultat <- function(
    ar = 2026, val = "RD", rakning = c("slutlig", "preliminar"),
    niva = NULL, source = c("auto", "local", "remote"), data_dir = NULL,
    update = FALSE, archive = FALSE, progress = interactive()
) {
  .check_ar_2026(ar, "valresultat")
  .check_text(val, "val")
  val <- toupper(val)
  if (!val %in% c("RD", "RF", "KF")) stop("Ok\u00e4nd valtyp.", call. = FALSE)
  if (missing(rakning)) rakning <- "slutlig"
  .check_text(rakning, "rakning")
  if (!rakning %in% c("slutlig", "preliminar")) {
    stop("Ok\u00e4nd rakning; ange slutlig eller preliminar.", call. = FALSE)
  }
  if (is.null(niva)) niva <- c(RD = "riket", RF = "region", KF = "kommun")[[val]]
  .check_text(niva, "niva")
  kalla <- .valresultat_kalla(val, niva)
  source <- .check_public_args(
    ar, "valresultat", source, data_dir, update, archive, progress
  )
  index <- .read_resultatindex_2026(source, data_dir, update, archive)
  paths <- .valresultat_paths(index, val, rakning, kalla)
  resultat <- purrr::map(paths, function(path) {
    tryCatch({
      file <- .resultat_file_2026(path, source, data_dir, update, archive)
      raw <- .read_valresultat_raw(file, kalla, val, rakning)
      .parse_valresultat(raw, kalla, val, niva, rakning, path)
    }, error = function(e) {
      stop(path, ": ", conditionMessage(e), call. = FALSE)
    })
  }, .progress = progress) |>
    purrr::list_rbind()
  .valresultat_check_key(resultat, niva)
  identitet <- c("valtillfalle", "valtyp", "rakningstillfalle", "geografiniva")
  if (nrow(unique(resultat[identitet])) > 1L) {
    stop("Filerna avser olika val eller r\u00e4kningar.", call. = FALSE)
  }
  nyckel <- c(.valresultat_geo_key(niva), "ovriga_partier", "partikod")
  dplyr::arrange(resultat, dplyr::across(dplyr::all_of(nyckel)))
}

.valresultat_scalar <- function(x, namn) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`", namn, "` ska vara exakt ett icke-tomt textv\u00e4rde, inte NULL/NA.", call. = FALSE)
  }
}

.valresultat_kalla <- function(val, niva) {
  # RF/lan har en beslutad filklass men en separat aktiveringskontroll.
  matris <- list(
    RD = c(valdistrikt = "D", kommun = "U", kommunvalkrets = "U",
           riksdagsvalkrets = "M", riket = "M"),
    RF = c(valdistrikt = "D", kommun = "U", kommunvalkrets = "U",
           region = "M", regionvalkrets = "M", riket = "O", lan = "O"),
    KF = c(valdistrikt = "D", kommun = "M", kommunvalkrets = "M",
           lan = "O", riket = "O")
  )
  if (niva == "lan" && val == "RD") {
    stop("RD/lan st\u00f6ds inte i v1: officiell l\u00e4nssummering saknas.", call. = FALSE)
  }
  if (niva == "lan" && val == "RF") {
    stop("RF/lan finns i OS-formatet men \u00e4r inte aktiverat i v1: slutlig k\u00e4lla ",
         "\u00e4r inte verifierad. Anv\u00e4nd region.", call. = FALSE)
  }
  kalla <- unname(matris[[val]][niva])
  if (is.na(kalla)) {
    stop("Niv\u00e5n ", niva, " st\u00f6ds inte f\u00f6r ", val, ".",
         if (niva == "region") " Administrativ indelning ben\u00e4mns lan.", call. = FALSE)
  }
  kalla
}

.valresultat_paths <- function(index, val, rakning, kalla) {
  prefix <- if (rakning == "slutlig") "s" else "p"
  kod <- if (kalla == "O") "OS" else switch(val, RD = "00", RF = "[0-9]{2}", KF = "[0-9]{4}")
  pattern <- paste0("^", prefix, "/", tolower(val), "/[^/]+_", rakning, "_", kod, "_", val, "\\.zip$")
  paths <- sort(index$path[!is.na(index$path) & grepl(pattern, index$path)])
  if (!length(paths)) {
    stop("Saknad prim\u00e4rk\u00e4lla ", kalla, " f\u00f6r ", val, "/", rakning, ".", call. = FALSE)
  }
  koder <- sub(".*_([^_]+)_[A-Z]{2}\\.zip$", "\\1", paths)
  if (anyDuplicated(koder)) stop("Dubbla filer f\u00f6r samma filidentitet.", call. = FALSE)
  paths
}

.read_valresultat_raw <- function(file, kalla, val, rakning) {
  if (grepl("^https?://", file)) {
    lokal <- tempfile(fileext = ".zip")
    on.exit(unlink(lokal), add = TRUE)
    utils::download.file(file, lokal, mode = "wb", quiet = TRUE)
    file <- lokal
  }
  filer <- utils::unzip(file, list = TRUE)$Name
  typ <- switch(kalla, D = "rostfordelning", M = "mandatfordelning", U = "summering", O = "summering")
  # Kräv rätt typsegment, val och räkning samt exakt en träff.
  # Rotstrukturen verifieras dessutom före parsning, särskilt för OS.
  if (kalla == "O") typ <- "(?:overordnad_)?summering"
  pattern <- paste0("(^|/)[^/]+_", rakning, "_", typ,
                    "(?:_[^/]+)?_", val, "\\.json$")
  poster <- filer[grepl(pattern, filer, perl = TRUE)]
  if (length(poster) != 1L) {
    stop("F\u00f6rv\u00e4ntade exakt en JSON-fil f\u00f6r ", kalla, "/", val, "/", rakning,
         "; hittade ", length(poster), ".", call. = FALSE)
  }
  con <- unz(file, poster, open = "r", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  jsonlite::fromJSON(paste(readLines(con, warn = FALSE), collapse = "\n"), simplifyVector = FALSE)
}
