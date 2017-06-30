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
# Convert the lists of data frames to actual data frames
list2env(list_1985_year, envir = .GlobalEnv)
list2env(list_1995_year, envir = .GlobalEnv)

# Print all objects beginning with 'vmi'
ls(pattern = '^vmi')

# Bind 1985 and 1995 data frames
vmi_lichen <- dplyr::bind_rows(vmi85_jakalat, vmi95_jakalat9)

vmi95_koeala9 <- dplyr::rename(vmi95_koeala9, SIIRT_POHJ = PE_SIIRT, 
  SIIRT_ITA = IL_SIIRT, RYHMANJOHTAJA = RJ, EP = E_P)
vmi_sample_plot <- dplyr::bind_rows(vmi85_koeala, vmi95_koeala9)
vmi_sample_plot$PVM <- as.Date(vmi_sample_plot$PVM)

vmi_species <- vmi85_lajit

vmi85_lukupuu$SYNTYTAPA <- as.character(vmi85_lukupuu$SYNTYTAPA)
vmi85_lukupuu$RINN_KORK_IKA <- as.character(vmi85_lukupuu$RINN_KORK_IKA)
vmi85_lukupuu$IKALISAYS <- as.character(vmi85_lukupuu$IKALISAYS)
vmi85_lukupuu$LENKOUS <- as.character(vmi85_lukupuu$LENKOUS)
vmi85_lukupuu$TUHON_ASTE <- as.character(vmi85_lukupuu$TUHON_ASTE)
vmi_sample_trees <- dplyr::bind_rows(vmi85_lukupuu, vmi95_lukupuu9)

vmi_osakasvusto <- dplyr::bind_rows(vmi85_osakasv, vmi95_osakasv9)

vmi95_peite9 <- dplyr::rename(vmi95_peite9, PEITTAVYYS = PEITE)
vmi_species_coverage <- dplyr::bind_rows(vmi85_peite, vmi95_peite9)

vmi_bushes <- dplyr::bind_rows(vmi85_pensaat, vmi95_pensaat9)

vmi85_pienpuut <- dplyr::rename(vmi85_pienpuut, KESKIPITUUS = KESKIPITUUSLUOKKA, 
  RUNKOLUKU = LKM)
vmi85_pienpuut$KESKIPITUUS <- as.character(vmi85_pienpuut$KESKIPITUUS)
vmi_small_trees <- dplyr::bind_rows(vmi85_pienpuut, vmi95_pienpuu9)

vmi_mean_basal_area <- dplyr::bind_rows(vmi85_ppaka, vmi95_ppaka9)

vmi_mean_basal_area_plot <- dplyr::bind_rows(vmi85_ppakuvio, vmi95_ppakuv9)

vmi_trees <- dplyr::bind_rows(vmi85_puut, vmi95_puut9)

vmi95_ruutu9 <- dplyr::rename(vmi95_ruutu9, RUNGOT = RUNGOT_1)
vmi_quadrats <- dplyr::bind_rows(vmi85_ruutu, vmi95_ruutu9)
  
luke_plant_db <- dbConnect(RSQLite::SQLite(), "")
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lajit", vmi85_lajit)
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lukupuu", vmi85_lukupuu)
RSQLite::dbListTables(luke_plant_db)

RSQLite::dbGetQuery(luke_plant_db, 'SELECT * FROM vmi85_lajit WHERE RYHMA = 6')
