#################################################################################################################
# format_protein_taxonomy.R
#
# Script to get full taxonomy from the NCBI taxonomy ID.
# Dependencies: data/raw/metaproteomic_data.tsv
#               code/functions/to_tibble.R
#               data/references/nameNode.sqlite
# Produces: data/processed/formatted_metaproteomic_data.tsv
#
#################################################################################################################

# Load annotated metaproteomic data containing NCBI taxonomy ID
metaproteomic_data <- read_tsv(file = "data/processed/metaproteomic_data.tsv")

# Remove entries that are not present (NA) in any of the samples
metaproteomic_data <- metaproteomic_data %>%
  filter(!if_all(.cols = starts_with("MM_"), .fns = ~ is.na(.)))

# Add taxonomy according to the NCBI taxonomy ID 
metaproteomic_data <- metaproteomic_data %>%
  mutate(to_tibble(x = getTaxonomy(NCBItaxonomyID, sqlFile = "data/references/nameNode.sqlite"),
                   colnames = c("domain", "phylum", "class", "order", "family", "genus", "species")))

# Remove entries without taxonomic classification or classified as Viruses and Eukaryota
metaproteomic_data <- metaproteomic_data %>%
  filter(domain == "Archaea" | domain == "Bacteria")

# Rename DIAMOND taxonomy columns
metaproteomic_data <- metaproteomic_data %>%
  rename("DIAMOND_domain" = "domain") %>%
  rename("DIAMOND_phylum" = "phylum") %>%
  rename("DIAMOND_class" = "class") %>%
  rename("DIAMOND_order" = "order") %>%
  rename("DIAMOND_family" = "family") %>%
  rename("DIAMOND_genus" = "genus")

# Remove Eukaryota and Viruses entries from the eggNOG_OGs column
metaproteomic_data <- metaproteomic_data %>%
  filter(str_detect(eggNOG_OGs, "\\|Archaea") | str_detect(eggNOG_OGs, "\\|Bacteria") | is.na(eggNOG_OGs))

# Save formatted data
write_tsv(metaproteomic_data, file = "data/processed/formatted_metaproteomic_data.tsv")
