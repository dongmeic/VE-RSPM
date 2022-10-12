# Objective: adjust group quarter dwelling units
# By: Dongmei Chen (dchen@lcog.org)
# October 21st, 2020

drive = 'E'

if(drive == 'C'){
  drive.path = 'C:/Users/DChen/all/VE-RSPM'
}else{
  drive.path = 'E:'
}

library(stringr)

path <- paste0(drive.path, "/VisionEval/models/CLMPO-scenarios/01-Base-Year-2010/inputs/")
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/data/DECENNIALSF12010.H1_2020-10-16T232536/"

hu_indata <- read.csv(paste0(infolder, "DECENNIALSF12010.H1_data_with_overlays_2020-10-16T232532.csv"), stringsAsFactors = FALSE)
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

# use 5 as numerator
# copy bzone_dwelling_units.csv

copy.file <- function(file, s, i){
  path <- "E:/VisionEval/models/CLMPO-scenarios/"
  newlocation <- paste0(path, 0, i, '-', s)
  file.copy(from = paste0(path, '01-Base-Year-2010/inputs/', file),
            to=paste0(newlocation, "/inputs/", file), overwrite = TRUE, copy.mode = TRUE)
}

infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
comb <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)

scenarios <- comb$S
start.time <- Sys.time()
for(s in scenarios){
  print(Sys.time())
  i = which(scenarios==s) + 1
  copy.file("bzone_dwelling_units.csv", s, i)
}
Sys.time() - start.time
