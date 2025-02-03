#################################################################################################################
# format_labels.R
#
# Function to format plot labels.
#
#################################################################################################################

format_labels <- function(x = NULL) {

  x %>%
    mutate(station = str_replace(station, "^SCy$", "Vegetated")) %>%
    mutate(station = str_replace(station, "^SN$", "Nonvegetated")) %>%
    mutate(station = factor(station, levels = c("Vegetated", "Nonvegetated"))) %>%
    mutate(layer = str_replace(layer, "^top$", "Top")) %>%
    mutate(layer = str_replace(layer, "^upper middle$", "Upper Middle")) %>%
    mutate(layer = str_replace(layer, "^lower middle$", "Lower Middle")) %>%
    mutate(layer = str_replace(layer, "^bottom$", "Bottom")) %>%
    mutate(layer = factor(layer, levels = c("Top", "Upper Middle", "Lower Middle", "Bottom"))) %>%
    mutate(decay_roots = str_replace(decay_roots, "^before$", "Before Decay")) %>%
    mutate(decay_roots = str_replace(decay_roots, "^after$", "Decay of Roots\nand Rhizomes")) %>%
    mutate(date = as.Date(date, "%d.%m.%Y")) %>%
    mutate(month = format(date, "%B")) %>%
    mutate(year = format(date, "%Y"))

  }
