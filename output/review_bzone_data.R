# Objective: Reivew bzone input and output data
# Source: run_example_scenarios.R
# By: Dongmei Chen (dchen@lcog.org)
# September 29th, 2020 

# load libraries
options("rgdal_show_exportToProj4_warnings"="none")
library(rgdal)

drive = 'E'

if(drive == 'C'){
  drive.path = 'C:/Users/DChen/all/VE-RSPM'
}else{
  drive.path = 'E:'
}

inpath <- paste0(drive.path, "/VisionEval/models/CLMPO-scenarios/01-Base-Year-2010/inputs/")
bzone.files <- list.files(path = inpath, pattern = "^bzone(.*)csv$")

# bzone shapefile
path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/data/Boundaries"
bzone.bd <- readOGR(dsn = path, layer = 'CLTracts_GsBoundary', 
                    stringsAsFactors = FALSE)

fields <- vector()
for(file in bzone.files){
  dt <- read.csv(paste0(inpath, file), stringsAsFactors = FALSE)
  for(field in colnames(dt)[-(which(colnames(dt) %in% c("Geo", "Year")))]){
    if(length(unique(dt[,field]))>3){
      # cat(paste0('In ', file, ' has ', field, ' with ', 
      #            length(unique(dt[,field])),' unique values\n'))
      if(length(unique(dt[,field]))>10){
        fields <- c(fields, field)
      }
    }
  }
}

dt <- read.csv(paste0(inpath, 'bzone_dwelling_units.csv'), stringsAsFactors = FALSE)
df <- dt[dt$Year==2010,c('Year', 'Geo')]
for(file in bzone.files){
  dt <- read.csv(paste0(inpath, file), stringsAsFactors = FALSE)
  print(file)
  if(any(colnames(dt) %in% fields)){
    df <- merge(df, dt[,which(colnames(dt) %in% c('Geo', fields))], by='Geo')
  }
}
outfolder <- 'C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/'
write.csv(df, paste0(outfolder, "bzone_input_with_more_unique_values.csv"), 
          row.names = FALSE)

head(bzone.bd@data)
bzone.bd$Geo <- paste0(substr(bzone.bd$DIVISION, 1, 3), "-", bzone.bd$FIPSTRACT)
bzone.bd@data <- merge(bzone.bd@data, df, by='Geo')
# writeOGR(bzone.bd, dsn = 'C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM',
#          layer = 'bzone_2010_data', driver = 'ESRI Shapefile', overwrite_layer = TRUE)

outpath <- 'E:/VisionEval/models/CLMPO-scenarios/01-Base-Year-2010/Datastore/2010/Bzone/'
files <- list.files(path = outpath)
dt <- read.csv(paste0(inpath, 'bzone_dwelling_units.csv'), stringsAsFactors = FALSE)
df <- dt[dt$Year==2010,c('Year', 'Geo')]
for(file in files){
  load(paste0(outpath, file))
  df.s <- data.frame(v=Dataset[1:67])
  if(length(unique(df.s$v)) > 10){
    colnames(df.s) <- str_remove(file, ".Rda")
    df <- cbind(df, df.s)    
  }
}
outfolder <- 'C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/'
write.csv(df, paste0(outfolder, "bzone_output_with_more_unique_values.csv"), 
          row.names = FALSE)
