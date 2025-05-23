#################################################################################################################
# custom_limits.R
#
# Function to set custom axis limits.
#
#################################################################################################################

custom_limits <- function(x) {
  case_when(max(x) > 10    & max(x) <= 20    ~ c(0, 20),
            max(x) > 20    & max(x) <= 40    ~ c(0, 40),
            max(x) > 70    & max(x) <= 100   ~ c(0, 100),
            max(x) > 100   & max(x) <= 20000 ~ c(0, 15000),
            max(x) > 20000                   ~ c(24000, 44000),
            TRUE                             ~ c(0, 0))
  }
