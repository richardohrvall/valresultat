#' Kandidater
#'
#' Skapar en analysvänlig kandidatfil.
#'
#' En rad motsvarar kandidatnummer × valtyp × parti. Kandidater som
#' ställer upp på flera politiska nivåer eller för flera partier kan därför
#' förekomma på flera rader.
#'
#' `oppen_lista` sammanfattar kandidatens giltiga kandidaturer och är känd
#' endast när alla ger samma status. `pa_namnvalsedel` är `TRUE` om minst en
#' giltig kandidatur stod på en tryckt namnvalsedel; om ingen gjorde det är
#' värdet `FALSE` bara när alla berörda kandidaturer har verifierad negativ
#' status. En äldre eller okänd kandidatfil kan därför ge `NA`.
#'
#' `antal_personroster_totalt` är känt endast när varje relevant
#' personvalsområde har ett känt värde. För 2026 används i första hand
#' officiella personvalstal, därefter verifierat komplett områdesmaterial.
#' För 2022 används de officiella slutliga områdeslistornas personröster;
#' varje lista avstäms mot sina personröster och partiets röster. Röster från
#' flera resultatlistor summeras en gång per kandidat och område, oavsett om
#' listan motsvarar en tryckt namnvalsedel. `90000` är partiröster och ger inga
#' ytterligare redovisade kandidatpersonröster. Om en komplett områdesstruktur
#' saknar en partirad är kandidatens redovisade personröster där 0; ett område
#' vars resultatstruktur inte kan verifieras ger `NA`.
#' Personvalskvalificering bedöms separat.
#'
#' @param ar Ett eller flera exakta valår (2022, 2026), eller `"alla"`.
#'   Dubbletter tas bort med den första årsordningen bevarad. Standard är 2026.
#' @param fran,till Inklusiva årsgränser bland stödda år, som alternativ till
#'   `ar`. En utelämnad gräns är öppen.
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
#'   `valar` är en heltalskolumn direkt efter `valtillfalle`; flera år staplas.
#'   `oppen_lista` är kandidatens entydiga status över giltiga kandidaturer.
#'   `pa_namnvalsedel` anger om kandidaten stod på minst en tryckt
#'   namnvalsedel, till skillnad från [kandidaturer()] där fältet avser
#'   den enskilda kandidaturen. Blandade eller okända underlag kan ge `NA`.
#'   Med `resultat = TRUE` tillkommer resultatkolumner. `invald` och
#'   `kvalificerad_personval` är `NA` när relevant information saknas,
#'   och `FALSE` när informationen finns men kandidaten inte uppfyller villkoret.
#'   `antal_personroster_totalt` summerar verifierade områdesvärden; för 2026
#'   är det samma områdesvärden som ligger till grund för [personroster()].
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
#' \dontrun{
#' kandidater(val = "RD", source = "local", data_dir = "mitt_arkiv")
#' kandidater(ar = c(2022, 2026), val = "RD")
#' }
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
    progress = interactive(),
    fran = NULL,
    till = NULL
) {
  ar_angivet <- !missing(ar)
  val <- .valtyper(val)
  valar <- .resolve_valar(ar, fran, till, "kandidater",
                         if (is.null(val)) "RD" else val[[1]], ar_angivet)
  source <- .check_public_args(
    valar[[1]], "kandidater", source, data_dir, update, archive, progress,
    valar_resolved = TRUE
  )
  .check_flag(resultat, "resultat")

  purrr::map(valar, function(ett_ar) {
    tryCatch(
      .kandidater_ett_ar(ett_ar, val, resultat, source, data_dir, update,
                         archive, progress),
      error = function(e) stop("Val\u00e5r ", ett_ar, ": ", conditionMessage(e),
                               call. = FALSE)
    )
  }) |> purrr::list_rbind()
}

.kandidater_ett_ar <- function(ar, val, resultat, source, data_dir, update,
                               archive, progress) {
  kandidaturdata <- kandidaturer(
    ar = ar,
    val = val,
    source = source,
    data_dir = data_dir,
    update = update,
    archive = archive
  )

  out <- make_kandidater_2026(kandidaturdata) |>
    dplyr::mutate(valar = as.integer(ar), .after = valtillfalle)
  status <- .kandidatstatus(kandidaturdata)
  out <- dplyr::left_join(
    out, status,
    by = dplyr::join_by(kandidatnummer, valtyp, partikod),
    relationship = "one-to-one"
  )

  if (!is.null(val)) {
    out <- out |>
      dplyr::filter(valtyp %in% val)
  } else {
    val <- c("RD", "RF", "KF")
  }

  if (!isTRUE(resultat)) {
    return(out)
  }

  add_resultat <- if (ar == 2022L) .add_kandidatresultat_2022 else
    .add_kandidatresultat_2026
  add_resultat(
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

.kandidatstatus <- function(kandidaturdata) {
  kandidaturdata |>
    dplyr::filter(giltig %in% TRUE) |>
    dplyr::summarise(
      oppen_lista = .enhetlig_status(
        dplyr::pick(dplyr::all_of("oppen_lista"))[[1]]),
      pa_namnvalsedel = .existentiell_status(
        dplyr::pick(dplyr::all_of("pa_namnvalsedel"))[[1]]),
      .by = c(kandidatnummer, valtyp, partikod)
    )
}

.enhetlig_status <- function(x) {
  if (all(x %in% TRUE)) return(TRUE)
  if (all(x %in% FALSE)) return(FALSE)
  NA
}

.existentiell_status <- function(x) {
  if (any(x %in% TRUE)) return(TRUE)
  if (all(x %in% FALSE)) return(FALSE)
  NA
}


#' Valda kandidater
#'
#' Bekväm vy av `kandidater()` som endast innehåller kandidater med
#' `invald == TRUE`.
#'
#' @inheritParams ersattare
#' @param progress Visa progressindikator vid läsning av resultatfiler.
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

  source <- .check_public_args(
    ar, "valda", source, data_dir, update, archive, progress
  )

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
