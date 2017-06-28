#### Background ####
# Date:         17.3.2015
# By:           Eric Le Tortorec
# Description:  R script for reading in plant inventory data and managing it
# R version:    3.2.3

#### Read VMI vascular plant data ####
library(readxl)
library(dplyr)
library(stringr)
vmi85_quadrat <- read_excel("/Users/Eric/Dropbox/Eric/Work/JKL/Vascular_plant_model_validation/Data/VMI85_aineistoa3_3_2015.xlsx", sheet = 1)
vmi85_circle <- read_excel("/Users/Eric/Dropbox/Eric/Work/JKL/Vascular_plant_model_validation/Data/VMI85_ka_ruutulko_lajit.xlsx", sheet = 2)
#vmi85_tree = read_excel("/Users/Eric/Dropbox/Eric/Work/JKL/Vascular_plant_model_validation/Data/VMI85_vmikuvio_lehtipuiden_osuus_18_12_2014.xlsx", sheet = 1)
plants_functional_database <- read.csv("/Users/Eric/Dropbox/Eric/Work/JKL/Plant_inventory_data/Data/TryAccSpecies.txt", sep="\t")

#### Combine circle and quadrat plant datasets ####
names(vmi85_quadrat)
vmi85_quadrat_subset <- select(vmi85_quadrat, KOEALA, NIMI, RYHMA) #vmi85_quadrat_subset <- vmi85_quadrat[,c(1,4,6)]
names(vmi85_circle)
vmi85_circle_subset <- select(vmi85_circle, KOEALA=Koeala, NIMI, RYHMA) #vmi85_circle_subset <- vmi85_circle[,c(1,2,7)]
vmi85_plants <- rbind(vmi85_quadrat_subset, vmi85_circle_subset)

# Get list of unique species from inventory data
vmi85_plant_list <- distinct(vmi85_plants, NIMI)

# Select only vasular plants from NFI data
vascular <- c(1:7,12)
vmi85_plant_list_vascular <- filter(vmi85_plant_list, RYHMA %in% vascular)

# Compare NFI plant list to plant list obtained from TRY plant trait database
# In the plant trait database there are some non- UTF-8 characters so I use the
# iconv function to convert them from latin1 to UTF-8
plants_functional_database$AccSpeciesName <- iconv(plants_functional_database$AccSpeciesName, "latin1", "UTF-8",sub='')

vmi85_plant_list$NIMI <- tolower(vmi85_plant_list$NIMI)
plants_functional_database$AccSpeciesName <- tolower(plants_functional_database$AccSpeciesName)

vmi85_trait_database_merged <- merge(vmi85_plant_list_vascular, plants_functional_database, by.x = "NIMI", by.y = "AccSpeciesName")

# Print how many NFI vascular plant species have trait data available
dim(vmi85_trait_database_merged)