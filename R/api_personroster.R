#' Personröster per personvalsområde eller valdistrikt
#'
#' Skapar en analysvänlig tabell med personröster för giltiga kandidaturer.
#'
#' En rad motsvarar valtillfälle × valtyp × personvalsområde × parti ×
#' kandidat. Personvalsområdet är den faktiska geografiska enhet där
#' personvalet avgörs: riksdagsvalkrets, region eller regionvalkrets, eller
#' kommun eller kommunvalkrets.
#'
#' Ett officiellt personröstetal i en komplett personvalslista används i
#' första hand. Därefter används observerade områdessummeringar eller
#' avstämda list- och distriktsresultat. Frånvaro ger 0 först när hela
#' personvalsområdets relevanta röstmaterial är färdigräknat och avstämt.
#' `NA` betyder att källmaterialet inte räcker för att fastställa värdet,
#' inte enbart att kandidaten saknas i en gles personröstarray.
#'
#' `niva` väljer personvalsområde eller valdistrikt och `per_lista` avgör om
#' listdimensionen behålls. På distriktsnivå och i listvyerna är tabellen
#' gles som standard: endast observerade personröstrader ingår. En saknad rad
#' betyder inte automatiskt noll röster. Med `komplettera_nollor = TRUE` läggs
#' kandidatkombinationer med verifierat nollresultat till. Det etablerade
#' standardanropet på personvalsområdesnivå utan lista har redan sin fulla
#' kandidatpopulation; där är resultatet identiskt för båda värdena på
#' `komplettera_nollor`.
#'
#' På distriktsnivå kräver en kompletterad nolla en giltig kandidatur på en
#' lista som faktiskt observerats i distriktet och ett komplett validerat
#' personröstunderlag. En saknad listnod ger aldrig en nolla. De kompletterade
#' tabellerna kan vara stora: slutlig RD 2026 ger cirka 3,84 miljoner rader
#' utan lista och 4,18 miljoner med lista. Råa listsummeringar valideras
#' innan ogiltiga kandidaturer filtreras bort.
#'
#' `per_lista = TRUE` visar från vilken lista kandidatens personröster kom.
#' `*-90000` är en kandidatfri partiröstkategori och korsas inte med
#' kandidaturer. En saknad listnod kan ge 0 liströster i ett fullständigt
#' avstämt slutresultat, men ger inte 0 under pågående räkning. Om
#' personröstunderlaget är ofullständigt används `NA`, inte en gissad nolla.
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
#' @param niva `"personvalsomrade"` (standard) eller `"valdistrikt"`.
#' @param per_lista Om `TRUE`, behåll listdimensionen. Standard är `FALSE`.
#' @param komplettera_nollor Om `TRUE`, komplettera glesa distrikts- och
#'   listvyer med verifierade nollrader. För standardvyn på personvalsområdesnivå
#'   utan lista ändras inte resultatet. Standard är `FALSE`.
#'
#' @return En tibble med en rad per giltig kandidat, parti och
#'   personvalsområde som standard. Nyckeln innehåller `valtillfalle`,
#'   `valtyp`, `valomradeskod`, `personvalsomradeskod`, `partikod` och
#'   `kandidatnummer`, samt `valdistriktskod` och `valdistriktstyp` på
#'   distriktsnivå och `listnummer` när `per_lista = TRUE`.
#'   `antal_partiroster` är partiets officiella
#'   mandatpåverkande röstetal i samma område. `andel_personroster` är den
#'   orundade proportionen `antal_personroster / antal_partiroster` på
#'   0–1-skalan. `kvalificerad_personval` är `FALSE` endast när en komplett
#'   officiell personvalslista saknar kandidaten; annars används `NA` för
#'   saknad eller oklar information.
#'   För KF är `valomradesnamn` ett kort kommunnamn. I en odelad kommun är
#'   även `personvalsomradesnamn` samma kortnamn; i en valkretsindelad kommun
#'   identifierar det i stället kommunvalkretsen.
#'   På distriktsnivå tillkommer distrikts-, kommun- och länsgeografi.
#'   När `per_lista = TRUE` tillkommer `listnummer` (kort format från
#'   kandidaturfilen), `antal_listroster` och `andel_personroster_lista`.
#'   De två andelarna är orundade proportioner på 0–1-skalan: kandidatens
#'   personröster dividerade med partiets respektive listans röster på samma
#'   geografiska nivå. En okänd eller nollstor nämnare ger `NA_real_`.
#'   `kvalificerad_personval` avser alltid det överordnade personvalsområdet.
#'   En explicit källnolla bevaras även i en gles vy. En kompletterad nolla
#'   kräver komplett listunderlag eller ett fullständigt avstämt slutresultat.
#'   Partiellt eller oklart underlag ger `NA` när raden i övrigt finns;
#'   oobserverade resultat har ingen rad i en gles vy.
#' @examples
#' \dontrun{
#' personroster(val = "RD", source = "local", data_dir = "mitt_arkiv")
#' personroster(val = "RD", per_lista = TRUE) |>
#'   dplyr::select(kandidatnummer, listnummer, antal_personroster)
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
    progress = interactive(),
    niva = "personvalsomrade",
    per_lista = FALSE,
    komplettera_nollor = FALSE
) {
  source <- .check_public_args(
    ar, "personroster", source, data_dir, update, archive, progress
  )
  val <- .valtyper(val)
  .check_text(niva, "niva")
  if (length(niva) != 1L || !niva %in% c("personvalsomrade", "valdistrikt")) {
    stop("`niva` ska vara `personvalsomrade` eller `valdistrikt`.", call. = FALSE)
  }
  if (!is.logical(per_lista) || length(per_lista) != 1L || is.na(per_lista)) {
    stop("`per_lista` ska vara TRUE eller FALSE.", call. = FALSE)
  }
  if (!is.logical(komplettera_nollor) || length(komplettera_nollor) != 1L ||
      is.na(komplettera_nollor)) {
    stop("`komplettera_nollor` ska vara TRUE eller FALSE.", call. = FALSE)
  }
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

  parsed <- .las_kandidatresultat_filer_2026(
    kandidaturer = kandidaturdata,
    kandidater = kandidater_data,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive,
    progress = progress,
    personroster_niva = niva,
    personroster_per_lista = per_lista,
    personroster_komplettera_nollor = komplettera_nollor
  )
  kolumn <- if (niva == "personvalsomrade" && !per_lista) {
    "personrostomraden"
  } else {
    "personroster_utokad"
  }
  parsed |>
    purrr::map(kolumn) |>
    purrr::list_rbind() |>
    dplyr::arrange(
      valtyp, valomradeskod, personvalsomradeskod, partikod, kandidatnummer,
      dplyr::across(dplyr::any_of(c("valdistriktskod", "listnummer")))
    )
}
