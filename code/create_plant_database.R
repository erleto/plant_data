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
# Lichens
vmi_lichen <- dplyr::bind_rows(vmi85_jakalat, vmi95_jakalat9)
# Sample plots
vmi95_koeala9 <- dplyr::rename(vmi95_koeala9, SIIRT_POHJ = PE_SIIRT, 
  SIIRT_ITA = IL_SIIRT, RYHMANJOHTAJA = RJ, EP = E_P)
vmi_plots <- dplyr::bind_rows(vmi85_koeala, vmi95_koeala9)
vmi_plots$PVM <- as.Date(vmi_sample_plot$PVM)
# Species
vmi_species <- vmi85_lajit
# Sample trees
vmi85_lukupuu$SYNTYTAPA <- as.character(vmi85_lukupuu$SYNTYTAPA)
vmi85_lukupuu$RINN_KORK_IKA <- as.character(vmi85_lukupuu$RINN_KORK_IKA)
vmi85_lukupuu$IKALISAYS <- as.character(vmi85_lukupuu$IKALISAYS)
vmi85_lukupuu$LENKOUS <- as.character(vmi85_lukupuu$LENKOUS)
vmi85_lukupuu$TUHON_ASTE <- as.character(vmi85_lukupuu$TUHON_ASTE)
vmi_sample_trees <- dplyr::bind_rows(vmi85_lukupuu, vmi95_lukupuu9)
#
vmi_osakasvusto <- dplyr::bind_rows(vmi85_osakasv, vmi95_osakasv9)
# Species coverage
vmi95_peite9 <- dplyr::rename(vmi95_peite9, PEITTAVYYS = PEITE)
vmi_species_coverage <- dplyr::bind_rows(vmi85_peite, vmi95_peite9)
# Bushes
vmi_bushes <- dplyr::bind_rows(vmi85_pensaat, vmi95_pensaat9)
# Small trees
vmi85_pienpuut <- dplyr::rename(vmi85_pienpuut, KESKIPITUUS = KESKIPITUUSLUOKKA, 
  RUNKOLUKU = LKM)
vmi85_pienpuut$KESKIPITUUS <- as.character(vmi85_pienpuut$KESKIPITUUS)
vmi_small_trees <- dplyr::bind_rows(vmi85_pienpuut, vmi95_pienpuu9)
# Mean basal area
vmi_mean_basal_area <- dplyr::bind_rows(vmi85_ppaka, vmi95_ppaka9)
# Mean basal area per compartment
vmi_compartment_mean_basal_area <- dplyr::bind_rows(vmi85_ppakuvio, vmi95_ppakuv9)
# Trees
vmi_trees <- dplyr::bind_rows(vmi85_puut, vmi95_puut9)
# Quadrats
vmi95_ruutu9 <- dplyr::rename(vmi95_ruutu9, RUNGOT = RUNGOT_1)
vmi_quadrat <- dplyr::bind_rows(vmi85_ruutu, vmi95_ruutu9)
# Species within quadrats
vmi_quadrat_species <- dplyr::bind_rows(vmi85_ruutulko, vmi95_ruutulk9)

# Ruutu osakasvusto
#vmi_plot_xxx <- dplyr::bind_rows(vmi85_ruutuosak, vmi95_ruuosak9)

# Biotopes within plots
vmi85_tyyppikuv <- dplyr::rename(vmi85_tyyppikuv, SUON_ALK_TR = OJ_LIS_M)
vmi_plot_biotope <- dplyr::bind_rows(vmi85_tyyppikuv, vmi95_tyypkuv9)
vmi_plot_biotope$DATE <- as.Date(with(vmi_plot_biotope, paste(PP, KK, VV, sep = "-")), "%d-%m-%y")
vmi_plot_biotope[c('PP', 'KK', 'VV')] <- NULL
# VMI compartments (a lot of renaming involved)
vmi85_vmikuvio <- dplyr::rename(vmi85_vmikuvio, METSALAUTAKUNTA = MLTK, 
  KEH_LUOKKA_JAKSO_1 = KEH_LUOKKA, VALL_PUUL_JAKSO_1 = VALL_PUUL_1, 
  VALL_OSUUS_JAKSO_1 = VALL_OSUUS_1,  HAVU_LEHT_OS_JAKSO_1 = HAVU_LEHT_OS_1, 
  SIVUPUULAJI_JAKSO_1 = SIVUPUULAJI_1, 
  PPA_1_JAKSO_1 = POHJA_1, PPA_1_HAV_PAIKKA_JAKSO_1 = HAV_PAIKKA_1, 
  PPA_2_JAKSO_1 = POHJA_2, PPA_2_HAV_PAIKKA_JAKSO_1 = HAV_PAIKKA_2, 
  PPA_3_JAKSO_1 = POHJA_3, PPA_3_HAV_PAIKKA_JAKSO_1 = HAV_PAIKKA_3, 
  KUVION_PPA_JAKSO_1 = KUVION_POHJA_1, KASV_RUNKOL_JAKSO_1 = KASV_RUNKOL_1, 
  KESKILAPIM_JAKSO_1 = KESKILAPIM_1, KESKIPITUUS_JAKSO_1 = KESKIPITUUS_1, 
  METS_IKA_JAKSO_1 = METS_IKA_1, 
  VALL_PUUL_JAKSO_2 = VALL_PUUL_2, VALL_OSUUS_JAKSO_2 = VALL_OSUUS_2,  
  HAVU_LEHT_OS_JAKSO_2 = HAVU_LEHT_OS_2, SIVUPUULAJI_JAKSO_2 = SIVUPUULAJI_2, 
  KUVION_PPA_JAKSO_2 = KUVION_POHJA_2, RUNKOLUKU_JAKSO_2 = RUNKOLUKU_2, 
  KASV_RUNKOL_JAKSO_2 = KASV_RUNKOL_2, KESKILAPIM_JAKSO_2 = KESKILAPIM_2, 
  KESKIPITUUS_JAKSO_2 = KESKIPITUUS_2, METS_IKA_JAKSO_2 = METS_IKA_2)
vmi95_vmikuv9 <- dplyr::rename(vmi95_vmikuv9, KALT_JYRKK = KALTEVUUS, 
  MAANP_MUOTO = TOPOGRAFIA, KUV_RAJ_ET = MAISEMARAJ_ET, KUV_RAJ_SU = MAISEMARAJ_SUU, 
  MITT_TAPA = MITTAUSTAPA, KORK_MERENP = KORKEUS, MITT_TAPA = MITTAUSTAPA, 
  ALARYHMA = KASVUP_PAATYYPPI, HUM_PAKS = ORG_KERR_PAKS, HUM_LAATU =ORG_KERR_LAATU , 
  MAAP_LAATU = MAALAJI, MAANPAR_TOIM = TEHTY_MAANMUOKK, MAANPAR_AIKA = TEHD_MAANM_AIKA, 
  HAKK_LAATU = TEHD_HAKKUUT, HAKK_AIKA = TEHD_HAKK_AIKA, METS_H_TOIM = TEHTY_METSH_TP, 
  METS_H_AIKA = TEHD_METSHTP_AIKA, EHD_HAKK = HAKKUUEHDOTUS, EHD_HAKK_KIIR = HAKK_KIIREELL, 
  EHD_HOITOTOIM = METSH_TOIMP_EHD, EHD_MAANP_KAS = MAANMUOKK_EHD, NAAV_JAKALAT = NAAV_JAK, 
  LEHT_JAKALAT = LEHT_JAK, PER_TAPA = PERUST_TAPA, 
  KEH_LUOKKA_JAKSO_1 = KEHLK, 
  VALL_PUUL_JAKSO_1 = VALL_PL, VALL_OSUUS_JAKSO_1 = VALL_PL_OSUUS, 
  HAVU_LEHT_OS_JAKSO_1 = HAVU_LEHT_OSUUS, SIVUPUULAJI_JAKSO_1 = SIVU_PL, 
  PPA_1_JAKSO_1 = PPA1, PPA_1_HAV_PAIKKA_JAKSO_1 = PPA1_HAV_PAIKKA, 
  PPA_2_JAKSO_1 = PPA2, PPA_2_HAV_PAIKKA_JAKSO_1 = PPA2_HAV_PAIKKA, 
  PPA_3_JAKSO_1 = PPA3, PPA_3_HAV_PAIKKA_JAKSO_1 = PPA3_HAV_PAIKKA, 
  KUVION_PPA_JAKSO_1 = KUVION_PPA, RUNKOLUKU_JAKSO_1 = RUNKOLUKU, 
  KASV_RUNKOL_JAKSO_1 = KASV_RUNKOLUKU, KESKILAPIM_JAKSO_1 = KESKILPM, 
  KESKILPM_LASK_JAKSO_1 = KESKILPM_LASK, KESKIPITUUS_JAKSO_1 = KESKIPITUUS, 
  METS_IKA_JAKSO_1 = KOK_IKA, 
  KEH_LUOKKA_JAKSO_2 = KEHLK_2, VALL_PUUL_JAKSO_2 = VALL_PL_2, 
  VALL_OSUUS_JAKSO_2 = VALL_PL_OSUUS_2, HAVU_LEHT_OS_JAKSO_2 = HAVU_LEHT_OSUUS_2, 
  SIVUPUULAJI_JAKSO_2 = SIVU_PL_2, RUNKOLUKU_JAKSO_2 = RUNKOLUKU_2, 
  KASV_RUNKOL_JAKSO_2 = KASV_RUNKOL_2, KESKILAPIM_JAKSO_2 = KESKILPM_2, 
  KESKILPM_LASK_JAKSO_2 = KESKILPM_LASK_2, KESKIPITUUS_JAKSO_2 = KESKIPITUUS_2, 
  METS_IKA_JAKSO_2 = KOK_IKA_2, KUVION_PPA_JAKSO_2 = PPA_2, TUHON_LAATU = TUHON_ILMIASU, 
  TUHON_SYY = TUHON_AIHEUTTAJA, TUHON_MAARA = TUHON_MERKITYS, LAAT_ALENT_SYY = LAAD_AL_SYY)
cols_to_change <- c('KUV_RAJ_SU', 'PER_TAPA', 'LEHT_JAKALAT', 'VALL_PUUL_JAKSO_1', 
  'SIVUPUULAJI_JAKSO_1', 'SIVUPUULAJI_JAKSO_2')
vmi85_vmikuvio[cols_to_change] <- sapply(vmi85_vmikuvio[cols_to_change], as.character)
vmi95_vmikuv9[cols_to_change] <- sapply(vmi95_vmikuv9[cols_to_change], as.character)
vmi_compartments <- dplyr::bind_rows(vmi85_vmikuvio, vmi95_vmikuv9)

# Create database
luke_plant_db <- dbConnect(RSQLite::SQLite(), "")
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lajit", vmi85_lajit)
RSQLite::dbWriteTable(luke_plant_db, "vmi85_lukupuu", vmi85_lukupuu)
RSQLite::dbListTables(luke_plant_db)

RSQLite::dbGetQuery(luke_plant_db, 'SELECT * FROM vmi85_lajit WHERE RYHMA = 6')
