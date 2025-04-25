# Developer input script: put year and IDs manually
# Sets a key to signal that inputs come from here, not from commandArgs()

# Interactive input

# Please enter the year (e.g. 2023)
year <- 2021 

# Enter the indicator IDs (e.g. 6901,6902,6904)
ids <- 6902

# Set a key that calculate_indicator.R can recognize
input_mode <- "interactive"

# Start the main script
source("functions/calculate_indicator.R")
