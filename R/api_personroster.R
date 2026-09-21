#' Personröster per personvalsområde
#'
#' Skapar en analysvänlig tabell med personröster för giltiga kandidaturer.
#'
#' En rad motsvarar valtillfälle × valtyp × personvalsområde × parti ×
#' kandidat. Personvalsområdet är den faktiska geografiska enhet där
#' personvalet avgörs: riksdagsvalkrets, region eller regionvalkrets, eller
#' kommun eller kommunvalkrets.
#'
#' Ett officiellt personröstetal i en komplett personvalslista används i
#' första hand. För övriga kandidater används distriktsvisa summerade
#' personröster endast när hela partiets underlag i personvalsområdet är
#' verifierat komplett. Verifierad frånvaro ger 0; saknat, partiellt eller
#' oklart underlag ger `NA`.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val En eller flera valtyper: `"RD"`, `"RF"` eller `"KF"`.
#'   `NULL` ger alla.
#' @param source Datakälla: `"auto"`, `"local"` eller `"remote"`.
#'   `"local"` använder aldrig nätet och får inte kombineras med `update = TRUE`.
#' @param data_dir Lokal rotmapp för rådata.
#' @param update Om `TRUE`, uppdateras lokala arbetskopior.
#' @param archive Om `TRUE`, sparas även daterade snapshots.
#' @param progress Visa progressindikator vid läsning av resultatfiler.
#'
#' @return En tibble med en rad per kandidat, parti och personvalsområde.
#'   Den unika nyckeln består av `valtillfalle`, `valtyp`, `geografiniva`,
#'   `valomradeskod`, `personvalsomradeskod`, `partikod` och
#'   `kandidatnummer`. `antal_partiroster` är partiets officiella
#'   mandatpåverkande röstetal i samma område. `andel_personroster` är den
#'   orundade proportionen `antal_personroster / antal_partiroster` på
#'   0–1-skalan. `kvalificerad_personval` är `FALSE` endast när en komplett
#'   officiell personvalslista saknar kandidaten; annars används `NA` för
#'   saknad eller oklar information.
#' @examples
#' \dontrun{
#' personroster(val = "RD", source = "local", data_dir = "mitt_arkiv")
#' }
#' @seealso [kandidater()], [kandidaturer()], [valresultat-package]
#' @export
personroster <- function(
    ar = 2026,
    val = NULL,
    source = c("auto", "local", "remote"),
    data_dir = NULL,
    update = FALSE,
    archive = FALSE,
    progress = interactive()
) {
  source <- .check_public_args(
    ar, "personroster", source, data_dir, update, archive, progress
  )
  val <- .valtyper(val)
  kandidaturdata <- kandidaturer(
    ar = ar,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )
  kandidater_data <- make_kandidater_2026(kandidaturdata)
  if (is.null(val)) val <- c("RD", "RF", "KF")

  .las_kandidatresultat_filer_2026(
    kandidaturer = kandidaturdata,
    kandidater = kandidater_data,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive,
    progress = progress
  ) |>
    purrr::map("personrostomraden") |>
    purrr::list_rbind() |>
    dplyr::arrange(
      valtyp, valomradeskod, personvalsomradeskod, partikod, kandidatnummer
    )
}
