#################################################################################################################
# custom_plot_pcoa.R
#
# Function to customise PCoA plotting.
# Dependencies: code/functions/transpose_naaf.R
#               code/functions/format_labels.R
#               code/functions/custom_pcoa.R
#               data/raw/colour_layer.R
#               data/raw/shape_period.R
#               data/raw/stroke_period.R
#               data/raw/colour_period.R
#               data/raw/shape_station.R
#               data/raw/theme.R
#
#################################################################################################################

custom_plot_pcoa <- function(naaf, metadata, filter_station = NULL, filter_layer = NULL,
                             filter_cog = NULL, add = NULL, xlim = NULL, ylim = NULL, ...) {

  # Filter COG category
  if(!is.null(filter_cog)) {
    naaf <- naaf %>%
      filter(COG_category %in% filter_cog) %>%
      mutate(across(.cols = starts_with("MM_"), .fns = ~ .x / sum(.x, na.rm = TRUE)))
    }

  # Transpose the NAAF data
  transposed_naaf <- transpose_naaf(x = naaf, id_column = Accession)

  # Format plot labels using custom function
  metadata <- format_labels(x = metadata)

  # Join transposed NAAF data and metadata
  transposed_naaf_metadata <- left_join(x = transposed_naaf, y = metadata, by = c("ID" = "ID"))

  # Select samples for plotting
  transposed_naaf_metadata <- transposed_naaf_metadata %>%
    filter(station %in% filter_station)
  if(!is.null(filter_layer)) {
    transposed_naaf_metadata <- transposed_naaf_metadata %>%
      filter(layer %in% filter_layer)
  }
  transposed_naaf_metadata <- transposed_naaf_metadata %>%
    select(ID, starts_with("19181-"), starts_with("20151-"))

  # Calculate PCoA
  pcoa <- custom_pcoa(data = transposed_naaf_metadata, add = add, metadata = metadata)

  # Load plot customisation data
  source(file = "data/raw/colour_layer.R")
  source(file = "data/raw/shape_period.R")
  source(file = "data/raw/stroke_period.R")
  source(file = "data/raw/colour_period.R")
  source(file = "data/raw/shape_station.R")

  # Generate plot
  p_pcoa <- ggplot()

  # Case when selected stations are plotted
  if (length(filter_station) == 1) {
    if(is.null(filter_layer)) {
      p_pcoa <- p_pcoa +
      geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, stroke = decay_roots), shape = 21, size = 4) +
      geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, fill = layer), shape = 21, size = 4, stroke = 0.5) +
      geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, shape = decay_roots), size = 5, stroke = 0.3) +
      scale_fill_manual(name = NULL,
                        breaks = names(colour_layer),
                        values = colour_layer) +
      scale_shape_manual(name = NULL,
                         breaks = names(shape_period),
                         values = shape_period) +
      scale_discrete_manual(aesthetics = "stroke",
                            name = NULL,
                            breaks = names(stroke_period),
                            values = stroke_period) +
      guides(fill = guide_legend(order = 1))
    # Case when selected stations and layers are plotted
    } else {
      p_pcoa <- p_pcoa +
        geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, fill = decay_roots), shape = 21, size = 2.5, stroke = 0.5) +
        geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, shape = decay_roots), size = 3, stroke = 0.3) +
        scale_fill_manual(name = NULL,
                          breaks = names(colour_period),
                          values = colour_period) +
        scale_shape_manual(name = NULL,
                           breaks = names(shape_period),
                           values = shape_period) +
        guides(shape = guide_legend(override.aes = list(size = 3.5)))
    }
  }

  # Case when all samples are plotted
  if (length(filter_station) > 1) {
    p_pcoa <- p_pcoa +
      geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, fill = layer, shape = station), size = 5, stroke = 0.5) +
      geom_point(data = pcoa$coordinates, aes(x = A1, y = A2, shape = decay_roots), size = 6, stroke = 0.3) +
      scale_fill_manual(name = NULL,
                        breaks = names(colour_layer),
                        values = colour_layer) +
      scale_shape_manual(name = NULL,
                         breaks = names(shape_station),
                         values = shape_station) +
      guides(fill = guide_legend(override.aes = list(shape = 22, size = 5.0), order = 1),
             shape = guide_legend(override.aes = list(size = 5.0)), order = 2)
    }

  # Add additional customisation present in any case
  p_pcoa <- p_pcoa +
    labs(x = paste0("PCoA I (", format(round(pcoa$spe_b_pcoa$eig[1] / sum(pcoa$spe_b_pcoa$eig) * 100, digits = 1), nsmall = 1), " %)"), 
         y = paste0("PCoA II (", format(round(pcoa$spe_b_pcoa$eig[2] / sum(pcoa$spe_b_pcoa$eig) * 100, digits = 1), nsmall = 1), " %)")) +
    scale_x_continuous(labels = scaleFUN) +
    scale_y_continuous(labels = scaleFUN) +
    theme
  
  # Set axis xlim and ylim
  # (Check if any element of vector xlim or ylim is NULL and if it is do not set axis limits)
  if(is.null(xlim) || is.null(ylim)) {
    p_pcoa <- p_pcoa +
      coord_fixed(ratio = 1)
    } else {
      p_pcoa <- p_pcoa +
        coord_fixed(ratio = 1, xlim = xlim, ylim = ylim)
      }

  # Use additional arguments if present
  p_pcoa <- p_pcoa +
    list(...)

  # Return outputs
  list(pcoa = pcoa,
       p_pcoa = p_pcoa)
  
  }
