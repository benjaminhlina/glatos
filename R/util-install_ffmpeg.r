##' Install external FFmpeg software into `glatos` package
##' 
##' Downloads and installs external ffmpeg into `glatos` package
##' directory system to enable creation animated videos of fish
##' movements
##'
##' @details \code{install_ffmpeg} determines operating system
##'   (Windows or Mac) and downloads the latest stable version of
##'   FFmpeg software.  FFmpeg software is installed within glatos
##'   package and may be accessed using \code{system.file}
##'
##' 
##' @return message is returned to console signalling successful installation
##' @author Todd Hayden
##'
##' @examples
##'
##'\dontrun{
##'
##' # call function
##' install_ffmpeg()
##'
##' # determine version of FFmpeg installed and if install was successful
##' fle <- system.file("bin", "ffmpeg.exe", package = "glatos")
##' system2(fle, "-version")
##' 
##'}
##' @export

install_ffmpeg <- function(){
  # determine what OS
  os <- get_os()
  
  # download windows build of ffmpeg
  if(os == "windows"){
    
    url <- "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip"
  }
  
  # download osx build of ffmpeg
  if(os == "osx"){
    url <- "http://ffmpeg.zeranoe.com/builds/macos64/static/ffmpeg-latest-macos64-static.zip"
  }
  
  # find package files on system
  tmp <- tempdir()
  destfile <- file.path(tmp, "ffmpeg.zip")
  download.file(url, destfile = destfile, mode = "wb")
  pkg <- find.package("glatos", lib.loc = .libPaths())
  utils::unzip(destfile, exdir = tmp)
  fls <- list.files(tmp, full.names = TRUE, recursive = TRUE, 
                    pattern = "^ffmpeg$|ffmpeg.exe$")
  if(!dir.exists(file.path(pkg, "bin"))) dir.create(file.path(pkg, "bin"))
  fl_dest <- file.path(pkg, "bin", basename(fls))
  file.rename(fls, fl_dest)
}



# install ffmpeg to GLATOS package
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}


