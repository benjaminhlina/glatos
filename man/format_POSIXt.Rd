% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load-write_vdat_csv.r
\name{format_POSIXt}
\alias{format_POSIXt}
\title{Round timestamp by fractional second and coerce to character}
\usage{
format_POSIXt(x, digits = 0, drop0trailing = TRUE)
}
\arguments{
\item{x}{A \code{POSIXct} or \code{POSIXlt} object.}

\item{digits}{The number of decimal places to which seconds is rounded.}

\item{drop0trailing}{logical (default = TRUE), indicating if trailing zeros,
i.e., "0" after the decimal mark, should be removed. Passed to
\link{format} which passes to \link{prettyNum}.}
}
\value{
A character vector in format like \code{"\%Y-\%m-\%d \%H:\%M:\%OSn"}
(see \link{strptime} but see 'detail' for differences).
}
\description{
Round timestamp by fractional second and coerce to character
}
\details{
Differs from e.g., \code{format(x, format = "\%Y-\%m-\%d
  \%H:\%M:\%OS6")} in that (1) rounding is used (not truncation) and (2)
trailing 0s can be omitted (via \code{drop0trailing}).

Differs from \code{lubridate::round_Date} in that it is accurate for
< 1 sec (see example 1 below for motivating example) but requires coercion
to POSIXlt before rounding and coercing to character.
}
\examples{

# Example 1 - motivating example: e.g., trouble with lubridate::round_Date
t1 <- as.POSIXct("2011-05-08 05:37:39.245541", tz = "UTC")
format(t1, digits = 6)

t2 <- lubridate::round_date(t1, unit = "0.00001s")
format(t2, digits = 6)

t3 <- format_POSIXt(t1, digits = 5)
format(t3, digits = 6)

# Example 2
t1 <- as.POSIXct(
  c(
    "2011-03-08 23:59:58",
    "2011-03-08 23:59:58.828867"
  ),
  tz = "UTC"
)
format_POSIXt(t1, digits = 5, drop0trailing = FALSE)
format_POSIXt(t1, digits = 5, drop0trailing = TRUE)

}
