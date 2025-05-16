#################################################################################################################
# selected_pairwise_wilcox.R
#
# Function to calculate the statistical parameters of the Mann-Whitney U test (Wilcoxon rank sum test) for
# comparing differences between layers from different stations and decay periods.
# Dependencies: code/functions/custom_wilcox.R
#
#################################################################################################################

selected_pairwise_wilcox <- function(input = NULL, select_value_column = NULL) {

  # Define Mann-Whitney U test analysis groups
  wilcox <- tibble(analysis = rep(c("Vegetated",
                                    "Nonvegetated",
                                    "Before Decline",
                                    "Meadow Decline"), times = 4),
                   layer = c(rep("Top", times = 4),
                             rep("Upper Middle", times = 4),
                             rep("Lower Middle", times = 4),
                             rep("Bottom", times = 4)),
                   groups = rep(c(rep(list(c("Before Decline", "Meadow Decline")), times = 2),
                                  rep(list(c("Vegetated", "Nonvegetated")), times = 2)), times = 4),
                   n = rep(NA, times = 16),
                   W = rep(NA, times = 16),
                   p = rep(NA, times = 16),
                   p.adj = rep(NA, times = 16))
  
  # Perform the pairwise Mann-Whitney U test
  for (i in 1 : nrow(wilcox)) {
   
   # Perform Mann-Whitney U test using custom function
   test <- custom_wilcox(input = input, filter_layer = wilcox$layer[i], filter_analysis = wilcox$analysis[i],
                         select_value_column = select_value_column, group_by = wilcox$groups[i])
   # Fill table with calculated statistic
   wilcox$n[i] <- list(test$groups)
   wilcox$W[i] <- test$wilcox$statistic
   wilcox$p[i] <- test$wilcox$p.value
   
   }
  
  # Adjust the p-values using the Bonferroni correction
  for (i in unique(wilcox$layer)) {
    # Extract the layer
    layer <- wilcox %>%
      filter(layer == i)
    # Adjust the p-values
    p.adjust <- p.adjust(p = layer$p, method = "bonferroni")
    # Add adjusted p-values to the extracted layer tibble
    layer <- layer %>%
      mutate(p.adj = p.adjust)
    #
    wilcox <- left_join(x = wilcox, y = layer, by = c("analysis" = "analysis",
                                                      "layer" = "layer",
                                                      "groups" = "groups",
                                                      "n" = "n",
                                                      "W" = "W",
                                                      "p" = "p")) %>%
      # Coalesce the columns prefixed with "p.adj" that were generated during
      # the table join (The !!! operator ("bang-bang-bang") is used to splice
      # the selected columns into the coalesce() function. If you have a list
      # of arguments that you want to pass into a function in a way that each
      # element is treated as an individual argument, you can use !!!.)
      mutate(p.adj = coalesce(!!!select(., starts_with("p.adj")))) %>%
      select(!starts_with("p.adj."))
    
  }
  
  # Return the output
  wilcox
  
}
