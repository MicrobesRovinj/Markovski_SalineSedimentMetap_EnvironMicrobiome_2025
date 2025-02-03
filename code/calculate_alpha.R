#################################################################################################################
# calculate_alpha.R
#
# Script to calculate the number of observed proteins and the exponential of the Shannon diversity index.
# Dependencies: data/processed/naaf.tsv
#               code/functions/transpose_naaf.R
#               data/raw/metadata.tsv
#               code/functions/format_labels.R
# Produces: results/numerical/alpha.Rdata
#
#################################################################################################################

# Load NAAFs metaproteomic data and transpose data
naaf <- read_tsv("data/processed/naaf.tsv") %>%
  transpose_naaf(id_column = Accession)

# Copying sample labels to rows names (input for library vegan) and
# transform NAAFs metaproteomic data to pa (presence/absence) format
observed_number <- naaf %>%
  column_to_rownames(var = "ID") %>%
  decostand(method = "pa") %>%
  as_tibble(.name_repair = "unique", rownames = "ID")

# Calculate the observed number of proteins for each sample
observed_number <- observed_number %>%
  mutate(observed_number = rowSums(select(., starts_with("19181-"), starts_with("20151-")))) %>%
  select(ID, observed_number)

# Copying sample labels to rows names (input for library vegan) and
# calculate the exponential of the Shannon diversity index for each sample
shannon_exponential <- naaf %>%
  column_to_rownames(var = "ID") %>%
  diversity(index = "shannon") %>%
  enframe(name = "ID", value = "shannon") %>%
  mutate(shannon_exponential = exp(shannon))

# Load metadata
metadata <- read_tsv("data/raw/metadata.tsv")

# Join metadata, observed number of proteins, and exponential of the Shannon diversity index
alpha <- inner_join(metadata, observed_number, by = c("ID" = "ID")) %>%
  inner_join(shannon_exponential, by = c("ID" = "ID")) %>%
  format_labels() %>%
  pivot_longer(cols = c(observed_number, shannon_exponential), names_to = "parameter", values_to = "value")

# Save
save(alpha, file = "results/numerical/alpha.Rdata")
