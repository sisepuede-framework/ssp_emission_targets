# 📘 Emission Targets Function

This repository contains the function **`compute_emission_targets()`**, which generates country–year emission targets from the [EDGAR](https://edgar.jrc.ec.europa.eu/) emissions dataset and a mapping file.

## 🔎 Context
- **EDGAR** provides greenhouse gas emissions by subsector and gas.  
- The **mapping file** links EDGAR categories to the categories used in the SiSePuede model (or similar frameworks).  
- For a given **country** and **year**, the function extracts the EDGAR values, distributes them across the mapped rows, and produces a cleaned CSV with emission targets.

## 📂 Repository structure
```
SSP_EMISSION_TARGETS/
│
├── data/                         # Input files (EDGAR, mapping, nations)
├── out/                          # Output emission target CSVs
├── scr/
│   └── compute_emission_targets.R # Function definition
├── main.r                        # Script to run the function
└── README.md                     # Documentation
```

## ⚙️ Inputs
1. **EDGAR CSV** (e.g. `data/CSC-GHG_emissions-April2024_to_calibrate.csv`)  
   Must contain columns:  
   - `Code` (ISO3 country code)  
   - `Gas`  
   - `CSC.Subsector`  
   - Year columns named as `XYYYY` (e.g. `X2022`)  

2. **Mapping file** (default: `data/mapping_corrected.csv`)  
   Must contain columns:  
   - `Subsector`  
   - `Gas`  
   - `Edgar_Class`  

3. **Nations file** (default: `data/tagertcountries_iso_codes.csv`)  
   Must contain columns:  
   - `Country`  
   - `ISOCode3`  

## 📝 How to run
You **do not need to edit the function**.  
All you need is to change the parameters in `main.r`:

```r
# main.r

# Load the function
source("scr/compute_emission_targets.R")

# Run with your chosen parameters
compute_emission_targets(
  edgar_file = "data/CSC-GHG_emissions-April2024_to_calibrate.csv",
  region     = "Egypt",
  tyear      = 2022
)

compute_emission_targets(
  edgar_file = "data/CSC-GHG_emissions-April2024_to_calibrate.csv",
  region     = "Mexico",
  tyear      = 2022
)
```

Then, from R or RStudio, just run:

```r
source("main.r")
```

## 📤 Output
The results are saved automatically in the `out/` folder with the format:

```
emission_targets_<region>_<year>.csv
```

Example:
```
out/emission_targets_egypt_2022.csv
out/emission_targets_mexico_2022.csv
```