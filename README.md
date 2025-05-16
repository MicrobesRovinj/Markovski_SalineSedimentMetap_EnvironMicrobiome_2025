## Shift in the metabolic profile of sediment microbial communities during seagrass decline
 
This is the repository for the manuscript "Shift in the metabolic profile of sediment microbial communities during seagrass decline" written by Marsej Markovski, Mirjana Najdek, Zihao Zhao, Gerhard J. Herndl, and Marino Korlević. The raw sequencing data have been deposited in the European Nucleotide Archive (ENA) at EMBL-EBI under accession number PRJEB75905, while the mass spectrometry proteomics data have been deposited in the ProteomeXchange Consortium via the PRIDE partner repository with the dataset identifier PXD054602. The analysis of these metagenomes and metaproteomes was performed separately and in advance using the Life Science Compute Cluster (LiSC; CUBE – Computational Systems Biology, University of Vienna) and is not part of this repository. This README file contains an overview of the repository structure, information on software dependencies, and instructions how to reproduce and rerun the analysis using outputs from the metagenomic and metaproteomic analysis performed in advance.

### Overview

	project
	|- README                            # the top level description of content (this doc)
	|- LICENSE                           # the license for this project
	|
	|- submission/                       # files necessary for manuscript or supplementary information rendering, e.g. executable R Markdown
	| |- preamble.tex                    # LaTeX in_header file used to format the PDF version of both the manuscript and supplementary information
	| |- manuscript.Rmd                  # executable R Markdown for the manuscript of this study
	| |- manuscript.tex                  # TeX version of the manuscript.Rmd file
	| |- manuscript.pdf                  # PDF version of the manuscript.Rmd file
	| |- manuscript.aux                  # auxiliary file of the manuscript.tex file, used for cross-referencing
	| |- before_body_manuscript.tex      # LaTeX before_body file used to format the PDF version of the manuscript
	| |- supplementary.Rmd               # executable R Markdown for the supplementary information of this study
	| |- supplementary.tex               # TeX version of the supplementary.Rmd file
	| |- supplementary.pdf               # PDF version of the supplementary.Rmd file
	| |- supplementary.aux               # auxiliary file of the supplementary.tex file, used for cross-referencing
	| |- before_body_supplementary.tex   # LaTeX before_body file to format the PDF version of supplementary information
	| |- packages.bib                    # BibTeX formatted references of used packages
	| |- references.bib                  # BibTeX formatted references
	| +- citation_style.csl              # csl file used to format references
	|
	|- data                              # raw, reference, and primary data, are not changed once created
	| |- references/                     # reference files to be used in analysis
	| |- raw/                            # raw data, will not be altered
	| |- processed/                      # data processed during the analysis 
	|
	|- code/                             # any programmatic code
	| +- functions/                      # custom functions
	|
	|- results                           # all output from workflows and analyses
	| |- figures/                        # manuscript or supplementary information figures
	| +- numerical/                      # results of the statistics or other numerical results for manuscript or supplementary information
	|
	|-.gitignore                         # gitinore file for this study
	|-.Rprofile                          # Rprofile file containing information on which R libraries to load, information on functions,
	|                                    # rendering options for knitr and rmarkdown, etc.
	+- Makefile                          # executable Makefile for this study

### How to regenerate this repository

#### Dependencies
* GNU Bash (v. 4.2.46(2)), should be located in user's PATH
* GNU Make (v. 4.3), should be located in user's PATH
* R (v. 4.5.0), should be located in user's PATH
* R packages:
  * `stats (v. 4.5.0)`
  * `knitr (v. 1.50)`
  * `rmarkdown (v. 2.29)`
  * `bookdown (v. 0.43)`
  * `tinytex (v. 0.57)`
  * `kableExtra (v. 1.4.0)`
  * `vegan (v. 2.6.10)`
  * `RColorBrewer (v. 1.1.3)`
  * `taxonomizr (v. 0.11.1)`
  * `ggpattern (v. 1.1.4)`
  * `cowplot (v. 1.1.3)`
  * `rlang (v. 1.1.6)`
  * `ggh4x (v. 0.3.0)`
  * `ggsignif (v. 0.6.4)`
  * `tidyverse (v. 2.0.0)`

#### Running analysis
The manuscript and supplementary information can be regenerated on a Linux computer by running the following commands:
```
git clone https://github.com/MicrobesRovinj/Markovski_SalineSedimentMetap_EnvironMicrobiome_2025.git
cd Markovski_SalineSedimentMetap_EnvironMicrobiome_2025/
make all
```
If something goes wrong and the analysis needs to be restarted run the following command from the project home directory before rerunning the analysis:
```
make clean
```

