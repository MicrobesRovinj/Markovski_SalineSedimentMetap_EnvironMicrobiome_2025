############################################################
# theme.R
#
# Script containing custom ggplot2 theme.
#
############################################################

theme <- theme(# General customisation of line, text, etc. elements
               line = element_line(colour = "black"),
               rect = element_rect(colour = "black"),
               text = element_text(family = "Times", colour = "black"),
               # Axis
               axis.title = element_text(size = 14),
               axis.text = element_text(colour = "black", size = 12),
               axis.ticks = element_line(),
               axis.line = element_line(),
               # Legend
               legend.margin = margin(t = 5.5, r = 0, b = 0, l = 0, unit = "pt"),
               legend.key = element_blank(),
               legend.text = element_text(size = 12),
               legend.justification = c("left", "bottom"),
               # Panel
               panel.background = element_blank(),
               panel.border = element_rect(fill = NA),
               # Plot
               plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
               # Strip
               strip.background = element_blank(),
               strip.placement = "outside",
               strip.text = element_text(face = "bold", size = 18),
               strip.text.y = element_text(margin = margin(r = 25, unit = "pt")))
