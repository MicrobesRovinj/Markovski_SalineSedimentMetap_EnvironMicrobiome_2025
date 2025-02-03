#################################################################################################################
# calculate_cog.R
#
# Script to calculate the number of proteins assigned to each COG functional category and the proportion of each
# category in the total NAAF.
# Dependencies: data/processed/naaf.tsv
# Produces: results/numerical/cog_number.Rdata
#           results/numerical/cog_naaf.Rdata
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv("data/processed/naaf.tsv")

# Select columns containing abundance and COG category data
naaf <- naaf %>%
  select(COG_category, starts_with(match = "MM"))

# Rename entries to "multiple_cog" if proteins are assigned to
# multiple COG categories
naaf <- naaf %>%
  mutate(COG_category = if_else(str_length(COG_category) > 1, "multiple_cog", COG_category))

# Replace missing COG category (NA) with "no_cog"
naaf <- naaf %>%
  replace_na(replace = list(COG_category = "no_cog"))

# Replace COG category "-" with "no_cog"
naaf <- naaf %>%
  mutate(COG_category = if_else(COG_category == "-", "no_cog", COG_category))

# Remove the category "no_cog"
naaf <- naaf %>%
  filter(COG_category != "no_cog")

# Recalculate the proportion of each protein
naaf <- naaf %>%
  mutate(across(starts_with(match = "MM"), ~ .x / sum(.x)))

# Calculate the number of proteins for every COG category
cog_number <- naaf %>%
  mutate(across(starts_with(match = "MM"), .fns = ~ decostand(., method = "pa"))) %>%
  group_by(COG_category) %>%
  summarise(MM_total = n(), across(starts_with(match = "MM"), .fns = sum))

# Sum the NAAFs for every COG category
cog_naaf <- naaf %>%
  mutate(MM_sum = rowSums(select(., starts_with(match = "MM"))), .after = COG_category) %>%
  group_by(COG_category) %>%
  summarise(across(starts_with(match = "MM"), .fns = sum)) %>%
  mutate(MM_sum =  MM_sum / sum(MM_sum))

# Save
save(cog_number, file = "results/numerical/cog_number.Rdata")
save(cog_naaf, file = "results/numerical/cog_naaf.Rdata")
