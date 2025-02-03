#################################################################################################################
# calculate_anosim.R
#
# Script to calculate ANOSIM.
# Dependencies: data/processed/naaf.tsv
#               data/raw/metadata.tsv
#               code/functions/custom_anosim.R
# Produces: results/numerical/anosim.Rdata
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv(file = "data/processed/naaf.tsv")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Define ANOSIM analysis groups
groups <- tribble(~ id, ~ station, ~ layer, ~ groups, ~n, ~ R, ~ p,
                  "all_samples", c("Vegetated", "Nonvegetated"), c("Top", "Upper Middle", "Lower Middle", "Bottom"), "station", NA, NA, NA,
                  "all_samples", c("Vegetated", "Nonvegetated"), c("Top", "Upper Middle", "Lower Middle", "Bottom"), "layer", NA, NA, NA,
                  "all_samples", c("Vegetated", "Nonvegetated"), c("Top", "Upper Middle", "Lower Middle", "Bottom"), "decay_roots", NA, NA, NA,
                  "vegetated", "Vegetated", c("Top", "Upper Middle", "Lower Middle", "Bottom"), "layer", NA, NA, NA,
                  "vegetated", "Vegetated", c("Top", "Upper Middle", "Lower Middle", "Bottom"), "decay_roots", NA, NA, NA,
                  "nonvegetated", "Nonvegetated", c("Top", "Upper Middle", "Lower Middle", "Bottom"), "layer", NA, NA, NA,
                  "nonvegetated", "Nonvegetated", c("Top", "Upper Middle", "Lower Middle", "Bottom"), "decay_roots", NA, NA, NA,
                  "vegetated_top", "Vegetated", "Top", "decay_roots", NA, NA, NA,
                  "vegetated_upper_middle", "Vegetated", "Upper Middle", "decay_roots", NA, NA, NA,
                  "vegetated_lower_middle", "Vegetated", "Lower Middle", "decay_roots", NA, NA, NA,
                  "vegetated_bottom", "Vegetated", "Bottom", "decay_roots", NA, NA, NA,
                  "nonvegetated_top", "Nonvegetated", "Top", "decay_roots", NA, NA, NA,
                  "nonvegetated_upper_middle", "Nonvegetated", "Upper Middle", "decay_roots", NA, NA, NA,
                  "nonvegetated_lower_middle", "Nonvegetated", "Lower Middle", "decay_roots", NA, NA, NA,
                  "nonvegetated_bottom", "Nonvegetated", "Bottom", "decay_roots", NA, NA, NA)

# Calculate ANOSIM for all proteins and for COG category C
for (i in c("all", "C")) {
  
  for (j in 1 : nrow(groups)) {
    
    # Set filter_cog value to NULL if all proteins are used
    filter_cog <- unlist(if_else(i == "all", list(NULL), list(i)))
    
    # Calculate ANOSIM using custom function
    anosim <- custom_anosim(naaf = naaf, metadata = metadata, filter_station = groups$station[[j]],
                            filter_layer = groups$layer[[j]], filter_cog = filter_cog, group_by = groups$groups[[j]],
                            permutations = 999)
    # Fill table with calculated statistic
    groups$n[j] <- list(anosim$groups)
    groups$R[j] <- anosim$anosim$statistic
    groups$p[j] <- anosim$anosim$signif
    
    }
  
  # Format table
  output <- groups %>%
    select(-id) %>%
    mutate(station = map(.x = station,
                         .f = ~ ifelse(identical(.x, c("Vegetated", "Nonvegetated")), "All Stations", .x))) %>%
    mutate(layer = map(.x = layer,
                       .f = ~ ifelse(identical(.x, c("Top", "Upper Middle", "Lower Middle", "Bottom")), "All Layers", .x)))
  
  # Set name for each table
  assign(i, output)
  
  }

# Save
save(all, file = "results/numerical/anosim_all.Rdata")
save(C, file = "results/numerical/anosim_C.Rdata")
