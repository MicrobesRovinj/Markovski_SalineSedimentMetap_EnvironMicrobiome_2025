#################################################################################################################
# write_package_information.R
#
# Script to add R package information to the README.md file in the project root directory.
# Dependencies: code/functions/r_package_version.R
#
#################################################################################################################

# Read the content of the input md file
readme <- read_lines(file = "README.md")

# Find the index of the string "* R packages:"
start_index <- which(readme == "* R packages:")

# Find the index of the first blank line after the start_index
end_index <- which(readme == "")[which(which(readme == "") > start_index)[1]]

# Delete the lines after "* R packages:" until the first blank line
readme <- readme[-c((start_index + 1) : (end_index - 1))]

# Find the index of the first blank line after the start_index after deleting the lines
end_index <- which(readme == "")[which(which(readme == "") > start_index)[1]]

# Obtain package names and versions
packages <- r_package_version(file_path = ".Rprofile")

# Format package names and versions
packages <- packages %>%
  mutate(name_version = paste0("  * `", name_version, "`"))

# Add R package information after "* R packages:" until the first blank line
readme <- c(readme[1 : start_index], packages$name_version, readme[end_index : length(readme)])

# Write modified md file
write_lines(x = readme, file = "README.md")
