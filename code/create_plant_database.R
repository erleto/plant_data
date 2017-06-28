library(stringr)
library(RSQLite)

# List all csv files in directory so that they can be imported later
file_list_85 <- list.files(path = '~/Desktop/luke_plant_data/VMI85/', 
  pattern = '*.csv', full.names = TRUE)
file_list_95 <- list.files(path = '~/Desktop/luke_plant_data/VMI95/', 
  pattern = '*.csv', full.names = TRUE)
# One of the 1985 files has a semicolon separator, it needs to be imported separately
file_list_85 <- file_list_85[!grepl("vmi85_vmikuvio", file_list_85)]
vmi85_vmikuvio <- read.csv2('~/Desktop/luke_plant_data/VMI85/vmi85_vmikuvio.csv', na.strings = c('\\N', ''))

list2env(lapply(setNames(file_list_85, str_extract(file_list_85, "vmi[^.]*")), 
  FUN = function(x) read.csv(file = x, na.strings = '\\N')), envir = .GlobalEnv)
list2env(lapply(setNames(file_list_95, str_extract(file_list_95, "vmi[^.]*")), 
  FUN = function(x) read.csv(file = x, na.strings = '\\N')), envir = .GlobalEnv)

list_1985 <- ls(pattern = "^vmi85")
list_1995 <- ls(pattern = "^vmi95")
#df_list = mget(ls(pattern = "^vmi85"))

luke_plant_db <- dbConnect(RSQLite::SQLite(), "")
dbWriteTable(luke_plant_db, "vmi85_lajit", vmi85_lajit)
dbWriteTable(luke_plant_db, "vmi85_lukupuu", vmi85_lukupuu)
dbListTables(luke_plant_db)

dbGetQuery(luke_plant_db, 'SELECT * FROM vmi85_lajit WHERE RYHMA = 6')
