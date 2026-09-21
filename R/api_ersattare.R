#' Ersättare
#'
#' Hämtar relationer mellan valda ledamöter och deras ersättare från
#' den slutliga mandatfördelningen.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val En eller flera valtyper: `"RD"`, `"RF"` eller `"KF"`.
#'   `NULL` ger alla.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator.
#'
#' @return En tibble där en rad är relationen mellan en vald ledamot och en
#'   ersättare inom val, område/valkrets, parti och ersättargrupp.
#'   `ledamot_kandidatnummer`, `ersattare_kandidatnummer` och
#'   `ersattarordning` identifierar relationen. Ordning är integer; koder och
#'   namn är character. Parti- och relationsfält ligger före geografi och
#'   teknisk valmetadata. Ett känt tomt resultat behåller samma typade schema.
#' @examples
#' \dontrun{ersattare(val = "RD", source = "local", data_dir = "mitt_arkiv")}
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

  source <- .check_public_args(
    ar, "ersattare", source, data_dir, update, archive, progress
  )
  val <- .valtyper(val)

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
    purrr::list_rbind() |>
    dplyr::select(dplyr::all_of(c(
      "valtillfalle",
      "valtyp",
      "partikod",
      "partiforkortning",
      "partibeteckning",
      "partifarg",
      "ledamot_kandidatnummer",
      "ledamot_namn",
      "ersattare_kandidatnummer",
      "ersattare_namn",
      "ersattarordning",
      "ersattargrupp",
      "valgrund_id",
      "valgrund_text",
      "geografiniva",
      "valomradeskod",
      "valomradesnamn",
      "valkretskod",
      "valkretsnamn",
      "valklass",
      "rakningstillfalle",
      "valdatum",
      "valdatum_fg",
      "test"
    )))
}
