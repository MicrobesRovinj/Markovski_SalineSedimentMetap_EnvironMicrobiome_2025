############################################################
# Libraries used
############################################################

library(stats)
library(knitr)
library(rmarkdown)
library(bookdown)
library(tinytex)
library(kableExtra)
library(vegan)
library(RColorBrewer)
library(taxonomizr)
library(ggpattern)
library(cowplot)
library(rlang)
library(ggh4x)
library(ggsignif)
library(tidyverse)

############################################################
# Custom functions used
############################################################

source("code/functions/r_package_version.R")
source("code/functions/scaleFUN.R")
source("code/functions/to_tibble.R")
source("code/functions/transpose_naaf.R")
source("code/functions/format_labels.R")
source("code/functions/custom_breaks.R")
source("code/functions/custom_limits.R")
source("code/functions/custom_pcoa.R")
source("code/functions/custom_plot_pcoa.R")
source("code/functions/custom_anosim.R")
source("code/functions/custom_wilcox.R")
source("code/functions/format_p_values.R")
source("code/functions/custom_heatmap.R")
source("code/functions/selected_pairwise_wilcox.R")
source("code/functions/p_values_to_labels.R")
source("code/functions/custom_round.R")

############################################################
# Custom ggplot2 theme used
############################################################

source("data/raw/theme.R")

############################################################
# Options for knitr
############################################################

# Set working directory for R code chunks
# (https://bookdown.org/yihui/rmarkdown-cookbook/working-directory.html)
if (require("knitr")) {
    opts_knit$set(root.dir = getwd())
  }

# Avoid false positive error when using knitr::include_graphics()
# (knitr release 1.28, https://github.com/yihui/knitr/release/tag/v1.28)
include_graphics = function(...) {
    knitr::include_graphics(..., error = FALSE)
  }

############################################################
# Permanently setting the CRAN repository
# (https://www.r-bloggers.com/permanently-setting-the-cran-repository/)
############################################################

local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.wu.ac.at/"
  options(repos = r)
})

############################################################
# Option to keep the auxiliary TeX files when rendering
############################################################
options(tinytex.clean = FALSE)

