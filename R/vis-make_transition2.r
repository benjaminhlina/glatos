#' Create transition layer from a spatial polygon
#'
#' Create transition layer for \link{interpolate_path} from
#' \link[=SpatialPolygons]{SpatialPolygonsDataFrame}.
#'
#' @param poly A spatial polygon object of class
#' \link[=SpatialPolygons]{SpatialPolygonsDataFrame}.
#'
#' @param res two element vector that specifies the x and y dimension
#'   of output raster cells.  Units of res are same as input
#'   polygon.
#'
#' @param extent_out An optional \code{Extent} object
#'   (see \link[raster]{extent}) that determines the extent of the
#'   output objects. Output extent will default to extent of input object
#'   \code{poly} if \code{extent_out}, and \code{x_lim}/\code{y_lim}
#'   are NULL (default).
#'
#' @param x_lim An optional two-element vector with extents of x axis.
#'
#' @param y_lim An optional two-element vector with extents of x axis.
#'
#' @param water value coded as water in transition layer. Represents
#'   the "cost" associated with moving between raster cells coded as
#'   water.
#' 
#' @param land land value coded as land in transition layer. Represents
#'   the "cost" associated with impossible (for fish) over land
#'   movements.
#' 
#' @details \code{make_transition} uses \link[raster]{rasterize} to
#'   convert a \link[=SpatialPolygons]{SpatialPolygonsDataFrame} into
#'   a raster layer, and geo-corrected transition layer
#'   \link[gdistance]{transition}.  Raster cell values on land = 0 and
#'   water = 1.
#'
#' @details output transition layer is corrected for projection
#'   distortions using \link[gdistance]{geoCorrection}.  Adjacent
#'   cells are connected by 16 directions and transition function
#'   returns 0 (land) for movements between land and water and 1 for
#'   all over-water movements.
#'
#' @details default values for "land" and "water" arguments allow
#'   interpolation of fish movements over land when receiver is coded
#'   as on "land" in transition layer.  This often occurs for
#'   receivers in rivers when pixel size of transition layer is too
#'   large to distinguish between water and land.  Changing land
#'   argument to 0 and water to 1 will prevent any interpolation
#'   overland and result in an error if a receiver is on land.
#'
#' 
#' 
#' @return A list with two elements:
#' \describe{
#'    \item{transition}{a geo-corrected transition raster layer where land = 0
#'       and water=1
#'   (see \code{gdistance})}
#'    \item{rast}{rasterized input layer of class \code{raster}}}
#'
#' @seealso \link{make_transition}
#'
#' @author Todd Hayden, Tom Binder, Chris Holbrook
#'
#' @examples
#'
#' library(sp) #for loading greatLakesPoly
#' library(raster) # for plotting rasters
#'
#' # get polygon of the Great Lakes
#' data(greatLakesPoly) #glatos example data; a SpatialPolygonsDataFrame
#'
#' # make_transition layer
#' tst <- make_transition2(greatLakesPoly, res = c(0.1, 0.1))
#'
#' # plot raster layer
#' # notice land = 1, water = 0
#' plot(tst$rast)
#'
#' # plot transition layer
#' plot(raster(tst$transition))
#' 
#' \dontrun{
#' # increase resolution- this may take some time...
#' tst1 <- make_transition2(greatLakesPoly, res = c(0.01, 0.01))
#'
#' # plot raster layer
#' plot(tst1$rast)
#'
#' # plot transition layer
#' plot(raster(tst1$transition))
#' }
#'
#' @export

make_transition2 <- function(poly, res = c(0.1, 0.1), extent_out = NULL,
                             x_lim = NULL, y_lim = NULL, water = 1e-10, land = 1000){

  # convert from "cost" to "conductance"
  water <- 1/water
  land <- 1/land

  message("Making transition layer...")
  
  if(sum(is.null(x_lim), is.null(y_lim)) == 1) stop(paste0("You must specify ",
    "'x_lim' and 'y_lim' or neither."))
  if(!is.null(x_lim) & length(x_lim) != 2) stop("'x_lim' must be a vector ",
    "with exactly two elements.")
  if(!is.null(y_lim) & length(y_lim) != 2) stop("'y_lim' must be a vector ",
    "with exactly two elements.")

  if(is.null(x_lim) & is.null(extent_out)){ 
    extent_out <- raster::extent(poly) 
    } else if (!is.null(x_lim)) { 
      extent_out <- raster::extent(c(x_lim[1], x_lim[2],
                                      y_lim[1], y_lim[2]))
  }
    
  burned = raster::rasterize(poly, y = raster::raster(res = res, ext = extent_out), 
    field = water, background = land)
  
  tran <- function(x) if(x[1] == land | x[2] == land){ return(land) } else { return(water) }
  tr1 <- gdistance::transition(burned, transitionFunction = tran, 
    directions = 16)
  tr1 <- gdistance::geoCorrection(tr1, type="c")
  
  message("Done.")
  return(list(transition = tr1, rast = burned))
  }
    
