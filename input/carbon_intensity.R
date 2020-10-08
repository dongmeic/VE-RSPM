# Objective: to calculate the area percentage of utility in cities
# Dongmei CHEN (dchen@lcog.org)
# August 10th, 2020
# Reference: http://r-sig-geo.2731867.n2.nabble.com/rgdal-and-MSSQL-Server-geometries-td7583193.html

library(odbc)
library(rgdal)
library(raster)
library(rgeos)

# con <- dbConnect(odbc(),
#                  Driver = "SQL Server",
#                  Server = "rliddb.int.lcog.org,5433",
#                  Database = "RLIDGeo")

myMSSQLdsn <- c("MSSQL:server=rliddb.int.lcog.org,5433;database=RLIDGeo;trusted_connection=yes")

#Confirm connection is working
ogrListLayers(myMSSQLdsn)

#Reading sp object classes from SQL SERVER
lyr <- c("dbo.UGB")
projstring <- CRS('+init=epsg:4269') 
UGB <- readOGR(dsn=myMSSQLdsn, layer=lyr) #, p4s=CRSargs(projstring)
utility <- readOGR(dsn = 'T:/Models/VisionEval/GIS/inputs.gdb', 
                   layer = 'Utility_Project',
                   stringsAsFactors = FALSE)
#utility <- spTransform(utility, projstring)
proj4string(UGB) <- proj4string(utility)

city <- 'EUG'

get.pct.by.utility <- function(city){
  ugb.selected <- UGB[UGB$ugbcity == city,]
  utility.intersected <- intersect(utility, ugb.selected)
  utility.intersected$Areas_acre <- area(utility.intersected) * 0.000023
  total.acres <- sum(utility.intersected$Areas_acre)
  utility.intersected$Areas_pct <- utility.intersected$Areas_acre/total.acres
  dt <- utility.intersected@data[, c('NAME', 'Areas_acre', 'Areas_pct')]
  return(dt)
}

get.pct.by.utility(city='EUG')
get.pct.by.utility(city='SPR')
get.pct.by.utility(city='COB')

