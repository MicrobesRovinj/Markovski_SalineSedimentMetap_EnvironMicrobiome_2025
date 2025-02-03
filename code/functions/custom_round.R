#################################################################################################################
# custom_round.R
#
# Function to customise the rounding and formatting of numbers. Returns a list containing the formatted minimum
# and maximum values. Numbers are rounded to two decimal places.
#
#################################################################################################################

custom_round <- function(x = NULL) {
  
  if (is.null(x)) {
    stop("Input x cannot be NULL.")
  }
  
  result <- list(
    min = format(x = round(x = (min(x)), digits = 2), nsmall = 2),
    max = format(x = round(x = (max(x)), digits = 2), nsmall = 2)
    )
  
  return(result)
  
}
