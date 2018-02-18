<!-- README.md is generated from README.Rmd. Please edit that file -->
glatos: An R package for acoustic telemetry
-------------------------------------------

### Package status

*This package is in early development and its content is evolving.* To access the package or contribute code, join the project at (<https://gitlab.oceantrack.org/GreatLakes/glatos>). If you encounter problems or have questions or suggestions, please post a new issue or email <cholbrook@usgs.gov> (maintainer: Chris Holbrook).

### Installation

Installation instructions can be found [here](https://gitlab.oceantrack.org/GreatLakes/glatos/wikis/installation-instructions)

### Contents

#### Data loading and processing

1.  [`read_glatos_detections`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/load-read_glatos_detections.r) and [`read_otn_detections`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/load-read_otn_detections.r) provide fast data loading from standard GLATOS and OTN data files to a single structure that is compatible with other glatos functions.

2.  [`read_glatos_receivers`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/load-read_glatos_receivers.r) reads receiver location histories from standard GLATOS adata files to a single structure that is compatible with other glatos functions.

3.  [`read_glatos_workbook`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/load-read_glatos_workbook.r) reads project-specific receiver history and fish taggging and release data from a standard glatos workbook file.

4.  [`read_vemco_tag_specs`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/load-read_vemco_tag_specs.r) reads transmitter (tag) specifications and operating schedule.

5.  [`real_sensor_values`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/proc-real_sensor_values.r) converts 'raw' transmitter sensor (e.g., depth, temperature) to 'real'-scale values (e.g., depth in meters) using transmitter specification data (e.g., from read\_vemco\_tag\_specs.

#### Filtering and summarizing

1.  [`min_lag`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/proc-min_lag.r) facilitates identification and removal of false positive detections by calculating the minimum time interval (min\_lag) between successive detections.

2.  [`detection_filter`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/filt-false_detections.r) removes potential false positive detections using "short interval" criteria (GLATOS min\_lag column).

3.  [`detection_events`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/summ-detection_events.r) distills detection data down to a much smaller number of discrete detection events, defined as a change in location or time gap that exceeds a threshold.

4.  [`summarize_detections`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/summ-summarize_detections.r) calculates number of fish detected, number of detections, first and last detection timestamps, and/or mean location of receivers or groups, depending on specific type of summary requested.

#### Simulation functions for system design and evaluation

1.  [`calc_collision_prob`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/sim-calc_collision_prob.r) estimates the probability of collisions for pulse-position-modulation type co-located telemetry transmitters. This is useful for determining the number of fish to release or tag specifications (e.g., delay).

2.  [`receiver_line_det_sim`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/sim-receiver_line_det_sim.r) simulates detection of acoustic-tagged fish crossing a receiver line (or single receiver). This is useful for determining optimal spacing of receviers in a line and tag specifications (e.g., delay).

3.  [`crw_in_polygon`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/simutil-crw_in_polygon.r), [`transmit_along_path`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/sim-transmit_along_path.r), and [`etect_transmissions`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/sim-detect_transmissions.r) individually simulate random fish movement paths within a water body (`crw_in_polygon`: a random walk in a polygon), tag signal transmissions along those paths (`transmit_along_path`: time series and locations of transmissions based on tag specs), and detection of those transmittions by receivers in a user-defined receiver network (`detect_transmissions`: time series and locations of detections based on detection range curve). Collectively, these functions can be used to explore, compare, and contrast theoretical performance of a wide range of transmitter and receiver network designs.

#### Visualization and data exploration

1.  [`kml_workbook`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-kml_workbook.r) is useful for exploring receiver and animal release locations in Google Earth. *VERY EARLY VERSION*

2.  [`abacus_plot`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-abacus_plot.r) is useful for exploring movement patterns of individual tagged animals.

3.  [`detection_bubble_plot`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-detection_bubble_plot.r) is useful for exploring distribution of tagged individuals among receivers.

4.  [`interpolate_path`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-interpolate_path.r), [`make_frames`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-make_frames.r), and [`make_video`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-make_video.r) can be used together to interpolate movement paths between detections and save animated movement paths to a video file (mp4).

5.  [`adjust_playback_time`](https://gitlab.oceantrack.org/GreatLakes/glatos/blob/workshop-version/R/vis-adjust_playback_time.r) can be used to modify videos.
