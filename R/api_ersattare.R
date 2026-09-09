#' Ersättare
#'
#' Hämtar relationer mellan valda ledamöter och deras ersättare från
#' den slutliga mandatfördelningen.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val Valtyp: `"RD"`, `"RF"` eller `"KF"`. `NULL` ger alla.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator.
#'
#' @return En tibble med relationer mellan valda ledamöter och ersättare,
#'   inklusive ersättarordning, ersättargrupp och valgrund.
#' @seealso [valda()], [mandat()], [valresultat-package]
#' @export
ersattare <- function(
    ar = 2026,
    val = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {

  source <- match.arg(source)
  .check_source_update(source, update)
  val <- .valtyper(val)

  if (!identical(as.integer(ar), 2026L)) {
    stop(
      "`ersattare()` st\u00f6der f\u00f6r n\u00e4rvarande endast val\u00e5ret 2026.",
      call. = FALSE
    )
  }

  if (is.null(val)) {
    val <- c("RD", "RF", "KF")
  }

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

  parsed <- purrr::map(
    paths$path,
    \(path) {

      file <- .resultat_file_2026(
        path = path,
        source = source,
        data_dir = data_dir,
        update = update,
        archive = archive
      )

      raw <- read_raw_json_zip_2026(
        file,
        type = "mandatfordelning"
      )

      parse_valda_ersattare_2026(raw)$ersattare
    },
    .progress = progress
  )

  parsed |>
    purrr::list_rbind()
}
