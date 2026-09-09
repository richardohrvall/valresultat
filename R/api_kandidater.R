#' Kandidater
#'
#' Skapar en analysvänlig kandidatfil.
#'
#' En rad motsvarar kandidatnummer × valtyp × parti. Kandidater som
#' ställer upp på flera politiska nivåer eller för flera partier kan därför
#' förekomma på flera rader.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val Valtyp: `"RD"`, `"RF"` eller `"KF"`. `NULL` ger alla.
#' @param resultat Om `TRUE`, kompletteras kandidaterna med personröster,
#'   personval och invaldsuppgifter när dessa finns i resultatfilerna.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator vid läsning av resultatfiler.
#'
#' @return En tibble med en rad per `kandidatnummer`, `valtyp` och `partikod`,
#'   byggd från giltiga kandidaturer. Namn normaliseras deterministiskt och
#'   `namn_varierar` anger om flera normaliserade namn förekommer.
#'   Med `resultat = TRUE` tillkommer resultatkolumner. `invald` och
#'   `kvalificerad_personval` är `NA` när relevant information saknas,
#'   och `FALSE` när informationen finns men kandidaten inte uppfyller villkoret.
#' @seealso [kandidaturer()], [valda()], [valresultat-package]
#' @export
kandidater <- function(
    ar = 2026,
    val = NULL,
    resultat = TRUE,
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
      "`kandidater()` st\u00f6der f\u00f6r n\u00e4rvarande endast val\u00e5ret 2026.",
      call. = FALSE
    )
  }

  kandidaturdata <- kandidaturer(
    ar = ar,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  out <- make_kandidater_2026(kandidaturdata)

  if (!is.null(val)) {
    out <- out |>
      dplyr::filter(valtyp %in% val)
  } else {
    val <- c("RD", "RF", "KF")
  }

  if (!isTRUE(resultat)) {
    return(out)
  }

  .add_kandidatresultat_2026(
    kandidater = out,
    kandidaturer = kandidaturdata,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive,
    progress = progress
  )
}


#' Valda kandidater
#'
#' Bekväm vy av `kandidater()` som endast innehåller kandidater med
#' `invald == TRUE`.
#'
#' @inheritParams kandidater
#' @return En tibble med samma kolumner som `kandidater(resultat = TRUE)`,
#'   filtrerad till kandidater med `invald == TRUE`.
#' @seealso [kandidater()], [ersattare()], [valresultat-package]
#' @export
valda <- function(
    ar = 2026,
    val = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {

  kandidater(
    ar = ar,
    val = val,
    resultat = TRUE,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive,
    progress = progress
  ) |>
    dplyr::filter(invald %in% TRUE)
}
