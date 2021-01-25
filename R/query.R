#' @export
query <- function(freqs, kgram) {
        attr(freqs, "cpp_obj")$query(kgram)
}