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
# NAME  Areas_acre   Areas_pct
# 1                  Lane Elec  1708.67086 0.047952954
# 2               Blachly-Lane  1055.21079 0.029613939
# 3                Emerald PUD   118.77832 0.003333451
# 4  Springfield Utility Board    60.63404 0.001701662
# 5                       EWEB 32688.93987 0.917397994
get.pct.by.utility(city='SPR')
# NAME Areas_acre    Areas_pct
# 1                Emerald PUD  1265.1477 0.0819459810
# 2                Emerald PUD    10.0901 0.0006535547
# 3  Springfield Utility Board 13754.6328 0.8909132877
# 4                       EWEB   408.9302 0.0264871765
get.pct.by.utility(city='COB')
# NAME Areas_acre Areas_pct
# 1 Emerald PUD   757.4331         1

# Electricity CI
