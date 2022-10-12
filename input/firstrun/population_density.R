# Objective: Check the bzone input data
# By: Dongmei Chen (dchen@lcog.org)
# September 1st, 2020
library(stringr)
library(rgdal)
infolder <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO/inputs/" 
infile <- "bzone_unprotected_area.csv"

# check one bzone file
dat <- read.csv(paste0(infolder, infile), stringsAsFactors = FALSE)
head(dat)
dat$GeoID <- str_remove_all(dat$Geo, "Eug|Spr|Cob|-")
head(dat$GeoID)
GeoIDs <- dat$GeoID

shp.path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/data/Census/cb_2018_41_tract_500k"
shp.file <- "cb_2018_41_tract_500k"
census.tract <- readOGR(dsn = shp.path, layer = shp.file, stringsAsFactors = FALSE)
head(census.tract@data)
census.tract.bzone <- census.tract[census.tract$GEOID %in% GeoIDs,]
writeOGR(census.tract.bzone, dsn = shp.path, layer = "bzone", driver = "ESRI Shapefile", overwrite_layer = TRUE)
unique(GeoIDs[!(GeoIDs %in% census.tract$GEOID)])


# check all bzone files
files <- list.files(path = infolder, pattern = "^bzone(.*)csv$")
for(file in files){
  dat <- read.csv(paste0(infolder, infile), stringsAsFactors = FALSE)
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
unprotected_area <- readOGR(dsn="C:/Users/DChen/all/VE-RSPM/inputs", layer="bzone_unprotected_area")
head(unprotected_area@data)
unique(unprotected_area$DIVISION)
unprotected_area$Geo <- paste0(substr(unprotected_area$DIVISION, 1, 3), "-", unprotected_area$FIPSTRACT)
new_df <- unprotected_area@data[unprotected_area$Geo %in% unique(dat$Geo), c("Geo", "Area")]
colnames(new_df)[2] <- "UrbanArea"
new_df$Year <- rep(2010, dim(new_df)[1])
new_df <- new_df[, c("Geo", "Year", "UrbanArea")]
new_df_2 <- new_df
new_df_2$Year <- rep(2040, dim(new_df)[1])
df <- rbind(new_df, new_df_2)
df$TownArea <- rep(0, dim(df)[1])
df$RuralArea <- rep(0, dim(df)[1])
write.csv(df, paste0(infolder, infile), row.names = FALSE)
