#################################################################################################################
# get_taxonomy.R
#
# Script to download the taxonomy files from NCBI (names and nodes) and create a SQLite database.
# Dependencies:
# Produces: data/references/names.dmp
#           data/references/nodes.dmp
#           data/references/nameNode.sqlite
#
#################################################################################################################

# Download the names and nodes files from NCBI and create a SQLite database
prepareDatabase(sqlFile = "data/references/nameNode.sqlite", getAccessions = FALSE, protocol = "http")
