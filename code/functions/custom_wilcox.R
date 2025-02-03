#################################################################################################################
# custom_wilcox.R
#
# Function to customise the Mann-Whitney U test (Wilcoxon rank sum test) calculation.
#
#################################################################################################################

custom_wilcox <- function(input, filter_layer = NULL, filter_analysis = NULL,
                          select_value_column = NULL, group_by = NULL) {
  
  # Filter layer
  input <- input %>%
    filter(layer == {{ filter_layer }})
  
  # Filter analysis groups
  if(select_value_column == "KO_in_C_value") {
    # Filter KO entry
    # (tests differences in KO entries within the functional COG category C)
    input <- input %>%
      filter(KO_name == {{ filter_analysis }} )
  } else {
    # In other cases, filter by station or decay of roots and rhizomes period
    input <- input %>%
      filter(station == {{ filter_analysis }} | decay_roots == {{ filter_analysis }} )
  }

  # Extract values to be tested
  x <- input %>%
    filter(station == unlist({{ group_by }})[1] | decay_roots == unlist({{ group_by }})[1])
  y <- input %>%
    filter(station == unlist({{ group_by }})[2] | decay_roots == unlist({{ group_by }})[2])
  
  # Select column containing values
  if(!is.null(select_value_column)) {
    x <- x %>%
      select({{ select_value_column }}) %>%
      deframe()
    y <- y %>%
      select({{ select_value_column }}) %>%
      deframe()
    }
  
  # Calculate number of samples in each group
  groups <- c(length(x), length(y))
  names(groups) <- c(unlist(group_by)[1], unlist(group_by)[2])
  
  # Perform the Mann-Whitney U test
  wilcox <- wilcox.test(x = x, y = y, alternative = "two.sided", paired = FALSE)
  
  # Return the outputs
  list(wilcox = wilcox,
       groups = groups)

  }
