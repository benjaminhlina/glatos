% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/util-convert_glatos_to_att.r
\name{convert_glatos_to_att}
\alias{convert_glatos_to_att}
\title{Convert detections and receiver metadata to a format that
ATT accepts.}
\usage{
convert_glatos_to_att(
  detectionObj,
  receiverObj,
  crs = sp::CRS("+init=epsg:4326")
)
}
\arguments{
\item{detectionObj}{a list from \code{read_glatos_detections}}

\item{receiverObj}{a list from \code{read_glatos_receivers}}

\item{crs}{a \code{\link[=CRS-class]{sp::CRS}} object with geographic coordinate system for all spatial information (latitude/longitude). If none provided or \code{crs} is not recognized, defaults to WGS84.}
}
\value{
a list of 3 tibble::tibbles containing tag dectections, tag metadata,
and station metadata, to be ingested by VTrack/ATT
}
\description{
Convert \code{glatos_detections} and \code{glatos_receiver} objects to \code{ATT} for compatibility with the Animal Tracking Toolbox (\url{https://github.com/vinayudyawer/ATT}).
}
\details{
This function takes 2 lists containing detection and reciever data
and transforms them into one list containing 3 \code{tibble::tibble}
objects. The input that AAT uses to get this data product is located here:
https://github.com/vinayudyawer/ATT/blob/master/README.md and our mappings
are found here: https://github.com/ocean-tracking-network/glatos/issues/75#issuecomment-982822886
in a comment by Ryan Gosse.
}
\examples{

#--------------------------------------------------
# EXAMPLE #1 - loading from the vignette data

library(glatos)
wal_det_file <- system.file("extdata", "walleye_detections.csv",
  package = "glatos"
)
walleye_detections <- read_glatos_detections(wal_det_file) # load walleye data

rec_file <- system.file("extdata", "sample_receivers.csv",
  package = "glatos"
)
rcv <- read_glatos_receivers(rec_file) # load receiver data

ATTdata <- convert_glatos_to_att(walleye_detections, rcv)
}
\author{
Ryan Gosse
}
