#'Check if measured velocity of a tagged animal is within plausible range
#' 
#'Perform velocity test (Steckenreuter et al., 2017), which checks if 
#'measured velocity exceeds a threshold (maximum velocity).
#'
#'@param detections A data frame containing detection data with at least 5 
#'  columns containing 'timestamp', 'transmitters', 'receivers', 'longitude', 
#'  and 'latitude'. Column names are specified by \code{detColNames} or 
#'  indirectly by \code{type} (for GLATOS and OTN data).
#'  
#'@param type A character string with the type of detection data  
#'  passed in, if applicable. Acceptable values are "GLATOS" (default) or "OTN".
#'   Not used (ignored) when \code{detColNames} is used.
#'  
#'@param detColNames An optional list that contains the user-defined column 
#'  names of reuired columns in \code{detections}. See Details.
#'  
#'@param maxVelocity The maximum expected velocity ('ground speed') of a tagged 
#'  animal, in meters per second.
#'  
#'@details detColNames A list with the names of the required
#'  columns in \code{detections}: \itemize{ \item \code{timestampCol} is a
#'  character string with the name of the column containing datetime stamps for
#'  the detections (MUST be of class 'POSIXct') ('detection_timestamp_utc' for
#'  GLATOS data, 'datecollected' for OTN data, or 'time' for sample data). \item
#'  \code{transmittersCol} is a character string with the name of the column 
#'  containing the ids of the transmitters ('transmission_id' for GLATOS data,
#'  'tagname' for OTN data, or 'transmitter' for sample data). \item
#'  \code{receiversCol} is a character string with the name of the column 
#'  containing the ids of the receivers ('receiver_sn' for GLATOS data,
#'  'receiver_group' for OTN data, or 'receiver' for sample data). \item
#'  \code{longitudeCol} is a character string with the name of the column 
#'  containing the longitude coordinate for the detections ('deploy_long' for
#'  GLATOS data, 'longitude' for OTN data, or 'longitude' for sample data). 
#'  \item \code{latitudeCol} is a character string with the name of the column 
#'  containing the latitude coordinate for the detections ('deploy_lat' for
#'  GLATOS data, 'latitude' for OTN data, or 'latitude' for sample data). }
#'  
#'@details Each value in the min_dist column indicates the minimum of the
#'  distance between the current instance and instance before, and the distance
#'  between the current instance and the instance after.
#'@details Each value in the min_time column indicates the minimum of the time
#'  between the current instance and instance before, and the time between the
#'  current instance and the instance after.
#'@details Each value in the min_vel column indicates the value in the min_dist
#'  column divided by the value in the min_time column.
#'@details Each value in the velValid column indicates whether the value in the
#'  min_vel column is greater than the threshold 'maxVelocity'.
#'  
#'@return A data frame containing the data with the four columns appended to it:
#'  \item{min_dist}{Minimum of the distance between the current instance and
#'  instance before, and the distance between the current instance and the
#'  instance after.} \item{min_time}{Minimum of the time between the current
#'  instance and instance before, and the time between the current instance and
#'  the instance after.} \item{min_vel}{The min_dist value divided by the
#'  min_time value.} \item{velValid}{A value to check if the min_vel value is
#'  greater than or equal to (0), or less than (1) the \code{maxVelocity}.}
#'  
#'@references (in APA) Steckenreuter, A., Hoenner, X., Huveneers, C.,
#'  Simpfendorfer, C., Buscot, M.J., Tattersall, K., ... Harcourt, R. (2017).
#'  Optimising the design of large-scale acoustic telemetry curtains. Marine and
#'  Freshwater Research. 68:1403-1413. doi: 10.1071/MF16126
#'  
#'@author A. Dini
#'  
#'@usage To use: For GLATOS data, velTest(data, "GLATOS") For OTN data,
#'  velTest(data, "OTN") For sample data, velTest(data, "sample")
#'  
#' @export

velTest <- function(detections, type = "GLATOS", detColNames = list(), 
  maxVelocity = NA) {
  #Different column names from different types of data
  #Set different minimum velocity values to test against
  # Check if user has set column names
  if(length(detColNames) == 0) {
    if(type == "GLATOS") { #Set column names for GLATOS data
      detColNames <- list(timestampCol = "detection_timestamp_utc", 
                     transmittersCol= "transmitter_id", 
                     receiversCol = "receiver_sn", 
                     longCol = "deploy_long", 
                     latCol = "deploy_lat")
    } else if (type == "OTN") { #Set column names for OTN data
      detColNames <- list(timestampCol = "datecollected", 
                          transmittersCol = "tagname", 
                          receiversCol = "receiver_group", 
                          longCol = "longitude", 
                          latCol = "latitude")
    } else { #Other type
      stop(paste0("The type '", type, "' is not defined."), call. = FALSE)
    }
  }

  # Check that the specified columns appear in the detections dataframe
  missingCols <- setdiff(unlist(detColNames), names(detections))
  if (length(missingCols) > 0){
    stop(paste0("Detections dataframe is missing the following ",
                "column(s):\n", paste0("       '", missingCols, "'", 
                collapse="\n")), call. = FALSE)
  }
  
  # Subset detections with only user-defined columns and change names
  # this makes code easier to understand (especially ddply)
  data2 <- detections[ ,unlist(detColNames)] #subset
  names(data2) <- c("timestamp", "transmitters", "receivers", "long", "lat")
  # data2$num <- as.numeric(data2$timestamp)
  
  
  # Check that timestamp is of class 'POSIXct'
  if(!('POSIXct' %in% class(data2$timestampCol))){
    stop(paste0("Column '", detColNames$timestampCol,
                "' in the detections dataframe must be of class 'POSIXct'."),
         call. = FALSE)
  }
  
  #Set of points, which are made up of: (longitude, latitude)
  points <- data.frame(long = data2$long, lat = data2$lat)
  
  #Gets list of points before the current and after the current point (lag and
  #lead, respectively)
  pointsBefore <- data.frame(long = dplyr::lag(data2$long), 
                             lat = dplyr::lag(data2$lat))
  pointsAfter <- data.frame(long = dplyr::lead(data2$long), 
                            lat = dplyr::lead(data2$lat))
  
  #Calculates distance between each set of points by calculating distance
  #between previous and current point, and distance between current and next
  #point and labelling each list distB and distA, respectively
  distB <- geosphere::distHaversine(pointsBefore[ , c('long', 'lat')], 
                                    points[ , c('long', 'lat')])
  distA <- geosphere::distHaversine(points[ , c('long', 'lat')], 
                                    pointsAfter[ , c('long', 'lat')])
  
  #Get minimum of distance before point and distance after point
  distances <- data.frame(distB = distB, distA = distA)
  di <- apply(distances, 1, function(x) min(x, na.rm = TRUE))
  detections$min_dist <- di #Find minimum distance of before and after
  
  #Calculate min time (min_time) between current point and points before/after
  n <- as.numeric(data2$timestamp)
  lagBefore <- n - dplyr::lag(n) #Time between current point and before point
  lagAfter <- dplyr::lead(n) - n #Time between current point and after point
  d <- data.frame(before = lagBefore, after = lagAfter)
  mLag <- apply(d, 1, function(x) min(x, na.rm = TRUE)) #Min time before/after
  detections$min_time <- mLag
  
  #Calculate min velocity (min_vel) between current point and points before/after
  detections$min_vel<- apply(detections, 1, function(x) {
    timeS <- as.numeric(x["min_time"])
    # if(is.na(timeS))
    #   timeS <- strsplit(x["min_time"], " ")[[1]][1]
    #If time of current point and before or after point is the same, return 0 as
    #dividing it will give an error
    if(timeS == 0) { 
      0
    } else {
      as.numeric(x["min_dist"]) / as.numeric(timeS) #calculate minimum speed
    }
  })
  
  #Check if min_vel is valid (< threshold, maxVelocity) (1 if yes, 0 if no)
  detections$velValid <- apply(detections, 1, function(x) {
    val <- as.numeric(x["min_vel"])
    if (val < maxVelocity) {
      1 #valid
    } else {
      0 #not valid
    }
  })
  
  return(detections)
}