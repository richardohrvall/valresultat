.komplettera_kommunnamn_2026 <- function(
    data,
    kommunnamn_officiellt = rep(NA_character_, nrow(data))
) {
  if (!"kommunkod" %in% names(data)) {
    stop("Internt kommunnamnsuppslag saknar `kommunkod`.", call. = FALSE)
  }
  if (!is.character(data$kommunkod) ||
      !is.character(kommunnamn_officiellt) ||
      length(kommunnamn_officiellt) != nrow(data)) {
    stop("Internt kommunnamnsuppslag har ogiltiga typer.", call. = FALSE)
  }
  if (nrow(kommunnamn_2026) != 290L ||
      anyNA(kommunnamn_2026) ||
      anyDuplicated(kommunnamn_2026$kommunkod)) {
    stop("Den interna kommunnamnslookupen \u00e4r ogiltig.", call. = FALSE)
  }

  index <- match(data$kommunkod, kommunnamn_2026$kommunkod)
  data$kommunnamn <- kommunnamn_2026$kommunnamn[index]
  data$kommunnamn_officiellt <- kommunnamn_officiellt
  data
}

.kort_kommunnamn_2026 <- function(
    data,
    kodkolumn = "valomradeskod",
    namnkolumn = "valomradesnamn",
    rader = NULL
) {
  required <- c("valtyp", kodkolumn, namnkolumn)
  if (!all(required %in% names(data))) {
    stop("Internt kommunuppslag saknar valomr\u00e5deskolumner.", call. = FALSE)
  }
  if (!is.character(data[[kodkolumn]]) || !is.character(data[[namnkolumn]])) {
    stop("Internt kommunuppslag har ogiltiga typer.", call. = FALSE)
  }
  if (is.null(rader)) rader <- rep(TRUE, nrow(data))
  if (!is.logical(rader) || length(rader) != nrow(data) || anyNA(rader)) {
    stop("Internt kommunuppslag har ogiltigt radurval.", call. = FALSE)
  }
  ar_kommun <- rader & !is.na(data$valtyp) & data$valtyp == "KF"
  index <- match(data[[kodkolumn]][ar_kommun], kommunnamn_2026$kommunkod)
  data[[namnkolumn]][ar_kommun] <- kommunnamn_2026$kommunnamn[index]
  data
}
