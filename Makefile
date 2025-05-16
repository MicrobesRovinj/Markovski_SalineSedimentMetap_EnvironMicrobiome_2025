# Run all
.PHONY : all

all : README.md\
      submission/manuscript.pdf\
      submission/supplementary.pdf

#########################################################################################
#
# Part 1: Prepare software for analysis 
#
# 	Before we start the analysis, we need to make some preparations, such as:
# check if essential commands/software are available, define variables, update
# the name of the repository/project directory, update the year, etc.
#
#########################################################################################

# Define the essential commands/software required for the analysis
EXECUTABLES = bash make R

# Check whether the required commands/software are available 
software_check := $(foreach exec, $(EXECUTABLES),\
                  $(if $(shell command -v $(exec)),\
                  "$(exec) present in PATH!",\
                   $(error "No $(exec) in PATH!")))

# Define variables for directories
export PROJECT_DIR := $(shell basename $(PWD))
export FUN := code/functions
export RAW := data/raw
export PROC := data/processed
export REFS := data/references
export FIGS := results/figures
export NUM := results/numerical
export FINAL := submission

# Update the name of the GitHub repository/project directory in README.md and manuscipt.Rmd
OLD_DIR_README_GIT := $(shell sed -n 's/^git clone https:\/\/github.com\/MicrobesRovinj\/\(.*\).git/\1/p' README.md)
OLD_DIR_README_CD := $(shell sed -n 's/^cd \(.*\)\//\1/p' README.md)
OLD_DIR_MANUSCRIPT := $(shell sed -n 's/.*(<https:\/\/github.com\/MicrobesRovinj\/\(.*\)>).*/\1/p' $(FINAL)/manuscript.Rmd)

.PHONY : check_dir_name

check_dir_name :
ifneq ($(PROJECT_DIR), $(OLD_DIR_README_GIT))
	$(shell sed -i 's/\(^git clone https:\/\/github.com\/MicrobesRovinj\/\).*\(.git\)/\1$(PROJECT_DIR)\2/' README.md)
	@echo "GitHub repository name has been updated in README.md."
else
	@echo "GitHub repository name is the same as in README.md." 
endif

ifneq ($(PROJECT_DIR), $(OLD_DIR_README_CD))
	$(shell sed -i 's/\(^cd \).*\(\/\)/\1$(PROJECT_DIR)\2/' README.md)
	@echo "Project directory name has been updated in README.md"
else
	@echo "Project directory name is the same as in README.md." 
endif

ifneq ($(PROJECT_DIR), $(OLD_DIR_MANUSCRIPT))
	$(shell sed -i 's/\(.*(<https:\/\/github.com\/MicrobesRovinj\/\).*\(>).*\)/\1$(PROJECT_DIR)\2/' $(FINAL)/manuscript.Rmd)
	@echo "GitHub repository name has been updated in manuscript.Rmd."
else
	@echo "GitHub repository name is the same as in manuscript.Rmd." 
endif

# Update the year in LICENSE.md
OLD_YEAR := $(shell sed -n 's/^Copyright (c) \([^ ]*\) .*/\1/p' LICENSE.md)
NEW_YEAR := $(shell echo $(PROJECT_DIR) | sed 's/^.*_\([^_]*\)$$/\1/')

.PHONY : check_year
check_year :
ifneq ($(NEW_YEAR), $(OLD_YEAR))
	$(shell sed -i 's/\(^Copyright (c)\) [^ ]* \(.*\)/\1 $(NEW_YEAR) \2/' LICENSE.md)
	@echo "Year has been updated in LICENSE.md."
else
	@echo "Year is the same as in LICENSE.md." 
endif

# Update the software and R package information in README.md 
README.md : code/write_software_version.R\
            code/write_package_information.R\
            .Rprofile\
            $(FUN)/r_package_version.R\
            check_dir_name\
            check_year
	R -e "source('code/write_software_version.R')"
	R -e "source('code/write_package_information.R')"

#########################################################################################
#
# Part 2: Create the reference files and tidy the metaproteomic data
#
# 	To find the taxonomic names of the identified proteins we need to create
# the SQLite database with the R package taxonomizr. After the full taxonomy has been
# assigned, we need to filter out only bacterial and archaeal entries as this is the
# topic of our research. Finally, we need to calculate the NAAF for each identified
# protein.
#
#########################################################################################

# Download the taxonomic data from NCBI (names and nodes) and create the SQLite database
$(REFS)/names.dmp\
$(REFS)/nodes.dmp\
$(REFS)/nameNode.sqlite &: code/get_taxonomy.R
	R -e "source('code/get_taxonomy.R')"
	mv names.dmp $(REFS)/
	mv nodes.dmp $(REFS)/

# Decompress the metaproteomic data
$(PROC)/metaproteomic_data.tsv : $(RAW)/metaproteomic_data.tsv.gz
	gzip -dkc $(RAW)/metaproteomic_data.tsv.gz > $(PROC)/metaproteomic_data.tsv

# Assign the full taxonomy and select only bacterial and archaeal entries
$(PROC)/formatted_metaproteomic_data.tsv &: code/format_protein_taxonomy.R\
                                            $(PROC)/metaproteomic_data.tsv\
                                            $(FUN)/to_tibble.R\
                                            $(REFS)/nameNode.sqlite
	R -e "source('code/format_protein_taxonomy.R')"

# Calculate the NAAF
$(PROC)/naaf.tsv : code/calculate_naaf.R\
                   $(PROC)/formatted_metaproteomic_data.tsv
	R -e "source('code/calculate_naaf.R')"

#########################################################################################
#
# Part 3: Calculate parameters
#
# 	Perform the calculation of various parameters used in the creation of plots or
# in the rendering of the manuscript and/or supplementary information.
#
#########################################################################################

# Calculate the parameters of alpha diversity
$(NUM)/alpha.Rdata : code/calculate_alpha.R\
                     $(PROC)/naaf.tsv\
                     $(FUN)/transpose_naaf.R\
                     $(RAW)/metadata.tsv\
                     $(FUN)/format_labels.R
	R -e "source('code/calculate_alpha.R')"

# Calculate ANOSIM
$(NUM)/anosim_all.Rdata\
$(NUM)/anosim_C.Rdata &: code/calculate_anosim.R\
                         $(PROC)/naaf.tsv\
                         $(RAW)/metadata.tsv\
                         $(FUN)/custom_anosim.R\
                         $(FUN)/transpose_naaf.R\
                         $(FUN)/format_labels.R
	R -e "source('code/calculate_anosim.R')"

# Calculate the parameters of each COG functional category
$(NUM)/cog_number.Rdata\
$(NUM)/cog_naaf.Rdata &: code/calculate_cog.R\
                         $(PROC)/naaf.tsv
	R -e "source('code/calculate_cog.R')"

# Calculate the relative contribution of KO entries within the functional COG
# category C
$(NUM)/cog_c_kegg.Rdata : code/calculate_cog_c_kegg.R\
                          $(PROC)/naaf.tsv
	wget https://rest.kegg.jp/list/ko -O $(RAW)/ko_names.tsv
	R -e "source('code/calculate_cog_c_kegg.R')"

#########################################################################################
#
# Part 4: Generate figures
#
# 	Run scripts to generate figures.
#
#########################################################################################

# Plot the alpha diversity parameters
$(FIGS)/alpha.jpg : code/plot_alpha.R\
                    $(NUM)/alpha.Rdata\
                    $(FUN)/selected_pairwise_wilcox.R\
                    $(FUN)/custom_wilcox.R\
                    $(FUN)/p_values_to_labels.R\
                    $(RAW)/colour_station.R\
                    $(RAW)/pattern_period.R\
                    $(RAW)/theme.R
	R -e "source('code/plot_alpha.R')"

# Construct the PCoA plots
$(FIGS)/pcoa_nonvegetated.jpg\
$(FIGS)/pcoa_layer.jpg &: code/plot_pcoa_nonvegetated.R\
                          code/plot_pcoa_layer.R\
                          $(PROC)/naaf.tsv\
                          $(RAW)/metadata.tsv\
                          $(FUN)/custom_plot_pcoa.R\
                          $(FUN)/transpose_naaf.R\
                          $(FUN)/format_labels.R\
                          $(FUN)/custom_pcoa.R\
                          $(RAW)/colour_layer.R\
                          $(RAW)/shape_period.R\
                          $(RAW)/colour_period.R\
                          $(RAW)/stroke_period.R\
                          $(RAW)/shape_station.R\
                          $(RAW)/theme.R
	R -e "source('code/plot_pcoa_nonvegetated.R')"
	R -e "source('code/plot_pcoa_layer.R')"

# Plot the most abundant KO entries within the functional COG category C
$(FIGS)/cog_c_kegg.jpg : code/plot_cog_c_kegg.R\
                         $(NUM)/cog_c_kegg.Rdata\
                         $(RAW)/colour_kegg.R\
                         $(FUN)/transpose_naaf.R\
                         $(RAW)/metadata.tsv\
                         $(FUN)/format_labels.R\
                         $(FUN)/custom_wilcox.R\
                         $(FUN)/p_values_to_labels.R\
                         $(RAW)/pattern_period.R\
                         $(RAW)/theme.R
	R -e "source('code/plot_cog_c_kegg.R')"

# Construct the heatmap plots
$(FIGS)/heatmap_hydrolases_abc_transporters.jpg\
$(FIGS)/heatmap_fermentation_dsr.jpg &: code/plot_heatmap_hydrolases_abc_transporters.R\
                                        code/plot_heatmap_fermentation_dsr.R\
                                        $(PROC)/naaf.tsv\
                                        $(RAW)/metadata.tsv\
                                        $(FUN)/custom_heatmap.R\
                                        $(RAW)/ko_names.tsv\
                                        $(RAW)/abc_description.tsv\
                                        $(FUN)/transpose_naaf.R\
                                        $(FUN)/format_labels.R\
                                        $(RAW)/theme.R\
                                        $(RAW)/fermentation.tsv\
                                        $(RAW)/dsr.tsv
	R -e "source('code/plot_heatmap_fermentation_dsr.R')"
	R -e "source('code/plot_heatmap_hydrolases_abc_transporters.R')"

##########################################################################################
#
# Part 5: Combine everything together 
#
# 	Render the manuscript and the supplementary information.
#
#########################################################################################

$(FINAL)/manuscript.pdf\
$(FINAL)/supplementary.pdf &: $(FINAL)/manuscript.Rmd\
                              $(FINAL)/references.bib\
                              $(FINAL)/citation_style.csl\
                              $(FINAL)/preamble.tex\
                              $(FINAL)/before_body_manuscript.tex\
                              .Rprofile\
                              $(RAW)/metagenomes_seq_num.tsv\
                              $(RAW)/metagenomes_contig_statistics.tsv\
                              $(RAW)/metagenomes_annotated_cds_num.tsv\
                              $(PROC)/metaproteomic_data.tsv\
                              $(PROC)/formatted_metaproteomic_data.tsv\
                              $(NUM)/alpha.Rdata\
                              $(NUM)/anosim_all.Rdata\
                              $(NUM)/anosim_C.Rdata\
                              $(NUM)/cog_number.Rdata\
                              $(NUM)/cog_naaf.Rdata\
                              $(NUM)/cog_c_kegg.Rdata\
                              $(PROC)/naaf.tsv\
                              $(RAW)/metadata.tsv\
                              $(RAW)/ko_names.tsv\
                              $(RAW)/fermentation.tsv\
                              $(RAW)/dsr.tsv\
                              $(FIGS)/alpha.jpg\
                              $(FIGS)/pcoa_nonvegetated.jpg\
                              $(FIGS)/pcoa_layer.jpg\
                              $(FIGS)/cog_c_kegg.jpg\
                              $(FIGS)/heatmap_hydrolases_abc_transporters.jpg\
                              $(FIGS)/heatmap_fermentation_dsr.jpg\
                              $(FINAL)/supplementary.Rmd\
                              $(FINAL)/before_body_supplementary.tex\
                              $(RAW)/cog_categories.tsv\
                              $(RAW)/metabolism.tsv
	R -e 'render("$(FINAL)/manuscript.Rmd", clean = FALSE)'
	R -e 'render("$(FINAL)/supplementary.Rmd", clean = FALSE)'
	rm $(FINAL)/*.knit.md $(FINAL)/*.log

# Clean
.PHONY : clean

clean :
	find $(RAW)/ -type f -not -name "README.md"\
                             -not -name "theme.R"\
                             -not -name "metaproteomic_data.tsv.gz"\
                             -not -name "metadata.tsv"\
                             -not -name "colour_layer.R"\
                             -not -name "colour_period.R"\
                             -not -name "colour_station.R"\
                             -not -name "pattern_period.R"\
                             -not -name "shape_period.R"\
                             -not -name "shape_station.R"\
                             -not -name "stroke_period.R"\
                             -not -name "cog_categories.tsv"\
                             -not -name "colour_kegg.R"\
                             -not -name "ko_names.tsv"\
                             -not -name "abc_description.tsv"\
                             -not -name "fermentation.tsv"\
                             -not -name "dsr.tsv"\
                             -not -name "metabolism.tsv"\
                             -not -name "metagenomes_annotated_cds_num.tsv"\
                             -not -name "metagenomes_contig_statistics.tsv"\
                             -not -name "metagenomes_seq_num.tsv"\
                             -delete
	find $(PROC)/ -type f -not -name "README.md" -delete
	find $(REFS)/ -type f -not -name "README.md" -delete
	find $(FIGS)/ -type f -not -name "README.md" -delete
	find $(NUM)/ -type f -not -name "README.md" -delete
	find $(FINAL)/ -type f -not -name "preamble.tex"\
                               -not -name "manuscript.Rmd"\
                               -not -name "manuscript.aux"\
                               -not -name "before_body_manuscript.tex"\
                               -not -name "supplementary.Rmd"\
                               -not -name "supplementary.aux"\
                               -not -name "before_body_supplementary.tex"\
                               -not -name "packages.bib"\
                               -not -name "references.bib"\
                               -not -name "citation_style.csl"\
                               -not -name "README.md"\
                               -delete 

