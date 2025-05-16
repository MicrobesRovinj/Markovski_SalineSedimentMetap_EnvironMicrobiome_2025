#################################################################################################################
# plot_heatmap_fermentation_dsr.R
#
# Script to plot the median relative contribution of different enzymes involved in fermentation and
# dissimilatory sulphate reduction in different layers and decay periods at the vegetated and nonvegetated site.
# Dependencies: data/processed/naaf.tsv
#               data/raw/metadata.tsv
#               data/raw/fermentation.tsv
#               data/raw/dsr.tsv
#               code/functions/custom_heatmap.R
#               data/raw/theme.R
# Produces: results/figures/heatmap_fermentation_dsr.jpg
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv(file = "data/processed/naaf.tsv")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Load the data for KEGG KO entries involved in fermentation and dissimilatory
# sulphate reduction
fermentation <- read_tsv(file = "data/raw/fermentation.tsv", col_names = c("name", "enzyme_product", "KEGG_ko", "KO_name"))
dsr <- read_tsv(file = "data/raw/dsr.tsv", col_names = c("name", "KEGG_ko", "KO_name"))

# Calculate the data for plot generation using the custom function
fermentation <- custom_heatmap(input = naaf, database = KEGG_ko, filter_database_entry = NULL, metadata = metadata,
                               filter_ko_names = NULL, filter_ko_table = fermentation, summarise_by = name)
dsr <- custom_heatmap(input = naaf, database = KEGG_ko, filter_database_entry = NULL, metadata = metadata,
                      filter_ko_names = NULL, filter_ko_table = dsr, summarise_by = name)

# Format the names of the enzymes involved in fermentation and dissimilatory
# sulphate reduction
fermentation$in_total_grouped <- fermentation$in_total_grouped %>%
  rename(y_axis = KEGG_ko) %>%
  mutate(y_axis = str_replace(y_axis, "^acetate kinase$", "Acetate Kinase")) %>%
  mutate(y_axis = str_replace(y_axis, "^acetyl-CoA hydrolase$", "Acetyl-CoA\nHydrolase")) %>%
  mutate(y_axis = str_replace(y_axis, "^alcohol dehydrogenase$", "Alcohol\nDehydrogenase")) %>%
  mutate(y_axis = str_replace(y_axis, "^formate dehydrogenase$", "Formate\nDehydrogenase")) %>%
  mutate(y_axis = str_replace(y_axis, "^lactate dehydrogenase$", "Lactate\nDehydrogenase")) %>%
  mutate(y_axis = str_replace(y_axis, "^pyruvate:ferredoxin oxidoreductase$", "Pyruvate:Ferredoxin\nOxidoreductase")) %>%
  mutate(y_axis = str_replace(y_axis, "^pyruvate formate-lyase$", "Pyruvate\nFormate-Lyase"))
dsr$in_total_grouped <- dsr$in_total_grouped %>%
  rename(y_axis = KEGG_ko) %>%
  mutate(y_axis = str_replace(y_axis, "^sulphate adenylyltransferase$", "Sulphate\nAdenylyltransferase")) %>%
  mutate(y_axis = str_replace(y_axis, "^adenylylsulphate reductase$", "Adenylylsulphate\nReductase")) %>%
  mutate(y_axis = str_replace(y_axis, "^dissimilatory sulphite reductase$", "Dissimilatory\nSulphite\nReductase"))

# Bind the calculated data
heatmap <- bind_rows(Fermentation = fermentation$in_total_grouped,
                     `Dissimilatory\nSulphate Reduction` = dsr$in_total_grouped,
                     .id = "y_strip")

# Format y_axis, layer and strip_y factor levels
heatmap <- heatmap %>%
  mutate(y_axis = factor(x = y_axis, levels = rev(c("Pyruvate:Ferredoxin\nOxidoreductase",
                                                    "Pyruvate\nFormate-Lyase",
                                                    "Acetyl-CoA\nHydrolase",
                                                    "Acetate Kinase",
                                                    "Alcohol\nDehydrogenase",
                                                    "Formate\nDehydrogenase",
                                                    "Lactate\nDehydrogenase",
                                                    "Sulphate\nAdenylyltransferase",
                                                    "Adenylylsulphate\nReductase",
                                                    "Dissimilatory\nSulphite\nReductase")))) %>%
  mutate(layer = factor(x = layer, levels = c("Top", "Upper Middle", "Lower Middle", "Bottom"))) %>%
  mutate(y_strip = factor(x = y_strip, levels = c("Fermentation", "Dissimilatory\nSulphate Reduction")))

# Generate plot
p <- heatmap %>%
  ggplot(mapping = aes(x = interaction(station, layer),
                       y = y_axis, fill = `NAAF (%)`, group = decay_roots,
                       shape = decay_roots)) +
  geom_point(mapping = aes(fermentation = `NAAF (%)`), data = ~ subset(., y_strip == "Fermentation"),
             position = position_dodge(width = 1.0), colour = "black", size = 7.5, stroke = 0.5) +
  geom_point(mapping = aes(dsr = `NAAF (%)`), data = ~ subset(., y_strip == "Dissimilatory\nSulphate Reduction"),
             position = position_dodge(width = 1.0), colour = "black", size = 7.5, stroke = 0.5) +
  scale_fill_multi(breaks = list(seq(0.1, 0.3, by = 0.1), seq(0.3, 2.3, by = 1.0)),
                   labels = function(x) format(x = x, digits = 1, nsmall = 1),
                   colours = list(brewer.pal(n = 9, name = "YlGnBu"),
                                  brewer.pal(n = 9, name = "YlOrBr")),
                   guide = list(fermentation = guide_colourbar(order = 1),
                                dsr = guide_colourbar(order = 2)),
                   aesthetics = c("fermentation", "dsr")) +
  scale_shape_manual(name = NULL,
                     values = c("Before Decline" = 21,
                                "Meadow Decline" = 22)) +
  labs(x = "Layer and Site", y = "") +
  facet_wrap(facets = vars(y_strip), nrow = 2, scales = "free_y",
             strip.position = "left", axes = "all_y") +
  force_panelsizes(rows = c(7 / 10, 3 / 10)) +
  # Add vertical reference lines (sometimes called rules) to the plot
  geom_vline(colour = "gray80", xintercept = c(2.5, 4.5, 6.5)) +
  geom_vline(linetype = 2, colour = "gray80", xintercept = c(1.5, 3.5, 5.5, 7.5)) +
  theme +
  theme(axis.title.x = element_text(margin = margin(t = 5.5 * 2)),
        axis.text.x = element_text(hjust = 1.0, vjust = 0.5, angle = 90,
                                   margin = margin(t = 5.5 / 2, b = 5.5 / 2, unit = "pt")),
        legend.spacing.y = unit(x = c(5.5 * 0.85, 5.5 * 1.0), units = "pt"),
        strip.text.y = element_text(margin = margin(r = 5.5, unit = "pt"))) +
  guides(shape = guide_legend(override.aes = list(size = 6.5))) +
  guides(x = "axis_nested")

# To ensure equal width in all heatmap plots, extract and save the
# width of the current plot
# (If the ggplot_gtable() function is not called within the graphics device driver,
# an empty PDF file will be created in the project home directory
# (https://stackoverflow.com/questions/17012518/why-does-this-r-ggplot2-code-bring-up-a-blank-display-device/17013882#17013882).)
pdf(file = NULL)
widths <- ggplot_gtable(data = ggplot_build(plot = p))$widths
dev.off()
save(widths, file = "results/numerical/widths.Rdata")

# Save
ggsave(filename = "results/figures/heatmap_fermentation_dsr.jpg", plot = p, width = 210, height = 250 * 10 / 11, units = "mm")
