#################################################################################################################
# custom_anosim.R
#
# Function to customise ANOSIM calculation.
# Dependencies: code/functions/transpose_naaf.R
#               code/functions/format_labels.R
#
#################################################################################################################

custom_anosim <- function(naaf, metadata, filter_station = NULL, filter_layer = NULL,
                          filter_cog = NULL, group_by = NULL, permutations = permutations) {

  # Filter COG category
  if(!is.null(filter_cog)) {
    naaf <- naaf %>%
      filter(COG_category %in% filter_cog) %>%
      mutate(across(.cols = starts_with("MM_"), .fns = ~ .x / sum(.x, na.rm = TRUE)))
  }

  # Transpose the NAAF data
  transposed_naaf <- transpose_naaf(x = naaf, id_column = Accession)

  # Format plot labels using custom function
  metadata <- format_labels(x = metadata)

  # Join transposed NAAF data and metadata
  transposed_naaf_metadata <- left_join(x = transposed_naaf, y = metadata, by = c("ID" = "ID"))

  # Select samples
  transposed_naaf_metadata <- transposed_naaf_metadata %>%
    filter(station %in% filter_station)
  if(!is.null(filter_layer)) {
    transposed_naaf_metadata <- transposed_naaf_metadata %>%
      filter(layer %in% filter_layer)
  }

  # Define groups
  groups <- transposed_naaf_metadata %>%
    column_to_rownames("ID") %>%
    select({{ group_by }}) %>%
    deframe()

  # Select columns containing abundance data
  transposed_naaf_metadata <- transposed_naaf_metadata %>%
    select(ID, starts_with("19181-"), starts_with("20151-"))

  # Remove abundance columns containing only 0
  transposed_naaf_metadata <- transposed_naaf_metadata %>%
    select(ID, where(fn = ~ is.numeric(.x) && sum(.x) !=  0)) %>%
    column_to_rownames("ID")

  # Calculate ANOSIM
  anosim <- anosim(x = transposed_naaf_metadata, grouping = groups, permutations = permutations, distance = "bray")
  
  # Calculate the number of samples in each group
  groups <- table(groups)
  
  # Return outputs
  list(anosim = anosim,
       groups = groups)
  
  }
