#################################################################################################################
# to_tibble.R
#
# Function to be used inside mutate() to store the output of another function into multiple columns
# (from https://stackoverflow.com/questions/73398676/dplyrmutate-when-custom-function-return-a-vector).
#
#################################################################################################################

to_tibble <- function(x, colnames) {
  
  x %>%
    matrix(ncol = length(colnames), dimnames = list(NULL, colnames)) %>%
    as_tibble()
  
  }
