# Load the function definition
source("scr/compute_emission_targets.R")

# Run the function with example parameters
compute_emission_targets(
  edgar_file = "data/CSC-GHG_emissions-April2024_to_calibrate.csv",
  region     = "egypt",
  tyear      = 2022
)

compute_emission_targets(
  edgar_file = "data/CSC-GHG_emissions-April2024_to_calibrate.csv",
  region     = "mexico",
  tyear      = 2022
)
