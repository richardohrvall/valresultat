#' Kandidaturer
#'
#' Hämtar kandidaturdata från Valmyndigheten.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val En eller flera valtyper: `"RD"`, `"RF"` eller `"KF"`.
#'   `NULL` ger alla.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#'   Lokal arkivering kräver en redan befintlig lokal fil.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras den lokala arbetskopian.
#' @param archive Om `TRUE`, sparas även en daterad snapshot.
#'
#' @return En tibble där en rad är en källrad för en kandidatur på en
#'   valsedel/lista i ett valområde och eventuell valkrets. En kandidat kan
#'   ha flera rader och ogiltiga kandidaturer bevaras. Identitetsfält omfattar
#'   valtyp, område, valkrets, parti, listnummer, ordning och kandidatnummer.
#'   Källans namn bevaras i `namn` och `giltig` är logical.
#'   För KF är valområdet kommunen och `valomradesnamn` är paketets korta
#'   kommunnamn, uppslaget exakt via `valomradeskod`.
#' @examples
#' \dontrun{kandidaturer(val = "RD", source = "local", data_dir = "mitt_arkiv")}
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

  source <- .check_public_args(ar, "kandidaturer", source, data_dir, update, archive)
  val <- .valtyper(val)

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

  .kort_kommunnamn_2026(out)
}


.valtyper <- function(val = NULL) {

  if (is.null(val)) {
    return(NULL)
  }

  .check_text(val, "val", flera = TRUE)
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
