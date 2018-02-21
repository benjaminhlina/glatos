#' @title 
#' Read data from a GLATOS data workbook
#' 
#' @description
#' Read data from a GLATOS workbook (xlsm file) and return a list of class 
#' \code{glatos_workbook}.
#'
#' @param wb_file A character string with path and name of workbook in 
#'  standard GLATOS format (*.xlsm). If only file name is given, then the 
#'  file must be located in the working directory.
#'  
#' @param wb_version An optional character string with the workbook version
#'   number. If NULL (default value) then version will be determined by
#'   evaluating workbook structure. Currently, the only allowed values are
#'   \code{NULL} and \code{"1.3"}. Any other values will trigger an error.
#'
#' @param read_all If TRUE, then all columns and sheets
#'  (e.g., user-created "project-specific" columns or sheets) in the workbook
#'  will be imported. If FALSE (default value) then only columns in the 
#'  standard GLATOS workbook will be imported (project-specific columns will 
#'  be ignored.)
#'
#' @details
#' If \code{read_all = TRUE} then the type of data in each user-defined 
#' column will be 'guessed' by \code{read_excel}; this may throw some warnings.
#' 
#' @return A list of class \code{glatos_workbook} with three elements:
#' \describe{
#'   \item{metadata}{A list with data about the project.}
#'   \item{animals}{A data frame with data about tagged animals.}
#'   \item{receivers}{A data frame with data about receivers.}
#' }
#'
#' @author C. Holbrook (cholbrook@usgs.gov) 
#'
#' @examples
#' #get path to example GLATOS Data Workbook
#' wb_file <- system.file("extdata", 
#'   "walleye_workbook.xlsm", package = "glatos")
#' wb <- read_glatos_workbook(wb_file)
#'
#' @export
read_glatos_workbook <- function(wb_file, read_all = FALSE, 
  wb_version = NULL) {

  #Read workbook-----------------------------------------------------------
  
  #see version-specific file specifications
  #internal glatos_workbook_spec in R/sysdata.r
  
  
  #Get sheet names
  sheets <- tolower(openxlsx::getSheetNames(wb_file))
    
  #Identify workbook version (based on sheet names)
  id_workbook_version <- function(wb_file, sheets){
    if(all(names(glatos:::glatos_workbook_schema$v1.3) %in% sheets)) {
      return("1.3") 
    } else {
      stop(paste0("Workbook version could not be identified. Double check ",
                  "that you are using a standard GLATOS Workbook file. The ",
                   "names of sheets must match standard file."))
    }
  }
  
  #Check version if specified
  if(is.null(wb_version)) {
    wb_version <- id_workbook_version(wb_file, sheets)
  } else if (!(paste0("v",wb_version) %in% 
             names(glatos:::glatos_workbook_schema))) {
    stop(paste0("Workbook version ", wb_version, " is not supported."))
  }
  
  wb <- list() #preallocate
  
  if(read_all)  wb[sheets] <- NA #add element for each sheet

  #-Workbook v1.3--------------------------------------------------------------  
  if (wb_version == "1.3") {
    wb[names(glatos:::glatos_workbook_schema$v1.3)] <- NA
    
    #Get project data
    tmp <- openxlsx::readWorkbook(wb_file, sheet = "Project", startRow = 1, 
                                  colNames = FALSE)
    
    wb$project <- list(project_code = tmp[1,2],
                        principle_investigator = tmp[2,2],
                        pi_email = tmp[3,2],
                        source_file=basename(wb_file),
                        wb_version = "1.3",
                        created = file.info(wb_file)$ctime)      

    #Read all sheets except project
    if(read_all) { 
      sheets_to_read <- sheets
      extra_sheets <- setdiff(sheets, names(glatos:::glatos_workbook_schema[[
        paste0("v", wb_version)]]))
    } else {
      sheets_to_read <- names(glatos:::glatos_workbook_schema[[
                                                paste0("v", wb_version)]])
    }
    sheets_to_read <- setdiff(sheets_to_read, "project") #exclude project
    
    for(i in 1:length(sheets_to_read)){
      
      schema_i <- glatos:::glatos_workbook_schema[[
                  paste0("v", wb_version)]][[sheets_to_read[i]]]

      if(is.null(schema_i)){ xl_start_row <- 1 } else { xl_start_row <- 2 }
        
      #read one row to get dimension and column names
      tmp <- openxlsx::readWorkbook(wb_file, 
        sheet = match(sheets_to_read[i], tolower(sheets)), 
        check.names = FALSE,
        startRow = xl_start_row, na.strings = c("", "NA"))      
        
      if(!is.null(schema_i)){
      
        #check that sheet i contains all names in schema
        missing_cols <- setdiff(schema_i$name, tolower(colnames(tmp)))
        if(length(missing_cols) > 0){ 
          stop(paste0("The following columns were not found in sheet named '", 
               sheets_to_read[i],"': ",
               paste(missing_cols, collapse = ", ")))
        }
        
        if(!read_all){
          #subset only columns in schema (by name)
          # - use match so that first column with each name is selected if > 1
          tmp <- tmp[ , match(schema_i$name, tolower(colnames(tmp)))]
        } else {
   
            #identify project-specific fields
            extra_cols <- colnames(tmp)[- match(schema_i$name, tolower(colnames(tmp)))]
            
            #identify new columns to add
            if (length(extra_cols) > 0) {
              
              #count column names to identify and rename any conflicting
              col_counts <- table(tolower(colnames(tmp)))
              conflict_cols <- col_counts[col_counts > 1]
              
              if(length(conflict_cols) > 0) {
                #rename conflict cols
                for(k in 1:length(conflict_cols)) {
                  name_k <- names(conflict_cols)[k]
                  extra_names_k <- c(name_k, 
                                paste0(name_k, "_x", 1:(conflict_cols[k] - 1)))
                  names(tmp)[tolower(colnames(tmp)) == name_k] <- extra_names_k
                    
                  warning(paste0("Non-standard (project-specific) columns ",
                    "were found with names matching standard column names ",
                    "in sheet '", sheets_to_read[i],"'. The following ",
                    "project-specific names were assigned to avoid conflicts: ", 
                    paste0(extra_names_k, collapse = ", "), "."))
                }
              } #end if
            }
          } #end if else
  
        #make column names lowercase
        names(tmp) <- tolower(names(tmp))
        
        #set classes; by column name since conflicts resolved above
        
        # character
        char_cols <- with(schema_i, name[type == "character"])
        for(j in char_cols) tmp[ , j] <- as.character(data.frame(tmp)[ , j])
   
        # numeric
        num_cols <- with(schema_i, name[type == "numeric"])
        for(j in num_cols) tmp[ , j] <- as.numeric(data.frame(tmp)[ , j])
   
        # POSIXct
        posixct_cols <- with(schema_i, name[type == "POSIXct"])
        for(j in posixct_cols) {
          schema_row <- match(j, schema_i$name)
  
          #Get time zone
          #function to construct time zone string from reference column tmp
          REFCOL <- function(x) {
            col_x <- gsub(")$", "", strsplit(x, "REFCOL\\(")[[1]][2])
            x2 <- tmp[, col_x]
            utc_rows <- tolower(x2) %in% c("utc", "gmt")
            x2[utc_rows] <- "UTC"
            x2[!utc_rows] <- with(tmp, paste0("US/", x2[!utc_rows]))
            return(x2)
          }
          
          #get timezone for this column        
          tz_cmd <- gsub("^tz = |^tz=|\"","", schema_i$arg[schema_row])         
          
          if(grepl("REFCOL", tz_cmd)) { 
            tzone_j <- REFCOL(tz_cmd)
            tz_cmd <- unique(tzone_j)
          } 
          
          if(length(tz_cmd) > 1) stop("Multiple time zones in one column are ",
            "not supported at this time.")        
          
          #Handle mixture of timestamps as date and char
          
          #identify timestamps that can be numeric; assume others character
          posix_na <- is.na(tmp[, j]) #identify missing first
          posix_as_num <- suppressWarnings(as.numeric(tmp[, j]))
          posix_as_char <- !posix_na & is.na(posix_as_num)
          if(any(posix_as_char)) warning(paste0("Some timestamps in ",
               "column ", j , " of `", sheets_to_read[i], "` were not formatted ",
               "as date-time objects in Excel. Double check the following rows ",
               "in the Excel file: ", paste0(which(posix_as_char) + 2, 
                 collapse = ", ")))
  
          #convert numeric
          posix_as_num <- openxlsx::convertToDateTime(posix_as_num, 
                                  tz = Sys.timezone())
          #round to nearest minute and force to correct timezone
          posix_as_num <- as.POSIXct(round(posix_as_num, "mins"), 
                                     tz = tz_cmd)
  
          #do same for posix_as_char and insert into posix_as_num
          if(any(posix_as_char)){
            posix_as_num[posix_as_char] <- as.POSIXct(tmp[posix_as_char , j], 
                                                      tz = tz_cmd)
          }
          
          tmp[ , j] <- posix_as_num
        
        } #end j
        
        # Date
        date_cols <- with(schema_i, name[type == "Date"])
        for(j in date_cols) {
          schema_row <- match(j, schema_i$name)
          
          #identify date that can be numeric; assume others character
          date_na <- is.na(tmp[, j]) #identify missing 
          date_as_num <- suppressWarnings(as.numeric(tmp[, j]))
          date_as_char <- !date_na & is.na(date_as_num)
          if(any(date_as_char)) warning(paste0("Some timestamps in ",
            "column ", j , " of `", sheets_to_read[i], "` were not formatted ",
            "as date-time objects in Excel. Double check the following rows ",
            "in the Excel file: ", paste0(which(date_as_char) + 2, 
              collapse = ", ")))
          
          #convert numeric
          date_as_num <- openxlsx::convertToDate(date_as_num)
          
          #do same for posix_as_char and insert into posix_as_num
          if(any(date_as_char)){
            date_as_num[date_as_char] <- as.Date(tmp[date_as_char , j])
          }
          
          tmp[ , j] <- date_as_num
          
        } #end j
      
      } #end if
        
      wb[[sheets_to_read[i]]] <- tmp
      
    } #end i
          
    
    #merge to glatos_workbook list object
    ins_key <- list(by.x = c("glatos_project", "glatos_array", "station_no",
        "consecutive_deploy_no", "ins_serial_no"), 
      by.y = c("glatos_project", "glatos_array", "station_no", 
        "consecutive_deploy_no", "ins_serial_number"))
    wb2 <- with(wb, list(
                  metadata = project,
                    animals = tagging,
                  receivers = merge(deployment,
                    recovery[, unique(c(ins_key$by.y, 
                      setdiff(names(recovery), names(deployment))))],
                    by.x = c("glatos_project", "glatos_array", "station_no",
                      "consecutive_deploy_no", "ins_serial_no"), 
                    by.y = c("glatos_project", "glatos_array", "station_no", 
                      "consecutive_deploy_no", "ins_serial_number"), 
                    all.x=TRUE, all.y=TRUE)
                  ))
    #add location descriptions
    wb2$receivers <- with(wb2, merge(receivers, wb$locations,
        by = "glatos_array"))
    
    #Drop unwanted columns from receivers
    
    #coalesce deploy_date_time and glatos_deploy_date_time
    attr(wb2$receivers$glatos_deploy_date_time, "tzone") <- "UTC"
    ddt_na <- is.na(wb2$receivers$deploy_date_time)
    wb2$receivers$deploy_date_time[ddt_na] <- 
                                wb2$receivers$glatos_deploy_date_time[ddt_na]
    
    #coalesce recover_date_time and glatos_recover_date_time
    attr(wb2$receivers$glatos_recover_date_time, "tzone") <- "UTC"
    rdt_na <- is.na(wb2$receivers$recover_date_time)
    wb2$receivers$recover_date_time[rdt_na] <- 
      wb2$receivers$glatos_recover_date_time[rdt_na]    
    
    drop_cols_rec <- c("glatos_deploy_date_time", "glatos_timezone",
                   "glatos_recover_date_time")
    wb2$receivers <- wb2$receivers[ , -match(drop_cols_rec, 
                                             names(wb2$receivers))]
    
    #sort rows by deploy_date_time
    wb2$receivers <- wb2$receivers[with(wb2$receivers, 
            order(deploy_date_time, glatos_array, station_no)), ]
    row.names(wb2$receivers) <- NULL
    
    #Drop unwanted columns from animals
    
    #coalesce release_date_time and utc_release_date_time
    attr(wb2$animals$glatos_release_date_time, "tzone") <- "UTC"
    ardt_na <- is.na(wb2$animals$utc_release_date_time)
    wb2$animals$utc_release_date_time[ardt_na] <- 
      wb2$animals$glatos_release_date_time[ardt_na]  
    
    drop_cols_anim <- c("glatos_release_date_time", "glatos_timezone")
    wb2$animals <- wb2$animals[ , -match(drop_cols_anim, 
                                         names(wb2$animals))]
    
    #sort animals
    #sort rows by deploy_date_time
    wb2$animals <- wb2$animals[with(wb2$animals, 
      order(utc_release_date_time, animal_id)), ]
    row.names(wb2$animals) <- NULL
    
    #create animal_id if missing
    anid_na <- is.na(wb2$animals$animal_id)
    wb2$animals$animal_id[anid_na] <- with(wb2$animals, 
            paste0(tag_code_space, "-", tag_id_code))
       
    
        
    #Append new sheets if required
    if(read_all) {
      for(i in 1:length(extra_sheets)){
        wb2[extra_sheets[i]] <- wb[extra_sheets[i]]
      }
    }
  }

  #-end v1.3----------------------------------------------------------------
  
  #assign classes
  wb2$animals <- glatos:::glatos_animals(wb2$animals)
  wb2$receivers <- glatos:::glatos_receivers(wb2$receivers)
  wb2 <- glatos:::glatos_workbook(wb2)
  
  return(wb2)
}

