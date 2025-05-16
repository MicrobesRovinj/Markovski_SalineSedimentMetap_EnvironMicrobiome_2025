#################################################################################################################
# plot_alpha.R
#
# Script to plot the observed number of proteins and the exponential of the Shannon diversity index.
# Dependencies: results/numerical/alpha.Rdata
#               code/functions/selected_pairwise_wilcox.R
#               code/functions/p_values_to_labels.R
#               data/raw/colour_station.R
#               data/raw/pattern_period.R
#               data/raw/theme.R
# Produces: results/figures/alpha.jpg
#
#################################################################################################################

# Load data
load(file = "results/numerical/alpha.Rdata")

# Calculate the statistical parameters of the Mann-Whitney U
# test for the observed number of proteins and the exponential
# of the Shannon diversity index
alpha_ob <- alpha %>%
  filter(parameter == "observed_number")
alpha_ob <- selected_pairwise_wilcox(input = alpha_ob, select_value_column = "value")
alpha_sh <- alpha %>%
  filter(parameter == "shannon_exponential")
alpha_sh <- selected_pairwise_wilcox(input = alpha_sh, select_value_column = "value")

# Bind the calculated statistical parameters
alpha_stat <- bind_rows(observed_number = alpha_ob,
                        shannon_exponential = alpha_sh,
                        .id = "parameter")

# Filter the adjusted p-values < 0.05
alpha_stat <- alpha_stat %>%
  filter(p.adj < 0.05)

# Represent p-values using asterisks
alpha_stat <- alpha_stat %>%
  mutate(p.adj_annot = p_values_to_labels(x = p.adj))

# Add positions where to draw the p-value annotations
alpha_stat <- alpha_stat %>%
  # Expand the column containing data in a list to
  # two columns
  rename(group = groups) %>%
  unnest_wider(col = group, names_sep = "_") %>%
  # Add the starting x axis position of the p-value annotation
  mutate(start = case_when(layer == "Top" & analysis == "Before Decline" & group_1 == "Vegetated" ~ 0.775,
                           layer == "Upper Middle" & analysis == "Before Decline" & group_1 == "Vegetated" ~ 1.775,
                           layer == "Lower Middle" & analysis == "Before Decline" & group_1 == "Vegetated" ~ 2.775,
                           layer == "Bottom" & analysis == "Before Decline" & group_1 == "Vegetated" ~ 3.775,
                           layer == "Lower Middle" & analysis == "Vegetated" & group_1 == "Before Decline" ~ 2.775,
                           layer == "Bottom" & analysis == "Nonvegetated" & group_1 == "Before Decline" ~ 4.075,
                           TRUE ~ NA)) %>%
  # Add the ending x axis position of the p-value annotation
  mutate(end = case_when(layer == "Top" & analysis == "Before Decline" & group_2 == "Nonvegetated" ~ 1.075,
                         layer == "Upper Middle" & analysis == "Before Decline" & group_2 == "Nonvegetated" ~ 2.075,
                         layer == "Lower Middle" & analysis == "Before Decline" & group_2 == "Nonvegetated" ~ 3.075,
                         layer == "Bottom" & analysis == "Before Decline" & group_2 == "Nonvegetated" ~ 4.075,
                         layer == "Lower Middle" & analysis == "Vegetated" & group_2 == "Meadow Decline" ~ 2.925,
                         layer == "Bottom" & analysis == "Nonvegetated" & group_2 == "Meadow Decline" ~ 4.225,
                         TRUE ~ NA)) %>%
  # Add the y axis position of the p-value annotation
  mutate(y = case_when(parameter == "observed_number" ~ 42500,
                       analysis == "Vegetated" ~ 12300,
                       analysis == "Nonvegetated" ~ 12300,
                       parameter == "shannon_exponential" ~ 13800,
                       TRUE ~ NA)) %>%
  # Add the columns station and decay roots (values added are not used for the
  # p-value annotation positioning but are required by package ggsignif)
  mutate(station = "Vegetated") %>%
  mutate(decay_roots = "Before Decline")

# Load plot customisation data
source(file = "data/raw/colour_station.R")
source(file = "data/raw/pattern_period.R")

# Generate plot
p <- alpha %>%
  ggplot(mapping = aes(x = layer, y = value, fill = station, pattern = decay_roots)) +
  stat_boxplot(geom = "errorbar", width = 0.2, position = position_dodge(0.6)) +
  geom_boxplot_pattern(width = 0.5, pattern_fill = "black", pattern_angle = 45,
                       pattern_size = 0.1, pattern_spacing = 0.01,
                       position = position_dodge(width = 0.6)) +
  scale_fill_manual(name = NULL,
                    values = colour_station,
                    breaks = names(colour_station)) +
  scale_pattern_manual(name = NULL,
                       values = pattern_period,
                       breaks = names(pattern_period)) +
  scale_y_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  labs(x = "Layer", y = "Number of Proteins") +
  facet_wrap(facets = vars(parameter), nrow = 2, scales = "free_y",
             labeller = labeller(parameter = c(observed_number = "Observed Number of Proteins",
                                               shannon_exponential = "Exponential of the Shannon Diversity Index")),
             axes = "all", axis.labels = "all_y") +
  geom_signif(mapping = aes(xmin = start, xmax = end, layer = layer,
                            annotations = p.adj_annot, y_position = y),
              data = alpha_stat, tip_length = 0.02, size = 0.5, textsize = 5.0,
              family = "Times", vjust = 0, manual = TRUE) +
  theme +
  theme(panel.border = element_blank()) +
  guides(fill = guide_legend(override.aes = list(pattern = "none"), order = 2))

# Save
ggsave(filename = "results/figures/alpha.jpg", p, width = 297, height = 210, units = "mm")
