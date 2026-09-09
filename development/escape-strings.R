# Escape non-ASCII characters only inside R string literals. Parsed expressions
# must remain identical, including the values of Swedish messages and labels.
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  before <- parse(file, keep.source = FALSE, encoding = "UTF-8")
  tokens <- utils::getParseData(parse(file, keep.source = TRUE, encoding = "UTF-8"))
  tokens <- tokens[tokens$token == "STR_CONST" & grepl("[^ -~]", tokens$text), ]
  if (!nrow(tokens)) next
  stopifnot(all(tokens$line1 == tokens$line2))
  tokens <- tokens[order(tokens$line1, tokens$col1, decreasing = TRUE), ]
  lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
  for (i in seq_len(nrow(tokens))) {
    token <- tokens[i, ]
    line <- lines[[token$line1]]
    original <- substr(line, token$col1, token$col2)
    stopifnot(identical(original, token$text))
    chars <- utf8ToInt(original)
    escaped <- paste0(vapply(chars, function(ch) {
      if (ch <= 127L) intToUtf8(ch) else sprintf("\\u%04x", ch)
    }, character(1)), collapse = "")
    lines[[token$line1]] <- paste0(substr(line, 1, token$col1 - 1L), escaped,
                                  substring(line, token$col2 + 1L))
  }
  stopifnot(identical(before, parse(text = lines, keep.source = FALSE)))
  writeLines(enc2utf8(lines), file, useBytes = TRUE)
  message("Escaped strings without changing parsed expressions: ", file)
}
