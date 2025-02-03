#################################################################################################################
# calculate_naaf.R
#
# Script to calculate the NAAF.
# Dependencies: data/processed/formatted_metaproteomic_data.tsv
# Produces: data/processed/naaf.tsv
#
#################################################################################################################

# Load formatted metaproteomic data
formatted_metaproteomic_data <- read_tsv(file = "data/processed/formatted_metaproteomic_data.tsv")

# Calculate the NAAF
naaf <- formatted_metaproteomic_data %>%
  mutate(across(.cols = starts_with("MM_"), .fns = ~ .x / `Number of AAs`)) %>%
  mutate(across(.cols = starts_with("MM_"), .fns = ~ .x / sum(.x, na.rm = TRUE)))

# Remove column containing the number of amino acids and replace NA values with 0
naaf <- naaf %>%
  select(-`Number of AAs`) %>%
  mutate(across(.cols = starts_with("MM_"), .fns = ~ replace_na(.x, 0)))

# Save calculated NAAFs
write_tsv(naaf, "data/processed/naaf.tsv")
