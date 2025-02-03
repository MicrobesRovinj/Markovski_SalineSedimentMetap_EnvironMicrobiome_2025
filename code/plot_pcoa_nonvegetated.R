#################################################################################################################
# plot_pcoa_nonvegetated.R
#
# Script to generate PCoA figures. Samples from the nonvegetated station are plotted. All proteins and proteins
# classified only into COG category C are plotted.
# Dependencies: data/processed/naaf.tsv
#               data/raw/metadata.tsv
#               code/functions/custom_plot_pcoa.R
# Produces: results/figures/pcoa_nonvegetated.jpg
#
#################################################################################################################

# Load NAAFs metaproteomic data
naaf <- read_tsv(file = "data/processed/naaf.tsv")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Generate plots using custom function
p_pcoa_nonvegetated <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                        filter_station = "Nonvegetated", filter_layer = NULL, filter_cog = NULL,
                                        add = NULL, xlim = c(-0.50, 0.50), ylim = c(-0.35, 0.45),
                                        ... = labs(title = "All Proteins"),
                                        ... = theme(legend.position = "none"))
p_pcoa_nonvegetated_cog <- custom_plot_pcoa(naaf = naaf, metadata = metadata,
                                            filter_station = "Nonvegetated", filter_layer = NULL, filter_cog = "C",
                                            add = "lingoes", xlim = c(-0.60, 0.40), ylim = c(-0.45, 0.35),
                                            ... = labs(title = "Category C"))

# Extract legend
legend <- get_legend(p_pcoa_nonvegetated_cog$p_pcoa)
# Remove legend from plot after extraction
p_pcoa_nonvegetated_cog$p_pcoa <- p_pcoa_nonvegetated_cog$p_pcoa +
  theme(legend.position = "none")

# Combine plots
p <- plot_grid(p_pcoa_nonvegetated$p_pcoa, p_pcoa_nonvegetated_cog$p_pcoa)

# Combine plots and legend
p <- ggdraw() +
  draw_plot(plot = p, x = 0.0, y = 0.0, width = 0.85, height = 1) +
  draw_plot(plot = legend, x = 0.853, y = 0.15, width = 0, height = 1)

# Save
ggsave(filename = "results/figures/pcoa_nonvegetated.jpg", plot = p, width = 297, height = 210 / 2, units = "mm")
