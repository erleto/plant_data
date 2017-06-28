library(stringr)
library(RSQLite)
library(dplyr)

# List all csv files in directory so that they can be imported later
file_list_85 <- list.files(path = '~/Desktop/luke_plant_data/VMI85/', 
  pattern = '*.csv', full.names = TRUE)
file_list_95 <- list.files(path = '~/Desktop/luke_plant_data/VMI95/', 
  pattern = '*.csv', full.names = TRUE)
# One of the 1985 files has a semicolon separator, it needs to be imported separately
file_list_85 <- file_list_85[!grepl("vmi85_vmikuvio", file_list_85)]
vmi85_vmikuvio <- read.csv2('~/Desktop/luke_plant_data/VMI85/vmi85_vmikuvio.csv', na.strings = c('\\N', ''))

list2env(lapply(setNames(file_list_85, stringr::str_extract(file_list_85, "vmi[^.]*")), 
  FUN = function(x) read.csv(file = x, na.strings = '\\N')), envir = .GlobalEnv)
list2env(lapply(setNames(file_list_95, stringr::str_extract(file_list_95, "vmi[^.]*")), 
  FUN = function(x) read.csv(file = x, na.strings = '\\N')), envir = .GlobalEnv)

# Create lists for 1985 and 1995 vmi data
list_1985 <- ls(pattern = "^vmi85")
list_1995 <- ls(pattern = "^vmi95")

# Add a year column and remove the VMITUNNUS column (if applicable) from each 
# dataframe in the lists
list_1985_year <- lapply(mget(list_1985), transform, YEAR = 1985)
list_1985_year <- lapply(list_1985_year, function(x) { x["VMITUNNUS"] <- NULL; x })
list_1995_year <- lapply(mget(list_1995), transform, YEAR = 1995)

list2env(list_1985_year, envir = .GlobalEnv)
list2env(list_1995_year, envir = .GlobalEnv)

luke_plant_db <- dbConnect(RSQLite::SQLite(), "")
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lajit", vmi85_lajit)
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lukupuu", vmi85_lukupuu)
RSQLite::dbListTables(luke_plant_db)

RSQLite::dbGetQuery(luke_plant_db, 'SELECT * FROM vmi85_lajit WHERE RYHMA = 6')
