# Make internal data object walleye_att for testing
# (example data object)

# get path to example detections file
dtc_file <- system.file("extdata",
  "walleye_detections.csv",
  package = "glatos"
)

# get path to example receiver file
rec_file <- system.file("extdata", "sample_receivers.csv",
  package = "glatos"
)

# create new objects
walleye_detections <- glatos::read_glatos_detections(dtc_file)
rcv <- glatos::read_glatos_receivers(rec_file) # load receiver data

walleye_att <- glatos::convert_glatos_to_att(walleye_detections, rcv)


#----------------------------------------------------

# add to sysdata.rda
rda_file <- file.path("R/sysdata.rda")
glatos:::add_internal_data(walleye_att, rda_file)

# for exported ('public') data
# devtools::use_data(walleye_detections, pkg = "..", overwrite = TRUE)
