#################################################################################################################
# plot_heatmap_hydrolases_abc_transporters.R
#
# Script to plot the median relative contribution of different groups of hyrolases and ABC transporters in
# different layers and decay periods at the vegetated and nonvegetated site.
# Dependencies: data/processed/naaf.tsv
#               data/raw/metadata.tsv
#               code/functions/custom_heatmap.R
#               data/raw/theme.R
# Produces: results/figures/heatmap_hydrolases_abc_transporters.jpg
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv(file = "data/processed/naaf.tsv")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Calculate the data for plot generation using the custom function
cazy <- custom_heatmap(input = naaf, database = CAZy, filter_database_entry = NULL, metadata = metadata,
                       filter_ko_names = NULL, filter_ko_table = NULL, summarise_by = NULL)
peptidases <- custom_heatmap(input = naaf, database = KEGG_ko, filter_database_entry = NULL, metadata = metadata,
                             filter_ko_names = "EC:3.4.", filter_ko_table = NULL, summarise_by = NULL)
lipases <- custom_heatmap(input = naaf, database = KEGG_ko, filter_database_entry = NULL, metadata = metadata,
                          filter_ko_names = "lipase", filter_ko_table = NULL, summarise_by = NULL)
abc <- custom_heatmap(input = naaf, database = KEGG_Pathway, filter_database_entry = "map02010", metadata = metadata,
                      filter_ko_names = NULL, filter_ko_table = NULL, summarise_by = NULL)

# Format the ABC transporters substrate names
abc$in_total_grouped <- abc$in_total_grouped %>%
  rename(y_axis = KEGG_Pathway) %>%
  mutate(y_axis = str_replace(y_axis, "^urea$", "Urea")) %>%
  mutate(y_axis = str_replace(y_axis, "^sugar$", "Sugar")) %>%
  mutate(y_axis = str_replace(y_axis, "^polyol$", "Polyol")) %>%
  mutate(y_axis = str_replace(y_axis, "^phosphate$", "Phosphate")) %>%
  mutate(y_axis = str_replace(y_axis, "^peptide$", "Peptide")) %>%
  mutate(y_axis = str_replace(y_axis, "^mineral and organic ion$", "Mineral and\nOrganic Ion")) %>%
  mutate(y_axis = str_replace(y_axis, "^lipid$", "Lipid")) %>%
  mutate(y_axis = str_replace(y_axis, "^amino acid$", "Amino Acid"))

# Bind the calculated data
hydrolases <- bind_rows(CAZymes = cazy$in_total_grouped_summed,
                        `Peptidases` = peptidases$in_total_grouped_summed,
                        Lipases = lipases$in_total_grouped_summed,
                        .id = "y_axis")
heatmap <- bind_rows(Hydrolases = hydrolases,
                     `ABC Transporters` = abc$in_total_grouped,
                     .id = "y_strip")

# Format y_axis, layer and strip_y factor levels
heatmap <- heatmap %>%
  mutate(y_axis = factor(x = y_axis, levels = rev(c("CAZymes", "Peptidases", "Lipases",
                                                    "Sugar", "Peptide", "Amino Acid",
                                                    "Urea", "Lipid", "Polyol", "Phosphate",
                                                    "Mineral and\nOrganic Ion")))) %>%
  mutate(layer = factor(x = layer, levels = c("Top", "Upper Middle", "Lower Middle", "Bottom"))) %>%
  mutate(y_strip = factor(x = y_strip, levels = c("Hydrolases", "ABC Transporters")))

# Generate plot
p <- heatmap %>%
  ggplot(mapping = aes(x = interaction(station, layer),
                       y = y_axis, fill = `NAAF (%)`, group = decay_roots,
                       shape = decay_roots)) +
  geom_point(mapping = aes(hydrolases = `NAAF (%)`), data = ~ subset(., y_strip == "Hydrolases"),
             position = position_dodge(width = 1.0), colour = "black", size = 7.5, stroke = 0.5) +
  geom_point(mapping = aes(abc_transporters = `NAAF (%)`), data = ~ subset(., y_strip == "ABC Transporters"),
             position = position_dodge(width = 1.0), colour = "black", size = 7.5, stroke = 0.5) +
  scale_fill_multi(breaks = list(seq(0.1, 0.7, by = 0.2), seq(1, 4, by = 1)),
                   labels = function(x) format(x = x, digits = 1, nsmall = 1),
                   colours = list(brewer.pal(n = 9, name = "YlGnBu"),
                                  brewer.pal(n = 9, name = "YlOrBr")),
                   guide = list(hydrolases = guide_colourbar(order = 1),
                                abc_transporters = guide_colourbar(order = 2)),
                   aesthetics = c("hydrolases", "abc_transporters")) +
  scale_shape_manual(name = NULL,
                     values = c("Before Decay" = 21,
                                "Decay of Roots\nand Rhizomes" = 22)) +
  labs(x = "Layer and Station", y = "") +
  facet_wrap(facets = vars(y_strip), nrow = 2, scales = "free_y",
             strip.position = "left", axes = "all_y") +
  force_panelsizes(rows = c(3 / 11, 8 / 11)) +
  # Add vertical reference lines (sometimes called rules) to the plot
  geom_vline(colour = "gray80", xintercept = c(2.5, 4.5, 6.5)) +
  geom_vline(linetype = 2, colour = "gray80", xintercept = c(1.5, 3.5, 5.5, 7.5)) +
  theme +
  theme(axis.title.x = element_text(margin = margin(t = 5.5 * 2)),
        axis.text.x = element_text(hjust = 1.0, vjust = 0.5, angle = 90,
                                   margin = margin(t = 5.5 / 2, b = 5.5 / 2, unit = "pt")),
        legend.spacing.y = unit(x = c(5.5 * 44.3, 5.5 * 1.0), units = "pt"),
        strip.text.y = element_text(margin = margin(r = 5.5, unit = "pt"))) +
  guides(shape = guide_legend(override.aes = list(size = 6.5))) +
  guides(x = "axis_nested")

# Load the width data from the previously creatNULL# Load the width data from the previously created plot
# to ensure that the new plot has equal width
load(file = "results/numerical/widths.Rdata")

# Set the width of the new plot to match the width of the previously created plot
# (If the ggplot_gtable() function is not called within the graphics device driver,
# an empty PDF file will be created in the project home directory
# (https://stackoverflow.com/questions/17012518/why-does-this-r-ggplot2-code-bring-up-a-blank-display-device/17013882#17013882).)
pdf(file = NULL)
p <- ggplot_gtable(data = ggplot_build(p))
dev.off()
p$widths <- widths

# Save
ggsave(filename = "results/figures/heatmap_hydrolases_abc_transporters.jpg", plot = p, width = 210, height = 250 * 10.5 / 11, units = "mm")
