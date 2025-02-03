#################################################################################################################
# calculate_cog_c_kegg.R
#
# Script to calculate the relative contribution of KO entries within the functional COG category C.
# Dependencies: data/processed/naaf.tsv
#               data/raw/ko_names.tsv
# Produces: results/numerical/cog_c_kegg.Rdata
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv("data/processed/naaf.tsv")

# Filter proteins classified into COG category C
naaf <- naaf %>%
  filter(str_detect(string = COG_category, pattern = "C"))

# If protein belongs to additional COG categories beside
# category C remove the other categories
naaf <- naaf %>%
  mutate(COG_category = if_else(COG_category != "C", "C", COG_category))

# Select columns containing NAAFs and KEGG KO data
naaf <- naaf %>%
  select(COG_category, KEGG_ko, starts_with(match = "MM"))

# Separate proteins assigned to multiple KO entries
naaf <- naaf %>%
  separate_longer_delim(cols = KEGG_ko, delim = ",")

# Remove "ko:" from KO entries
naaf <- naaf %>%
  mutate(KEGG_ko = str_remove(KEGG_ko, "^ko:"))

# Rename KO entry "-" to "no_ko"
naaf <- naaf %>%
  mutate(KEGG_ko = if_else(KEGG_ko == "-", "no_ko", KEGG_ko))

# Sum the NAAFs for every KO entry
naaf <- naaf %>%
  mutate(MM_sum = rowSums(select(., starts_with(match = "MM"))), .after = KEGG_ko) %>%
  group_by(COG_category, KEGG_ko) %>%
  summarise(across(starts_with(match = "MM"), .fns = sum), .groups = "drop")

# Recalculate the relative contribution of each KO entry
naaf <- naaf %>%
  mutate(across(starts_with(match = "MM"), ~ . / sum(.) * 100))

# Load KO entry names
ko_names <- read_tsv(file = "data/raw/ko_names.tsv", col_names = c("KEGG_ko", "KO_name"))

# Join NAAFs data and KO entry names
naaf_ko_names <- left_join(x = naaf, y = ko_names, by = c("KEGG_ko" = "KEGG_ko"))

# Add description for entry "no_ko"
naaf_ko_names <- naaf_ko_names %>%
  mutate(KO_name = if_else(KEGG_ko == "no_ko", "No KO available", KO_name))

# Format KO names
naaf_ko_names <- naaf_ko_names %>%
  mutate(KO_name = str_remove(KO_name, ";.*")) %>%
  mutate(KO_name = if_else(KO_name == "ATPF0C, atpE", "atpE (ATPF0C)", KO_name))

# Save
save(naaf_ko_names, file = "results/numerical/cog_c_kegg.Rdata")
