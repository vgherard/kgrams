% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/preprocess.R
\name{preprocess}
\alias{preprocess}
\title{Text preprocessing}
\usage{
preprocess(input, erase = "[^.?!:;'[:alnum:][:space:]]", lower_case = TRUE)
}
\arguments{
\item{input}{a character vector.}

\item{erase}{a length one character vector. Regular expression matching
parts of text to be \emph{erased} from input. The default removes anything
not  alphanumeric (\code{[A-z0-9]}), space (white space, tab,
vertical tab, newline, form feed, carriage return), apostrophes or
punctuation characters (\code{"[.?!:;]"}).}

\item{lower_case}{a length one logical vector. If TRUE, puts everything to
lower case.}
}
\value{
a character vector containing the processed output.
}
\description{
A minimal text preprocessing utility.
}
\details{
The expressions \code{preprocess(x, erase = pattern, lower_case = TRUE)} and
\code{preprocess(x, erase = pattern, lower_case = FALSE)} are roughly
equivalent to \code{tolower(gsub(pattern, "", x))} and
\code{gsub(pattern, "", x)}, respectively, provided that the regular
expression 'pattern' is correctly recognized by R.

\strong{Note.} This function, as well as \link[kgrams]{tknz_sent}, are included
in the library for illustrative purposes only, and are not optimized for
performance. Furthermore (for performance reasons) the function has a
separate implementation for Windows and UNIX OS types, respectively, so that
results obtained in the two cases may differ slightly.
In contexts that require full reproducibility, users are encouraged to define
their own preprocessing and tokenization custom functions - or to work with
externally processed data.
}
\examples{
preprocess("#This Is An Example@-@!#")
}
\author{
Valerio Gherardi
}
