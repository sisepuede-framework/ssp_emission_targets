# Dependencies
library(data.table)

# Compute country emission targets from EDGAR + mapping
compute_emission_targets <- function(
    edgar_file,                 # e.g. "data/CSC-GHG_emissions-April2024_to_calibrate.csv"
    region,                     # e.g. "egypt" (any case; spaces allowed)
    tyear,                      # e.g. 2022
    mapping_file = "data/mapping_corrected.csv",
    nations_file = "data/tagertcountries_iso_codes.csv",
    output_dir   = "out"
) {
  
  # --- Load EDGAR and build class key
  edgar <- fread(edgar_file, header=TRUE, check.names = T)
  setDT(edgar)
  edgar[, Edgar_Class := paste(CSC.Subsector, Gas, sep = ":")]
  
  # --- Load mapping, build stable row id
  mapping <- fread(mapping_file)
  setDT(mapping)
  mapping[, ids := paste(.I, Subsector, Gas, sep = ":")]
  ids_all <- mapping[["ids"]]
  target_class <- "Edgar_Class"
  
  # --- Load nations, find ISO3 for requested region
  tnations <- fread(nations_file)
  tnations[, Nations := tolower(gsub(" ", "_", Country))]
  region_key <- tolower(gsub(" ", "_", region))
  iso_code3 <- tnations[Nations == region_key, ISOCode3][1]
  
  if (is.na(iso_code3) || !nzchar(iso_code3)) {
    stop(sprintf("Region '%s' not found in %s. Check spelling or update nations file.",
                 region, nations_file))
  }
  
  # --- Ensure output column exists for this ISO3
  if (!(iso_code3 %in% names(mapping))) {
    mapping[, (iso_code3) := 0]
  } else {
    mapping[, (iso_code3) := 0]  # reset if already present
  }
  
  # --- Column name in EDGAR for the target year
  year_col <- paste0("X", tyear)
  if (!(year_col %in% names(edgar))) {
    stop(sprintf("Year column '%s' not found in EDGAR file. Available cols: %s",
                 year_col, paste(names(edgar), collapse = ", ")))
  }
  
  # --- Fill targets row-by-row
  for (id in ids_all) {
    # The EDGAR class this mapping row belongs to
    target_class_i <- mapping[ids == id, get(target_class)]
    
    # All mapping rows that share the same EDGAR class (split evenly)
    ssp_ids <- mapping[get(target_class) == target_class_i, ids]
    n_ssp   <- length(ssp_ids)
    
    # Country/year EDGAR value for this class
    v <- edgar[Edgar_Class == target_class_i & Code == iso_code3, get(year_col)]
    v <- if (length(v) == 0 || is.na(v)) 0 else as.numeric(v) / n_ssp
    
    # Assign value to this mapping row in the country's column
    mapping[ids == id, (iso_code3) := v]
  }
  
  # --- Write output
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  outfile <- file.path(output_dir, sprintf("emission_targets_%s_%s.csv", region_key, tyear))
  fwrite(mapping, outfile)
  
  message(sprintf("Wrote: %s (ISO3=%s)", outfile, iso_code3))
  invisible(list(file = outfile, iso_code3 = iso_code3, n_rows = nrow(mapping)))
}