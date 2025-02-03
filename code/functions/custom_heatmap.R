#################################################################################################################
# custom_heatmap.R
#
# Function to customise the heatmap data calculation.
# Dependencies: data/raw/ko_names.tsv
#               data/raw/abc_description.tsv
#               code/functions/transpose_naaf.R
#               code/functions/format_labels.R
#
#################################################################################################################

custom_heatmap <- function(input = NULL, database = NULL, filter_database_entry = NULL, metadata = NULL,
                           filter_ko_names = NULL, filter_ko_table = NULL, summarise_by = NULL) {
  
  #################################################################
  # Preformat database entries
  # (identical for all databases selected)
  #################################################################
  
  # Ensure that the required arguments are provided
  if(is.null(input) || quo_is_null(quo = enquo(arg = database)) ||
     is.null(metadata)) {
    stop("'input', 'database' and 'metadata' must be provided.")
  }
  
  # Filter the proteins classified using the defined database
  input <- input %>%
    filter(!is.na( {{database}} )) %>%
    filter({{ database }} != "-")
  
  # Filter the database entries if the filter argument is provided
  if(!is.null(filter_database_entry)) {
    input <- input %>%
      filter(str_detect(string = {{ database }}, pattern =  filter_database_entry))
  }
  
  # Select the columns containing the NAAFs and the data from the defined
  # database
  # If the KEGG_Pathway database is defined, select the
  # KEGG_ko column instead of the KEGG_Pathway column.
  if(as_name(x = enquo(arg = database)) == "KEGG_Pathway") {
    input <- input %>%
      select(KEGG_ko, starts_with(match = "MM"))
    } else {
      input <- input %>%
        select({{ database }}, starts_with(match = "MM"))
      }
  
  #################################################################
  # Format the KEGG_ko database entries
  #################################################################
  
  # When the KEGG_ko database is selected:
  # 1. Format KEGG_ko entries
  # 2. Evaluate the filters: filter_ko_names and filter_ko_table
  # (The purpose of enquo is to capture the expression
  # passed to the function in the form of a quosure.
  # A quosure (quoted expression) is an object that
  # contains both an expression and the environment
  # in which it was created. Function as_name() converts
  # the quoted expression into a character string.)
  if(as_name(x = enquo(arg = database)) == "KEGG_ko") {
    
    # Format the KEGG_ko entries (remove "ko:" from the KEGG_ko entries)
    input <- input %>%
      mutate(KEGG_ko = str_remove_all(KEGG_ko, "ko:"))
    
    # When filter_ko_names is defined:
    # 1. Retrieve KEGG_ko entries corresponding to the defined KO names
    # 2. Filter KEGG_ko entries based on the evaluation results from step 1
    if(!is.null(filter_ko_names)) {
      # Load the KO entry names and filter the defined entries
      ko_names <- read_tsv(file = "data/raw/ko_names.tsv", col_names = c("KEGG_ko", "KO_name")) %>%
        filter(str_detect(string = KO_name, pattern = filter_ko_names))
      # Filter the KEGG_ko entries based on the defined KO names
      input <- input %>%
        filter(str_detect(KEGG_ko, paste0(ko_names$KEGG_ko, collapse = "|")))
      }
    # When filter_ko_table is defined:
    # 1. Separate the proteins classified into multiple KEGG_ko categories
    # 2. Join the NAAFs data with the KO entries from the table provided
    # 3. Retrieve KEGG_ko entries corresponding to the defined KO names
    # keeping only matching rows
    if(!is.null(filter_ko_table)) {
      # Ensure that the required arguments are provided
      if(quo_is_null(quo = enquo(arg = summarise_by))) {
        stop("'summarise_by' must be provided.")
      }
      # Separate the proteins classified into multiple KEGG_ko categories
      # into individual rows
      input <- input %>%
        separate_longer_delim(KEGG_ko, delim = ",")
      # Join the NAAFs data with the KO entries from the table provided
      # keeping only matching rows
      input <- inner_join(x = input, y = filter_ko_table, by = c("KEGG_ko" = "KEGG_ko"))
      # Remove column KEGG_ko and rename the column name
      # to KEGG_ko
      # (required for the summarising step)
      input <- input %>%
        select(-KEGG_ko) %>%
        rename(KEGG_ko = {{ summarise_by }})
      }
    
    }
  
  #################################################################
  # Format the KEGG_Pathway database entries
  #################################################################
  
  # If the KEGG_Pathway database is selected:
  # 1. Format the KEGG_ko entries
  # 2. Filter out the KEGG_ko entries that are either "-" or NA
  # 3. Separate the proteins classified into multiple KEGG_ko categories
  # 4. Join the NAAFs data with the KO entry names
  # 5. Filter the entries containing the description "substrate-binding protein"
  # 6. Join the NAAFs data and KO entry names with the ABC transporter data
  if(as_name(x = enquo(arg = database)) == "KEGG_Pathway") {
    
    # Format the KEGG_ko entries (remove "ko:" from the KEGG_ko entries)
    input <- input %>%
      mutate(KEGG_ko = str_remove_all(KEGG_ko, "ko:"))
    # Filter out the KEGG_ko entries that are either "-" or NA
    input <- input %>%
      filter(!is.na(KEGG_ko)) %>%
      filter(KEGG_ko != "-")
    # Separate the proteins classified into multiple KEGG_ko categories
    # into individual rows
    input <- input %>%
      separate_longer_delim(KEGG_ko, delim = ",")
    # Load the KO entry names
    ko_names <- read_tsv(file = "data/raw/ko_names.tsv", col_names = c("KEGG_ko", "KO_name"))
    # Join the NAAFs data with the KO entry names
    input <- left_join(x = input, y = ko_names, by = c("KEGG_ko" = "KEGG_ko"))
    # Filter the entries containing the description "substrate-binding protein"
    input <- input %>%
      filter(str_detect(string = KO_name, pattern = "substrate-binding protein"))
    # Load the ABC transporter description data
    abc_description <- read_tsv(file = "data/raw/abc_description.tsv", col_names = c("name", "substrate"))
    # Ensure that descriptions for all substrate-binding proteins are listed
    # in "data/raw/abc_description.tsv"
    if(any(input$KO_name %in% abc_description$name == FALSE)) {
      stop("Substrate-binding protein description missing. Descriptions for all substrate-binding proteins must be provided in 'data/raw/abc_description.tsv'.")
    }
    # Join the NAAFs data and KO entry names with the ABC transporter
    # description data
    input <- input %>%
      left_join(x = input, y = abc_description, by = c("KO_name" = "name"))
    # Remove substrate entries that are NA
    input <- input %>%
      filter(!is.na(substrate))
    # Rename the substrate column to KEGG_Pathway
    # (required for the summarising step)
    input <- input %>%
      rename(KEGG_Pathway = substrate)
    
    }
  
  #################################################################
  # Extract formatted data 
  #################################################################
  
  # Rename the object that contains formatted data
  formatted_data <- input

  #################################################################
  # Summarise processed data
  # (identical for all databases selected)
  #################################################################
  
  # Convert the NAAFs to percentages and sum them for
  # every database entry
  in_total <- input %>%
    mutate(across(starts_with(match = "MM"), ~ .x * 100)) %>%
    group_by({{ database }}) %>%
    summarise(across(starts_with(match = "MM"), .fns = sum), .groups = "drop")
  
  # Recalculate the relative contribution of the database entries
  in_selected <- in_total %>%
    mutate(across(starts_with(match = "MM"), ~ .x / sum(.x) * 100))
  
  # Transpose and pivot longer the data 
  in_total <- in_total %>%
    transpose_naaf(id_column = {{ database }}) %>%
    pivot_longer(cols = !ID, names_to = as_name(x = enquo(arg = database)), values_to = "NAAF (%)")
  in_selected <- in_selected %>%
    transpose_naaf(id_column = {{ database }}) %>%
    pivot_longer(cols = !ID, names_to = as_name(x = enquo(arg = database)), values_to = "NAAF (%)")
  
  # Format the plot labels using the custom function
  metadata <- format_labels(x = metadata)
  
  # Join the transposed NAAF data and the metadata
  in_total <- right_join(x = metadata, y = in_total, by = c("ID" = "ID"))
  in_selected <- right_join(x = metadata, y = in_selected, by = c("ID" = "ID"))
  
  # Calculate the median NAAF for each station's layer, decay period, and database entry
  in_total_grouped <- in_total %>%
    group_by(station, layer, decay_roots, {{ database }}) %>%
    summarise(`NAAF (%)` = median(`NAAF (%)`), .groups = "drop")
  in_selected_grouped <- in_selected %>%
    group_by(station, layer, decay_roots, {{ database }}) %>%
    summarise(`NAAF (%)` = median(`NAAF (%)`, na.rm = TRUE), .groups = "drop")
  
  # Sum the NAAF for each sample
  # (This applies only to the contribution to the total NAAF (in_total).)
  in_total_summed <- in_total %>%
    group_by(ID, station, layer, decay_roots) %>%
    summarise(`NAAF (%)` = sum(`NAAF (%)`), .groups = "drop")
  
  # Sum the NAAF for each station's layer and decay period
  # (This applies only to the contribution to the total NAAF (in_total_grouped).)
  in_total_grouped_summed <- in_total_grouped %>%
    group_by(station, layer, decay_roots) %>%
    summarise(`NAAF (%)` = sum(`NAAF (%)`), .groups = "drop")
  
  # Combine the outputs
  output <- list(formatted_data = input,
                 in_total = in_total,
                 in_total_summed = in_total_summed,
                 in_total_grouped = in_total_grouped,
                 in_total_grouped_summed = in_total_grouped_summed,
                 in_selected = in_selected,
                 in_selected_grouped = in_selected_grouped)
  
  # Return the output
  return(output)
  
}
