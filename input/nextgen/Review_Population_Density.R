# Objective: Review the bzone input data
# By: Dongmei Chen (dchen@lcog.org)
# October 26th, 2022
# click T:\Models\VisionEval\VE-3.0-Installer-Windows-R4.1.3_2022-05-27\VisionEval.Rproj to open RStudio

library(stringr)
library(sf)

infolder <- "models/CLMPO-base/inputs"
infile <- "bzone_unprotected_area.csv"

# check one bzone file
dat <- read.csv(file.path(infolder, infile), stringsAsFactors = FALSE)
head(dat)
dat$GeoID <- str_remove_all(dat$Geo, "Eug|Spr|Cob|-")
head(dat$GeoID)
GeoIDs <- dat$GeoID

shp.file <- "tl_2020_41_tract"
shp.path <- file.path("T:/DCProjects/Data/Census/Shp", shp.file)
census.tract <- st_read(dsn = shp.path, layer = shp.file, stringsAsFactors = FALSE)
head(census.tract)
census.tract.bzone <- census.tract[census.tract$GEOID %in% GeoIDs,]
census.tract.bzone$ALAND <- as.character(census.tract.bzone$ALAND)
st_write(census.tract.bzone, dsn = shp.path, layer = "bzone", driver = "ESRI Shapefile", delete_layer = TRUE)
unique(GeoIDs[!(GeoIDs %in% census.tract$GEOID)])

# bzone source data (a CLMPO clip of 2010 census tract?)
cltracts <- st_read(dsn = 'T:/Trans Projects/Model Development/UrbanSim_LandUse/Inputs/VisionEval',
                     layer = 'CLTracts_GsBoundary',
                     stringsAsFactors = FALSE)
head(cltracts)
GeoIDs <- cltracts$FIPSTRACT


# check all bzone files
files <- list.files(path = infolder, pattern = "^bzone(.*)csv$")
for(file in files){
  dat <- read.csv(file.path(infolder, infile), stringsAsFactors = FALSE)
  dat$GeoID <- str_remove_all(dat$Geo, "Eug|Spr|Cob|-")
  if(all(dat$GeoID %in% GeoIDs)){
    print(paste("The Geo IDs are identical betweeen", file, "and bzone_unprotected_area.csv"))
  }else{
    if(length(dat$GeoID[!(dat$GeoID %in% GeoIDs)]) > 0){
      print(paste(file, "has different Geo IDs from bzone_unprotected_area.csv:"))
      print(dat$GeoID[!(dat$GeoID %in% GeoIDs)])
    }else{
      print(paste0("bzone_unprotected_area.csv has different Geo IDs from ", file, ":"))
      print(GeoIDs[!(GeoIDs %in% dat$GeoID)])
    }
  }
}

# correct unprotected area
unprotected_area <- st_read(dsn="T:/DCProjects/Modeling/VE-RSPM/GIS/Shp", layer="bzone_unprotected_area", stringsAsFactors = FALSE)
head(unprotected_area)
unique(unprotected_area$DIVISION)
unprotected_area$Geo <- paste0(substr(unprotected_area$DIVISION, 1, 3), "-", unprotected_area$FIPSTRACT)
new_df <- unprotected_area[unprotected_area$Geo %in% unique(dat$Geo), c("Geo", "Area")]
colnames(new_df)[2] <- "UrbanArea"
new_df$Year <- rep(2010, dim(new_df)[1])
new_df <- new_df[, c("Geo", "Year", "UrbanArea")]
new_df_2 <- new_df
new_df_2$Year <- rep(2040, dim(new_df)[1])
df <- rbind(new_df, new_df_2)
df$TownArea <- rep(0, dim(df)[1])
df$RuralArea <- rep(0, dim(df)[1])
write.csv(df, paste0(infolder, infile), row.names = FALSE)


# review dwelling units - check Review_Dwelling_Units.R

