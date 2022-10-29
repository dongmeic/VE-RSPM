# Objective: adjust group quarter (GQ) dwelling units to include only non-institutional GQ
# By: Dongmei Chen (dchen@lcog.org)
# October 28th, 2022

library(stringr)
library(sf)

infolder <- "T:/DCProjects/Data/Census/P5/DECENNIALPL2020.P5_2022-10-28T180822"
cltracts <- st_read(dsn = 'T:/Trans Projects/Model Development/UrbanSim_LandUse/Inputs/VisionEval',
                    layer = 'CLTracts_GsBoundary',
                    stringsAsFactors = FALSE)



# group quarters population by major group quarters type
gq_by_type <- read.csv(file.path(infolder, "DECENNIALPL2020.P5-Data.csv"), stringsAsFactors = FALSE)
bzone <-
hu_indata <- hu_indata[-1,]
hu_indata$GEO_ID <- str_split(hu_indata$GEO_ID, "US", simplify = TRUE)[,2]
head(hu_indata)
du_indata <- read.csv(paste0(path, "bzone_dwelling_units.csv"), stringsAsFactors = FALSE)
du_indata$Geo <- str_split(du_indata$Geo, "-", simplify = TRUE)[,2]
colnames(hu_indata)[which(colnames(hu_indata)=="GEO_ID")] <- "Geo"
indata <- merge(du_indata, hu_indata[,c("Geo", "H001001")], by="Geo")
indata$DU <- as.numeric(indata$H001001) - (indata$SFDU + indata$MFDU)
indata <- indata[indata$Year == 2010, ]
indata[indata$GQDU != 0, c('GQDU', 'DU')]


