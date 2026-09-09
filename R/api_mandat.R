#' Mandat
#'
#' Hämtar mandatfördelningen.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val Valtyp: `"RD"`, `"RF"` eller `"KF"`. `NULL` ger alla.
#' @param rakning `"slutlig"` eller `"preliminar"`.
#' @param niva Geografisk nivå: `"riket"`, `"riksdagsvalkrets"`, `"region"`,
#'   `"regionvalkrets"`, `"kommun"` eller `"kommunvalkrets"`.
#'   `NULL` ger alla relevanta nivåer. Resultatet filtreras till valda nivåer.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator.
#'
#' @return En tibble med mandat per parti och geografiskt område, inklusive
#'   `geografiniva`, `rakningstillfalle` och `antal_tomma_stolar`.
#' @seealso [valda()], [ersattare()], [valresultat-package]
#' @export
mandat <- function(
    ar = 2026,
    val = NULL,
    rakning = c("slutlig", "preliminar"),
    niva = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {

  source <- match.arg(source)
  .check_source_update(source, update)
  rakning <- match.arg(rakning)
  val <- .valtyper(val)

  if (!identical(as.integer(ar), 2026L)) {
    stop(
      "`mandat()` st\u00f6der f\u00f6r n\u00e4rvarande endast val\u00e5ret 2026.",
      call. = FALSE
    )
  }

  if (is.null(val)) {
    val <- c("RD", "RF", "KF")
  }

  allowed_niva <- c(
    "riket",
    "riksdagsvalkrets",
    "region",
    "regionvalkrets",
    "kommun",
    "kommunvalkrets"
  )

  if (!is.null(niva)) {
    invalid_niva <- setdiff(niva, allowed_niva)

    if (length(invalid_niva) > 0) {
      stop(
        "Ok\u00e4nd geografisk niv\u00e5: ",
        paste(invalid_niva, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
  }

  index <- .read_resultatindex_2026(
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  prefix <- dplyr::recode_values(
    rakning,
    "slutlig" ~ "s",
    "preliminar" ~ "p"
  )

  paths <- purrr::map_dfr(
    val,
    \(valtyp) {

      pattern <- dplyr::recode_values(
        valtyp,
        "RD" ~ paste0("^", prefix, "/rd/.*_00_RD\\.zip$"),
        "RF" ~ paste0("^", prefix, "/rf/.*_[0-9]{2}_RF\\.zip$"),
        "KF" ~ paste0("^", prefix, "/kf/.*_[0-9]{4}_KF\\.zip$")
      )

      index |>
        dplyr::filter(stringr::str_detect(path, pattern)) |>
        dplyr::transmute(
          valtyp = valtyp,
          path
        )
    }
  )

  if (nrow(paths) == 0) {
    stop(
      "Hittade inga mandatfiler f\u00f6r vald kombination av val och r\u00e4kning.",
      call. = FALSE
    )
  }

  parsed <- purrr::map(
    paths$path,
    \(path) {

      file <- .resultat_file_2026(
        path = path, source = source, data_dir = data_dir,
        update = update, archive = archive
      )

      raw <- read_raw_json_zip_2026(
        file,
        type = "mandatfordelning"
      )

      mandat_data <- parse_mandat_2026(raw)

      tomma_stolar <- parse_tomma_stolar_2026(raw)

      if (nrow(tomma_stolar) > 0) {
        mandat_data <- mandat_data |>
          dplyr::left_join(
            tomma_stolar,
            by = dplyr::join_by(
              valtyp,
              geografiniva,
              valomradeskod,
              valkretskod,
              partikod
            )
          )
      } else {
        mandat_data <- mandat_data |>
          dplyr::mutate(
            antal_tomma_stolar = NA_integer_
          )
      }

      mandat_data
    },
    .progress = progress
  ) |>
    purrr::list_rbind()

  if (!is.null(niva)) {
    parsed <- parsed |>
      dplyr::filter(geografiniva %in% niva)
  }

  parsed
}
