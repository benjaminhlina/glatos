#' Convert detections and receiver metadata to a format that
#' ATT accepts.
#'
#' Convert `glatos_detections` and `glatos_receiver` objects to `ATT` for compatibility with the Animal Tracking Toolbox (<https://github.com/vinayudyawer/ATT>).
#'
#' @param detectionObj a list from `read_glatos_detections`
#'
#' @param receiverObj a list from `read_glatos_receivers`
#'
#' @param crs a \code{\link[=CRS-class]{sp::CRS}} object with geographic coordinate system for all spatial information (latitude/longitude). If none provided or `crs` is not recognized, defaults to WGS84.
#'
#' @details This function takes 2 lists containing detection and reciever data
#'   and transforms them into one list containing 3 `tibble::tibble`
#'   objects. The input that AAT uses to get this data product is located here:
#'   https://github.com/vinayudyawer/ATT/blob/master/README.md and our mappings
#'   are found here: https://github.com/ocean-tracking-network/glatos/issues/75#issuecomment-982822886
#'   in a comment by Ryan Gosse.
#'
#' @author Ryan Gosse
#'
#' @return a list of 3 tibble::tibbles containing tag dectections, tag metadata,
#'   and station metadata, to be ingested by VTrack/ATT
#'
#' @examples
#'
#' #--------------------------------------------------
#' # EXAMPLE #1 - loading from the vignette data
#'
#' library(glatos)
#' wal_det_file <- system.file("extdata", "walleye_detections.csv",
#'   package = "glatos"
#' )
#' walleye_detections <- read_glatos_detections(wal_det_file) # load walleye data
#'
#' rec_file <- system.file("extdata", "sample_receivers.csv",
#'   package = "glatos"
#' )
#' rcv <- read_glatos_receivers(rec_file) # load receiver data
#'
#' ATTdata <- convert_glatos_to_att(walleye_detections, rcv)
#' @export

convert_glatos_to_att <- function(detectionObj, receiverObj,
                                  crs = sp::CRS("+init=epsg:4326")) {
  transmitters <-
    if (all(grepl("-", detectionObj$transmitter_id, fixed = TRUE))) {
      detectionObj$transmitter_id
    } else {
      concat_list_strings(
        detectionObj$transmitter_codespace,
        detectionObj$transmitter_id
      )
    }

  tagMetadata <- unique(tibble::tibble( # Start building Tag.Metadata table
    Tag.ID = as.integer(detectionObj$animal_id),
    Transmitter = as.factor(transmitters),
    Common.Name = as.factor(detectionObj$common_name_e)
  ))

  tagMetadata <- unique(tagMetadata) # Cut out dupes

  nameLookup <- tibble::tibble( # Get all the unique common names
    Common.Name = unique(tagMetadata$Common.Name)
  )
  nameLookup <- dplyr::mutate(nameLookup, # Add scinames to the name lookup
    Sci.Name = as.factor(purrr::map(nameLookup$Common.Name, query_worms_common))
  )
  # Apply sci names to frame
  tagMetadata <- dplyr::left_join(tagMetadata, nameLookup, by = "Common.Name")


  releaseData <- tibble::tibble( # Get the rest from detectionObj
    Tag.ID = as.integer(detectionObj$animal_id),
    Tag.Project = as.factor(detectionObj$glatos_project_transmitter),
    Release.Latitude = detectionObj$release_latitude,
    Release.Longitude = detectionObj$release_longitude,
    Release.Date = as.Date(detectionObj$utc_release_date_time),
    Sex = as.factor(detectionObj$sex)
  )

  releaseData <- dplyr::mutate(releaseData,
    # Convert sex text and null missing columns
    Sex = as.factor(purrr::map(Sex, convert_sex)),
    Tag.Life = as.integer(NA),
    Tag.Status = as.factor(NA),
    Bio = as.factor(NA)
  )
  # Final version of Tag.Metadata
  tagMetadata <- dplyr::left_join(tagMetadata, releaseData, by = "Tag.ID")

  detectionObj <- detectionObj %>%
    dplyr::mutate(dummy = TRUE) %>%
    dplyr::left_join(
      dplyr::select(
        receiverObj %>%
          dplyr::mutate(dummy = TRUE),
        glatos_array, station_no, deploy_lat, deploy_long,
        station, dummy, ins_model_no, ins_serial_no,
        deploy_date_time, recover_date_time
      ),
      by = c(
        "glatos_array", "station_no", "deploy_lat",
        "deploy_long", "station", "dummy"
      )
    ) %>%
    dplyr::filter(
      detection_timestamp_utc >= deploy_date_time,
      detection_timestamp_utc <= recover_date_time
    ) %>%
    dplyr::mutate(ReceiverFull = concat_list_strings(
      ins_model_no,
      ins_serial_no
    )) %>%
    dplyr::select(-dummy)

  detections <- unique(tibble::tibble(
    Date.Time = detectionObj$detection_timestamp_utc,
    Transmitter = as.factor(
      concat_list_strings(
        detectionObj$transmitter_codespace,
        detectionObj$transmitter_id
      )
    ),
    Station.Name = as.factor(detectionObj$station),
    Receiver = as.factor(detectionObj$ReceiverFull),
    Latitude = detectionObj$deploy_lat,
    Longitude = detectionObj$deploy_long,
    Sensor.Value = as.integer(detectionObj$sensor_value),
    Sensor.Unit = as.factor(detectionObj$sensor_unit)
  ))

  stations <- unique(tibble::tibble(
    Station.Name = as.factor(receiverObj$station),
    Receiver = as.factor(concat_list_strings(
      receiverObj$ins_model_no,
      receiverObj$ins_serial_no
    )),
    Installation = as.factor(NA),
    Receiver.Project = as.factor(receiverObj$glatos_project),
    Deployment.Date = receiverObj$deploy_date_time,
    Recovery.Date = receiverObj$recover_date_time,
    Station.Latitude = receiverObj$deploy_lat,
    Station.Longitude = receiverObj$deploy_long,
    Receiver.Status = as.factor(NA)
  ))

  att_obj <- list(
    Tag.Detections = detections,
    Tag.Metadata = unique(tagMetadata),
    Station.Information = unique(stations)
  )

  class(att_obj) <- "ATT"


  if (inherits(crs, "CRS")) {
    attr(att_obj, "CRS") <- crs
  } else {
    message("Geographic projection for detection positions not recognised, reverting to WGS84 global coordinate reference system")
    attr(att_obj, "CRS") <- eval(formals()$crs)
  }

  return(att_obj)
}


# Function for taking 2 lists of string of the same length and concatenating the
# columns, row by row.
concat_list_strings <- function(list1, list2, sep = "-") {
  if (length(list1) != length(list2)) {
    stop(sprintf(
      "Lists are not the same size. %d != %d.",
      length(list1), length(list2)
    ))
  }
  return(paste(list1, list2, sep = sep))
}
