library(readr)
library(dplyr)
library(magrittr)
library(tidyverse)
library(ggplot2)
library(r2d3)
library(jsonlite)

#read volcano data
volcanoes = read_delim("GVP_Volcano_List_Holocene.csv", delim=";")

#filter it to only volcanoes after common era
volcanoes_after_ce = volcanoes %>% filter(!str_detect(`Last Known Eruption`, "BCE")) %>% filter(!str_detect(`Last Known Eruption`, "Unknown")) 
#remove the CE in the last known eruption column
volcanoes_after_ce$`Last Known Eruption` = gsub("CE", "", volcanoes_after_ce$`Last Known Eruption`) 
#convert it to numeric data
volcanoes_after_ce$`Last Known Eruption` = as.numeric(volcanoes_after_ce$`Last Known Eruption`)
#filter it to just after 1879
volcanoes_after_1880 = volcanoes_after_ce %>% filter(`Last Known Eruption` > 1879)

#find the eruption data and load it
eruptions = read_delim("GVP_Eruption_Results.csv", delim = ";")

#filter it to 1880 and after
eruptions_1880 = eruptions %>% filter(`Start Year` > 1879)
#sum up the number of eruptions per volcano
eruptions_1880_sum = eruptions_1880 %>% group_by(`Volcano Number`) %>% summarise(n())
#join eruptions to volcano data
volcanoes_after_1880_join = left_join(volcanoes_after_1880, eruptions_1880_sum, by.x=`Volcano Number`, by.y = `Volcano Number`)
#filter for only volcanoes above ground
volcanoes_after_1880_join_aboveM = volcanoes_after_1880_join %>% filter(`Elevation (m)` >= 0)

#rename columns for easier coding
volcanoes_after_1880_join_aboveM = volcanoes_after_1880_join_aboveM %>% rename(vol_number = `Volcano Number`, vol_name = `Volcano Name`,
                                                                               country = Country, type = `Primary Volcano Type`, 
                                                                               eruption_date = `Last Known Eruption`, region = Region, 
                                                                               lat = Latitude, lon = Longitude, elevation = `Elevation (m)`, 
                                                                               sum = `n()`)

#remove columns i don't need
volcanoes_after_1880_join_aboveM = volcanoes_after_1880_join_aboveM %>% select(vol_number, vol_name, 
                                                                               country, type, eruption_date, 
                                                                               region, lat, lon, elevation, sum)
#write 
write_csv(volcanoes_after_1880_join_aboveM, "volcano_eruptions_1880.csv")
write_json(volcano_json, "volcano_1880.json")
