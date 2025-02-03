#################################################################################################################
# plot_cog_c_kegg.R
#
# Script to plot the relative contribution of the most abundant KO entries within the functional COG category C
# and the changes in the relative contribution of the same entries in each layer and decay period at the
# nonvegetated site.
# Dependencies: results/numerical/cog_c_kegg.Rdata
#               data/raw/colour_kegg.R
#               code/functions/transpose_naaf.R
#               data/raw/metadata.tsv
#               code/functions/format_labels.R
#               code/functions/custom_wilcox.R
#               code/functions/p_values_to_labels.R
#               data/raw/pattern_period.R
#               data/raw/theme.R
# Produces: results/figures/cog_c_kegg.jpg
#
#################################################################################################################

#################################################################################################################
# Plot the relative contribution of the most abundant KEGG KO entries within the functional COG category C
#################################################################################################################

# Load the relative contribution of KEGG KO entries
# within the functional COG category C
load(file = "results/numerical/cog_c_kegg.Rdata")

# Select KO entries, NAAFs sum in all samples, and KO entry names
naaf_ko_names <- naaf_ko_names %>%
  select(COG_category, KEGG_ko, MM_sum, KO_name)

# Group KO entries less than 3 % into category "Other"
naaf_ko_names <- naaf_ko_names %>%
  filter(MM_sum > 3) %>%
  bind_rows(tibble(COG_category = "C",
                   KEGG_ko = "other_ko",
                   MM_sum = 100 - sum(.$MM_sum),
                   KO_name = "Other"))

# Load plot customisation data
source(file = "data/raw/colour_kegg.R")

# Format factor levels of KO names
naaf_ko_names <- naaf_ko_names %>%
  mutate(KO_name = factor(x = KO_name, levels = names(colour_kegg)))

# Generate plot
p1 <- naaf_ko_names %>%
  ggplot(mapping = aes(x = COG_category, y = MM_sum, fill = KO_name)) +
  geom_bar(colour = "black", linewidth = 0.5, stat = "identity") +
  scale_fill_manual(name = NULL,
                    values = colour_kegg,
                    breaks = names(colour_kegg)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0))) +
  labs(x = "COG Category", y = "NAAF in COG Category C (%)",
       title = "All Samples") +
  theme +
  theme(legend.key.spacing.y = unit(x = 1.5, units = "pt"),
        panel.border = element_blank(),
        plot.title = element_text(margin = margin(b = 3 * 5.5)),
        plot.margin = margin(t = 20 * 5.5, r = 10 * 5.5, b = 20 * 5.5, l = 2 * 5.5, unit = "pt"))

#################################################################################################################
# Plot the relative contribution of the most abundant KEGG KO entries within the functional COG category C
# in each layer and decay period of the nonvegetated site
#################################################################################################################

# Load the relative contribution of KEGG KO entries
# within the functional COG category C
load(file = "results/numerical/cog_c_kegg.Rdata")

# Filter the most abundant KEGG KO entries to be plotted
naaf_ko_names <- naaf_ko_names %>%
  filter(KO_name %in% c("atpE (ATPF0C)",
                        "hppA",
                        "aprA",
                        "aprB"))

# Select columns containing KEGG KO names and NAAFs sample data
naaf_ko_names <- naaf_ko_names %>%
  select(KO_name, starts_with(match = "MM_"), -MM_sum)

# Transpose data
naaf_ko_names <- naaf_ko_names %>%
  transpose_naaf(id_column = KO_name)

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Join metadata and NAAFs data and format labels
metadata_naaf_ko_names <- right_join(x = metadata, y = naaf_ko_names, by = c("ID" = "ID")) %>%
  format_labels()

# Filter samples from the nonvegetated site
metadata_naaf_ko_names <- metadata_naaf_ko_names %>%
  filter(station == "Nonvegetated")

# Sum aprA and aprB
metadata_naaf_ko_names <- metadata_naaf_ko_names %>%
  mutate(aprAB = aprA + aprB) %>%
  select(-aprA, -aprB)

# Pivot longer the data
metadata_naaf_ko_names <- metadata_naaf_ko_names %>%
  pivot_longer(cols = c(aprAB, `atpE (ATPF0C)`, hppA), names_to = "KO_name", values_to = "KO_in_C_value")

# Define Mann-Whitney U test analysis groups
wilcox <- tibble(analysis = c(rep("atpE (ATPF0C)", times = 4),
                              rep("hppA", times = 4),
                              rep("aprAB", times = 4)),
                 layer = rep(c("Top",
                               "Upper Middle",
                               "Lower Middle",
                               "Bottom"), times = 3),
                 groups = rep(list(c("Before Decay", "Decay of Roots\nand Rhizomes")), times = 12),
                 n = rep(NA, times = 12),
                 W = rep(NA, times = 12),
                 p = rep(NA, times = 12))

# Perform the Mann-Whitney U test for the most abundant KEGG KO
# entries within the functional COG category C
for (i in 1 : nrow(wilcox)) {
  
  # Perform Mann-Whitney U test using custom function
  test <- custom_wilcox(input = metadata_naaf_ko_names, filter_layer = wilcox$layer[i], filter_analysis = wilcox$analysis[i],
                        select_value_column = "KO_in_C_value", group_by = wilcox$groups[i])
  # Fill table with calculated statistic
  wilcox$n[i] <- list(test$groups)
  wilcox$W[i] <- test$wilcox$statistic
  wilcox$p[i] <- test$wilcox$p.value
  
}

# Filter the adjusted p-values < 0.05
wilcox <- wilcox %>%
  filter(p < 0.05)

# Represent p-values using asterisks
wilcox <- wilcox %>%
  mutate(p_annot = p_values_to_labels(x = p))

# Load plot customisation data
source(file = "data/raw/colour_kegg.R")
source(file = "data/raw/pattern_period.R")

# Add positions where to draw the p-value annotations
wilcox <- wilcox %>%
  # Rename the analysis column to KO_name
  rename(KO_name = analysis) %>%
  # Expand the column containing data in a list to
  # two columns
  rename(group = groups) %>%
  unnest_wider(col = group, names_sep = "_") %>%
  # Add the starting x axis position of the p-value annotation
  mutate(start = case_when(layer == "Top" ~ 0.85,
                           layer == "Upper Middle" ~ 1.85,
                           layer == "Lower Middle" ~ 2.85,
                           layer == "Bottom" ~ 3.85,
                           TRUE ~ NA)) %>%
  # Add the ending x axis position of the p-value annotation
  mutate(end = case_when(layer == "Top" ~ 1.15,
                         layer == "Upper Middle" ~ 2.15,
                         layer == "Lower Middle" ~ 3.15,
                         layer == "Bottom" ~ 4.15,
                         TRUE ~ NA)) %>%
  # Add the y axis position of the p-value annotation
  mutate(y = case_when(KO_name == "atpE (ATPF0C)" ~ 85,
                       KO_name == "hppA" ~ 17,
                       KO_name == "aprAB" ~ 32,
                       TRUE ~ NA)) %>%
  # Add the column decay roots (values added are not used for the
  # p-value annotation positioning but are required by package ggsignif)
  mutate(decay_roots = "Before Decay") %>%
  # Format factor levels of KO names
  mutate(KO_name = factor(x = KO_name, levels = names(colour_kegg)))

# Format factor levels of KO names
metadata_naaf_ko_names <- metadata_naaf_ko_names %>%
  mutate(KO_name = factor(x = KO_name, levels = names(colour_kegg)))

# Generate plot
p2 <- metadata_naaf_ko_names %>%
  ggplot(mapping = aes(x = layer, y = KO_in_C_value, fill = KO_name, pattern = decay_roots)) +
  stat_boxplot(geom = "errorbar", width = 0.2, position = position_dodge(0.6)) +
  geom_boxplot_pattern(width = 0.5, pattern_fill = "black", pattern_angle = 45,
                       pattern_size = 0.1, pattern_spacing = 0.01,
                       position = position_dodge(0.6)) +
  scale_fill_manual(name = NULL,
                    values = colour_kegg,
                    breaks = names(colour_kegg)) +
  scale_pattern_manual(name = NULL,
                       values = pattern_period,
                       breaks = names(pattern_period["Decay of Roots\nand Rhizomes"])) +
  scale_y_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  labs(x = "Layer", y = "NAAF in COG Category C (%)",
       title = "Nonvegetated") +
  facet_wrap(facets = vars(KO_name), ncol = 1, scales = "free_y",
             axes = "all", axis.labels = "all_y") +
  geom_signif(mapping = aes(xmin = start, xmax = end, layer = layer,
                            annotations = p_annot, y_position = y),
            data = wilcox, tip_length = 0.02, size = 0.5, textsize = 5.0,
            family = "Times", vjust = 0, manual = TRUE) +
  theme +
  theme(panel.border = element_blank(),
        panel.spacing.y = unit(x = 4 * 5.5, units = "pt"),
        plot.title = element_text(margin = margin(b = 3 * 5.5)),
        strip.text = element_blank()) +
  guides(fill = guide_legend(override.aes = list(pattern = "none"), order = 2))

#################################################################################################################
# Combine plots and save
#################################################################################################################

# Combine plots
p <- plot_grid(p1, p2, nrow = 1, ncol = 2,
               rel_widths = c(0.34, 0.69))

# Save
ggsave(filename = "results/figures/cog_c_kegg.jpg", p, width = 0.9 * 297, height = 210, units = "mm")
