#' Kandidater
#'
#' Skapar en analysvänlig kandidatfil.
#'
#' En rad motsvarar kandidatnummer × valtyp × parti. Kandidater som
#' ställer upp på flera politiska nivåer eller för flera partier kan därför
#' förekomma på flera rader.
#'
#' `antal_personroster_totalt` är känt endast när varje relevant
#' personvalsområde från kandidatens giltiga kandidaturer har ett känt värde.
#' Ett officiellt personröstetal i en komplett personvalslista används i första
#' hand. I övrigt krävs verifierat komplett distriktsunderlag för partiet.
#' Saknas kandidaten i ett sådant komplett underlag blir områdesvärdet 0.
#' Saknat, partiellt eller motsägelsefullt underlag i något annat relevant
#' område gör totalen `NA`. Personvalskvalificering bedöms separat.
#' En saknad summeringsnod räknas som verifierad noll endast när varje relevant
#' lista uttryckligen har noll personröster och en tom personröstarray.
#'
#' @param ar Valår. För närvarande stöds 2026.
#' @param val En eller flera valtyper: `"RD"`, `"RF"` eller `"KF"`.
#'   `NULL` ger alla.
#' @param resultat Om `TRUE`, kompletteras kandidaterna med personröster,
#'   personval och invaldsuppgifter från slutliga resultatfiler.
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
#'   Samma regel gäller `invald`. `antal_personroster_totalt` summerar de
#'   områdesspecifika värden som även ligger till grund för [personroster()].
#'   Totalen är 0 endast när samtliga relevanta områden är verifierade nollor;
#'   ett okänt område ger `NA`. Antalsfält är integer och indikatorer logical.
#'   Kandidatidentitet och parti följs av personröst-, personvals- och
#'   invaldsfält; tekniska kandidatursammanfattningar ligger sist.
#'   För KF är `valomradesnamn` paketets korta kommunnamn när kandidaten har
#'   ett entydigt valområde. Vid flera valområden är både `valomradeskod` och
#'   `valomradesnamn` `NA`, medan `antal_valomraden` och `flera_valomraden`
#'   visar varför. `invald_valomradeskod` och `invald_valomradesnamn` beskriver
#'   det faktiska invaldsområdet oberoende av kandidaturernas antal; även där
#'   används kort kommunnamn för KF. `folkbokforingskommun` ändras inte.
#' @examples
#' \dontrun{kandidater(val = "RD", source = "local", data_dir = "mitt_arkiv")}
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

  source <- .check_public_args(
    ar, "kandidater", source, data_dir, update, archive, progress
  )
  val <- .valtyper(val)
  .check_flag(resultat, "resultat")

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
#'   och samma observationsnivå kandidatnummer × valtyp × partikod, filtrerad
#'   till explicit `invald == TRUE`. Kandidater med okänd status ingår inte.
#' @examples
#' \dontrun{valda(val = "RD", source = "local", data_dir = "mitt_arkiv")}
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
