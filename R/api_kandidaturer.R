#' Kandidaturer
#'
#' Hämtar kandidaturdata från Valmyndigheten.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val Valtyp: `"RD"`, `"RF"` eller `"KF"`. `NULL` ger alla.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras den lokala arbetskopian.
#' @param archive Om `TRUE`, sparas även en daterad snapshot.
#'
#' @return En tibble med källnära kandidaturer, inklusive ogiltiga
#'   kandidaturer. Källans namn bevaras i `namn` och `giltig` anger giltighet.
#' @seealso [kandidater()], [valresultat-package]
#' @export
kandidaturer <- function(
    ar = 2026,
    val = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE
) {

  source <- match.arg(source)
  .check_source_update(source, update)
  val <- .valtyper(val)

  if (!identical(as.integer(ar), 2026L)) {
    stop(
      "`kandidaturer()` st\u00f6der f\u00f6r n\u00e4rvarande endast val\u00e5ret 2026.",
      call. = FALSE
    )
  }

  path <- "parti/kandidaturer.csv"
  samling <- "val2026"
  base_url <- "https://data.val.se/filer/val2026"

  file <- .resolve_val_file(
    path = path, ar = ar, samling = samling, source = source,
    data_dir = data_dir, base_url = base_url, update = update, archive = archive
  )

  out <- read_kandidaturer_2026(file)

  if (!is.null(val)) {
    out <- out |>
      dplyr::filter(valtyp %in% val)
  }

  out
}


.valtyper <- function(val = NULL) {

  if (is.null(val)) {
    return(NULL)
  }

  val <- toupper(val)

  allowed <- c("RD", "RF", "KF")
  invalid <- setdiff(val, allowed)

  if (length(invalid) > 0) {
    stop(
      "Ok\u00e4nd valtyp: ",
      paste(invalid, collapse = ", "),
      ". Till\u00e5tna v\u00e4rden \u00e4r RD, RF och KF.",
      call. = FALSE
    )
  }

  unique(val)
}
