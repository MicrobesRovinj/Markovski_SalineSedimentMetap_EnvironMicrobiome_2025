#################################################################################################################
# write_software_version.R
#
# Script to add software version to the README.md file in the project root directory.
#
#################################################################################################################

# Read the content of the input md file
readme <- read_lines(file = "README.md")

# Find indices of lines requiring update
bash_index <- grep(pattern = "^\\* GNU bash \\(v\\.", x = readme)
make_index <- grep(pattern = "^\\* GNU Make \\(v\\.", x = readme)
r_index <- grep(pattern = "^\\* R \\(v\\.", x = readme)
indices <- c(bash = bash_index, make = make_index, r = r_index)

# Find software versions
bash_version <- system("bash --version", intern = TRUE)[1]
make_version <- system("make --version", intern = TRUE)[1]
r_version <- system("R --version", intern = TRUE)[1]

# Extract software versions
versions <- c(bash_version, make_version, r_version) %>%
  str_extract(pattern = "[0-9.()]+")
names(versions) <- c("bash", "make", "r")

# Add software versions to md file
readme[indices["bash"][[1]]] <- paste0("* GNU bash (v. ", versions["bash"][[1]], ")", ", should be located in user's PATH")
readme[indices["make"][[1]]] <- paste0("* GNU Make (v. ", versions["make"][[1]], ")", ", should be located in user's PATH")
readme[indices["r"][[1]]] <- paste0("* R (v. ", versions["r"][[1]], ")", ", should be located in user's PATH")

# Write modified md file
write_lines(x = readme, file = "README.md")
