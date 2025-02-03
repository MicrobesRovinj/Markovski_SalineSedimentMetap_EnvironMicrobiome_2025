#################################################################################################################
# custom_pcoa.R
#
# Function to customise PCoA calculation.
#
#################################################################################################################

custom_pcoa <- function(data, add, metadata) {

  # Remove abundance columns that contain only 0
  data <- data %>%
    select(ID, where(fn = ~ is.numeric(.x) && sum(.x) !=  0))

  # Calculate the dissimilarity
  spe_bray <- data %>%
    column_to_rownames("ID") %>%
    vegdist(method = "bray")

  # Calculate PCoA
  spe_b_pcoa <- wcmdscale(spe_bray, k = (nrow(data) - 1), eig = TRUE, add = add)

  # Extract point coordinates
  coordinates <- spe_b_pcoa %>%
    scores(choices = c(1, 2)) %>%
    as_tibble(rownames = NA) %>%
    rownames_to_column("ID") %>%
    rename(A1 = Dim1, A2 = Dim2)

  # Combine metadata and point coordinates
  coordinates <- inner_join(metadata, coordinates, by = c("ID" = "ID"))

  # Return outputs
  list(input = data,
       spe_bray = spe_bray,
       spe_b_pcoa = spe_b_pcoa,
       coordinates = coordinates)

}
