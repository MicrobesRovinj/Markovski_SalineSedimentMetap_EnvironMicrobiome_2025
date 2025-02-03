#################################################################################################################
# r_package_version.R
#
# Function to retrieve the version of R packages used.
#
#################################################################################################################

r_package_version <- function(file_path) {
  
  # Read the file containing package names
  packages <- read_lines(file = file_path)
  
  # Create a tibble from input data
  packages <- tibble(name = packages)
  
  # Filter rows containing package names
  packages <- packages %>%
    filter(str_detect(name, "^library\\(.+\\)$"))
  
  # Remove everything from string except package name
  packages <- packages %>%
    mutate(name = str_replace(name, "^library\\((.+)\\)", "\\1"))
  
  # Iterate over each package name and retrieve its version
  packages <- packages %>%
    mutate(version = map_chr(name, ~ {
      as.character(packageVersion(.x))
    }))
  
  # Combine package name and version in one column
  packages <- packages %>%
    mutate(name_version = paste0(name, " (v. ", version, ")"))
  
  # Return package data
  return(packages)
  
  }
