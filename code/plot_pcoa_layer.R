#################################################################################################################
# plot_pcoa_layer.R
#
# Script to generate PCoA figures. Samples from each nonvegetated station's layer are plotted. All proteins and
# proteins classified only into COG category C are plotted.
# Dependencies: data/processed/naaf.tsv
#               data/raw/metadata.tsv
#               code/functions/custom_plot_pcoa.R
# Produces: results/figures/pcoa_layer.jpg
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv(file = "data/processed/naaf.tsv")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Define COG category
cog_category <- "C"

# Set axis xlim and ylim
xlim <- c(-0.65, 0.60)
ylim <- c(-0.40, 0.60)

# Set custom theme values
custom_theme <- theme(# Axis
                      axis.title = element_text(size = 10),                    
                      axis.text = element_text(size = 8))

# Generate plots using custom function
p_pcoa_nonvegetated_top <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                            filter_station = "Nonvegetated", filter_layer = "Top", filter_cog = NULL,
                                            add = NULL, xlim = xlim, ylim = ylim,
                                            ... = custom_theme,
                                            ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_top_cog <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                filter_station = "Nonvegetated", filter_layer = "Top", filter_cog = cog_category,
                                                add = NULL, xlim = xlim, ylim = ylim,
                                                ... = custom_theme,
                                                ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_upper_middle <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                     filter_station = "Nonvegetated", filter_layer = "Upper Middle", filter_cog = NULL,
                                                     add = NULL, xlim = xlim, ylim = ylim,
                                                     ... = custom_theme,
                                                     ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_upper_middle_cog <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                         filter_station = "Nonvegetated", filter_layer = "Upper Middle", filter_cog = cog_category,
                                                         add = NULL, xlim = xlim, ylim = ylim,
                                                         ... = custom_theme,
                                                         ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_lower_middle <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                     filter_station = "Nonvegetated", filter_layer = "Lower Middle", filter_cog = NULL,
                                                     add = NULL, xlim = xlim, ylim = ylim,
                                                     ... = custom_theme,
                                                     ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_lower_middle_cog <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                         filter_station = "Nonvegetated", filter_layer = "Lower Middle", filter_cog = cog_category,
                                                         add = NULL, xlim = xlim, ylim = ylim,
                                                         ... = custom_theme,
                                                         ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_bottom <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                               filter_station = "Nonvegetated", filter_layer = "Bottom", filter_cog = NULL,
                                               add = NULL, xlim = xlim, ylim = ylim,
                                               ... = custom_theme,
                                               ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_bottom_cog <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                                   filter_station = "Nonvegetated", filter_layer = "Bottom", filter_cog = cog_category,
                                                   add = NULL, xlim = xlim, ylim = ylim,
                                                   ... = custom_theme)
# Extract legend
legend <- get_legend(p_pcoa_nonvegetated_bottom_cog$p_pcoa)
# Remove legend from plot after extraction
p_pcoa_nonvegetated_bottom_cog$p_pcoa <- p_pcoa_nonvegetated_bottom_cog$p_pcoa +
  theme(legend.position = "none")

# Combine plots
p <- plot_grid(p_pcoa_nonvegetated_top$p_pcoa, p_pcoa_nonvegetated_top_cog$p_pcoa,
               p_pcoa_nonvegetated_upper_middle$p_pcoa, p_pcoa_nonvegetated_upper_middle_cog$p_pcoa,
               p_pcoa_nonvegetated_lower_middle$p_pcoa, p_pcoa_nonvegetated_lower_middle_cog$p_pcoa,
               p_pcoa_nonvegetated_bottom$p_pcoa, p_pcoa_nonvegetated_bottom_cog$p_pcoa,
               nrow = 4, ncol = 2)

# Combine plots and labels
p <- ggdraw() +
  draw_label("All Proteins", x = 0.260, y = 0.965, hjust = 0.5,  fontfamily = "Times", fontface = "bold", size = 16) +
  draw_label("Category C", x = 0.660, y = 0.965, hjust = 0.5,  fontfamily = "Times", fontface = "bold", size = 16) +
  draw_label("Top", x = 0.025, y = 0.850, vjust = 0.5, hjust = 0.5, angle = 90, fontfamily = "Times", fontface = "bold", size = 16,) +
  draw_label("Upper Middle", x = 0.025, y = 0.610, vjust = 0.5, hjust = 0.5, angle = 90, fontfamily = "Times", fontface = "bold", size = 16,) +
  draw_label("Lower Middle", x = 0.025, y = 0.375, vjust = 0.5, hjust = 0.5, angle = 90, fontfamily = "Times", fontface = "bold", size = 16) +
  draw_label("Bottom", x = 0.025, y = 0.140, vjust = 0.5, hjust = 0.5, angle = 90, fontfamily = "Times", fontface = "bold", size = 16) +
  draw_plot(p, x = 0.030, y = 0.000, width = 0.80, height = 0.95) +
  draw_plot(legend, x = 0.815, y = 0.055, width = 0, height = 1)

# Save
ggsave(filename = "results/figures/pcoa_layer.jpg", plot = p, width = 210, height = 297 * 0.85, units = "mm")
