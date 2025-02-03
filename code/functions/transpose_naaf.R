#################################################################################################################
# transpose_naaf.R
#
# Function to transpose the NAAF data.
#
#################################################################################################################

transpose_naaf <- function(x = NULL, id_column = NULL) {

  # Select columns containing accession numbers and abundance data
  transposed_naaf <- x %>%
    select({{ id_column }}, starts_with("MM_"))

  # Transpose the data
  transposed_naaf %>%
    column_to_rownames(var = as_name(x = enquo(arg = id_column))) %>%
    t() %>%
    as_tibble(rownames = NA) %>%
    rownames_to_column(var = "ID")
  
  }
