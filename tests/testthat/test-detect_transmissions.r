context("Check detect_transmissions")

# non-spatial input
mypath <- data.frame(x=seq(0,1000,100),y=seq(0,1000,100))

#add receivers
recs <- expand.grid(x=c(250,750),y=c(250,750))

#  spatial transmit output
set.seed(30)
tr_dfin_spout <- transmit_along_path(mypath,vel=0.5,delayRng=c(60,180),
                                       burstDur=5.0)

#  spatial detection output - 50% constant detection prob
set.seed(33)
dtc_spin_spout <- detect_transmissions(trnsLoc=tr_dfin_spout, recLoc=recs, 
  detRngFun=function(x) 0.5)

#  non-spatial detection output - 50% constant detection prob
set.seed(33)
dtc_spin_dfout <- detect_transmissions(trnsLoc=tr_dfin_spout, recLoc=recs, 
  detRngFun=function(x) 0.5, sp_out = FALSE)


#   non-spatial output
set.seed(30)
tr_dfin_dfout <- transmit_along_path(mypath,vel=0.5,delayRng=c(60,180),
                                       burstDur=5.0, sp_out = FALSE)

#  spatial detection output - 50% constant detection prob
set.seed(33)
dtc_dfin_spout <- detect_transmissions(trnsLoc=tr_dfin_dfout, recLoc=recs, 
  detRngFun=function(x) 0.5)

#  non-spatial detection output - 50% constant detection prob
set.seed(33)
dtc_dfin_dfout <- detect_transmissions(trnsLoc=tr_dfin_dfout, recLoc=recs, 
  detRngFun=function(x) 0.5, sp_out = FALSE)


# Expected results
dtc_dfin_spout_shouldBe <- 
  new("SpatialPointsDataFrame", data = structure(list(trns_id = c(1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L), recv_id = c(4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L), trns_x = c(13.1818276389968, 56.8767184012104, 95.3024591051508, 
        136.128787984722, 171.878595847054, 201.123194387415, 262.227469359408, 
        294.693139266688, 358.656461557839, 387.622399439919, 413.376148018637, 
        453.211208320106, 499.272006531944, 559.572565160459, 592.031144616776, 
        654.084467239561, 687.734054906759, 745.948621229734, 794.731523462804, 
        836.013161249459, 865.489174427581, 913.313477097312, 937.754992288304, 
        974.732007517247), trns_y = c(13.1818276392296, 56.8767184013268, 
          95.3024591031717, 136.128787984606, 171.87859585078, 201.123194389394, 
          262.22746935545, 294.69313926599, 358.656461557839, 387.622399437707, 
          413.376148019102, 453.211208321038, 499.272006532294, 559.572565161507, 
          592.031144615728, 654.084467240493, 687.734054906061, 745.948621230782, 
          794.731523467344, 836.013161250623, 865.489174428163, 913.3134770951, 
          937.754992288304, 974.732007516897), etime = c(37.2838388492104, 
            160.871653092721, 269.55606038838, 385.030356395685, 486.146082656154, 
            568.862298421257, 741.691287189418, 833.51806857779, 1014.4336643365, 
            1096.36170873574, 1169.20430977985, 1281.87487485043, 1412.15448590151, 
            1582.71022156037, 1674.51694812781, 1850.03024901419, 1945.2056555093, 
            2109.86131395369, 2247.84019785158, 2364.60230192325, 2447.97305712632, 
            2583.24061202041, 2652.37165655165, 2756.95844941928)), row.names = c(NA, 
              24L), class = "data.frame"), coords.nrs = numeric(0), coords = structure(c(750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788), .Dim = c(24L, 
                  2L), .Dimnames = list(c("1", "2", "3", "4", "5", "6", "7", "8", 
                    "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", 
                    "20", "21", "22", "23", "24"), c("recv_x", "recv_y"))), bbox = structure(c(750.000000000116, 
                      749.999999997788, 750.000000000116, 749.999999997788), .Dim = c(2L, 
                        2L), .Dimnames = list(c("recv_x", "recv_y"), c("min", "max"))), 
    proj4string = new("CRS", projargs = "+init=epsg:3175 +proj=aea +lat_1=42.122774 +lat_2=49.01518 +lat_0=45.568977 +lon_0=-83.248627 +x_0=1000000 +y_0=1000000 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
  
dtc_dfin_dfout_shouldBe <- 
  structure(list(trns_id = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L), 
    recv_id = c(4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L), recv_x = c(749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884), recv_y = c(749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391), trns_x = c(13.1818276389968, 
            56.8767184012104, 95.3024591051508, 136.128787984722, 171.878595847636, 
            201.123194387765, 262.227469359408, 294.693139266688, 358.656461557839, 
            387.622399439686, 413.376148018637, 453.211208320456, 499.272006531944, 
            559.572565160692, 592.03114461666, 654.084467239445, 687.734054906759, 
            745.948621229734, 794.731523462804, 836.013161249459, 865.489174427581, 
            913.313477097312, 937.75499228877, 974.732007517247), trns_y = c(13.1818276392296, 
              56.8767184013268, 95.3024591031717, 136.128787984606, 171.878595853574, 
              201.123194392188, 262.22746935545, 294.69313926599, 358.656461557839, 
              387.62239943631, 413.376148019102, 453.211208323832, 499.272006532294, 
              559.572565162904, 592.031144614331, 654.084467239096, 687.734054906061, 
              745.948621230782, 794.731523467344, 836.013161250623, 865.489174428163, 
              913.3134770951, 937.754992292495, 974.732007516897), etime = c(37.2838388492104, 
                160.871653092721, 269.55606038838, 385.030356395685, 486.146082656154, 
                568.862298421257, 741.691287189418, 833.51806857779, 1014.4336643365, 
                1096.36170873574, 1169.20430977985, 1281.87487485043, 1412.15448590151, 
                1582.71022156037, 1674.51694812781, 1850.03024901419, 1945.2056555093, 
                2109.86131395369, 2247.84019785158, 2364.60230192325, 2447.97305712632, 
                2583.24061202041, 2652.37165655165, 2756.95844941928)), class = "data.frame", row.names = c(NA, 
                  24L))
  

dtc_spin_spout_shouldBe <- 
  new("SpatialPointsDataFrame", data = structure(list(trns_id = c(1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L), recv_id = c(4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L), trns_x = c(13.1818276389968, 56.8767184012104, 95.3024591051508, 
        136.128787984722, 171.878595847054, 201.123194387415, 262.227469359408, 
        294.693139266688, 358.656461557839, 387.622399439919, 413.376148018637, 
        453.211208320106, 499.272006531944, 559.572565160459, 592.031144616776, 
        654.084467239561, 687.734054906759, 745.948621229734, 794.731523462804, 
        836.013161249459, 865.489174427581, 913.313477097312, 937.754992288304, 
        974.732007517247), trns_y = c(13.1818276392296, 56.8767184013268, 
          95.3024591031717, 136.128787984606, 171.87859585078, 201.123194389394, 
          262.22746935545, 294.69313926599, 358.656461557839, 387.622399437707, 
          413.376148019102, 453.211208321038, 499.272006532294, 559.572565161507, 
          592.031144615728, 654.084467240493, 687.734054906061, 745.948621230782, 
          794.731523467344, 836.013161250623, 865.489174428163, 913.3134770951, 
          937.754992288304, 974.732007516897), etime = c(37.2838388492104, 
            160.871653092721, 269.55606038838, 385.030356395685, 486.146082656154, 
            568.862298421257, 741.691287189418, 833.51806857779, 1014.4336643365, 
            1096.36170873574, 1169.20430977985, 1281.87487485043, 1412.15448590151, 
            1582.71022156037, 1674.51694812781, 1850.03024901419, 1945.2056555093, 
            2109.86131395369, 2247.84019785158, 2364.60230192325, 2447.97305712632, 
            2583.24061202041, 2652.37165655165, 2756.95844941928)), row.names = c(NA, 
              24L), class = "data.frame"), coords.nrs = numeric(0), coords = structure(c(750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 750.000000000116, 
                750.000000000116, 750.000000000116, 750.000000000116, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788, 749.999999997788, 
                749.999999997788, 749.999999997788, 749.999999997788), .Dim = c(24L, 
                  2L), .Dimnames = list(c("1", "2", "3", "4", "5", "6", "7", "8", 
                    "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", 
                    "20", "21", "22", "23", "24"), c("recv_x", "recv_y"))), bbox = structure(c(750.000000000116, 
                      749.999999997788, 750.000000000116, 749.999999997788), .Dim = c(2L, 
                        2L), .Dimnames = list(c("recv_x", "recv_y"), c("min", "max"))), 
    proj4string = new("CRS", projargs = "+init=epsg:3175 +proj=aea +lat_1=42.122774 +lat_2=49.01518 +lat_0=45.568977 +lon_0=-83.248627 +x_0=1000000 +y_0=1000000 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
  
dtc_spin_dfout_shouldBe <- 
  structure(list(trns_id = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 
    1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L), 
    recv_id = c(4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 
      4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L, 4L), recv_x = c(749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884, 749.999999999884, 
        749.999999999884, 749.999999999884, 749.999999999884), recv_y = c(749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391, 749.999999996391, 
          749.999999996391, 749.999999996391, 749.999999996391), trns_x = c(13.1818276389968, 
            56.8767184012104, 95.3024591051508, 136.128787984722, 171.878595847636, 
            201.123194387765, 262.227469359408, 294.693139266688, 358.656461557839, 
            387.622399439686, 413.376148018637, 453.211208320456, 499.272006531944, 
            559.572565160692, 592.03114461666, 654.084467239445, 687.734054906759, 
            745.948621229734, 794.731523462804, 836.013161249459, 865.489174427581, 
            913.313477097312, 937.75499228877, 974.732007517247), trns_y = c(13.1818276392296, 
              56.8767184013268, 95.3024591031717, 136.128787984606, 171.878595853574, 
              201.123194392188, 262.22746935545, 294.69313926599, 358.656461557839, 
              387.62239943631, 413.376148019102, 453.211208323832, 499.272006532294, 
              559.572565162904, 592.031144614331, 654.084467239096, 687.734054906061, 
              745.948621230782, 794.731523467344, 836.013161250623, 865.489174428163, 
              913.3134770951, 937.754992292495, 974.732007516897), etime = c(37.2838388492104, 
                160.871653092721, 269.55606038838, 385.030356395685, 486.146082656154, 
                568.862298421257, 741.691287189418, 833.51806857779, 1014.4336643365, 
                1096.36170873574, 1169.20430977985, 1281.87487485043, 1412.15448590151, 
                1582.71022156037, 1674.51694812781, 1850.03024901419, 1945.2056555093, 
                2109.86131395369, 2247.84019785158, 2364.60230192325, 2447.97305712632, 
                2583.24061202041, 2652.37165655165, 2756.95844941928)), class = "data.frame", row.names = c(NA, 
                  24L))

# Testing output matches desired format for each input
test_that("data.frame input, spatial output gives expected result", {
  # Check if expected and actual results are the same
  expect_equal(dtc_dfin_spout, dtc_dfin_spout_shouldBe)
})
test_that("data.frame input, data.frame output gives expected result", {
  # Check if expected and actual results are the same
  expect_equal(dtc_dfin_dfout, dtc_dfin_dfout_shouldBe)
})
test_that("spatial input, data.frame output gives expected result", {
  # Check if expected and actual results are the same
  expect_equal(dtc_spin_dfout, dtc_spin_dfout_shouldBe)
})
test_that("spatial input, spatial output gives expected result", {
  # Check if expected and actual results are the same
  expect_equal(dtc_spin_spout, dtc_spin_spout_shouldBe)
})
