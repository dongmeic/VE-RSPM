# Objective: Modify input data from ODOT data files
# By: Dongmei Chen (dchen@lcog.org)
# July 9th, 2020 

# note that the output overwrites the input
setwd("T:/Models/VisionEval/CLMPO_VE-R3.6.1.2019-09-18/models/VERSPM/SA_Reference/inputs")
bzone_parking <- read.csv("bzone_parking.csv", stringsAsFactors = FALSE)
attach(bzone_parking)
# add "PropNonWrkTripPay"
bzone_parking$PropNonWrkTripPay = PropWkrPay * (1 - PropCashOut) 
write.csv(bzone_parking, "bzone_parking.csv", row.names = FALSE)
detach(bzone_parking)
#bzone_parking <- bzone_parking[, -which(names(bzone_parking) == 'PropNonWrkTripPay')]

# correct 'geo' from 'EugneSpringfield' to 'CLMPO'
# list files that contain 'marea' 
setwd("C:/Users/DChen/all/VE-RSPM/VisionEval/models/STSRec/inputs")
files <- list.files(path = ".", pattern = "^marea(.*)csv$")
for(file in files){
  dt <- read.csv(file, stringsAsFactors = FALSE, header = TRUE, row.names = NULL)
  if('row.names' %in% names(dt)){
    colnames(dt) <- c(colnames(dt)[-1], NULL)
    if(NA %in% names(dt)){
      dt <- dt[,-which(is.na(names(dt)))]
    }
  }
  if("Geo" %in% names(dt)){
    dt$Geo <- ifelse(dt$Geo == "EugeneSpringfield", "CLMPO", dt$Geo)
  }
  write.csv(dt, file, row.names = FALSE)
  print(paste("rewrote geography in", file))
}

# revise marea_transit_service.csv
infolder <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO/inputs/"
dat <- read.csv(paste0(infolder, "marea_transit_service.csv"), stringsAsFactors = FALSE)
vars <- c('DRRevMi', 'VPRevMi', 'MBRevMi', 'RBRevMi')
dat[,vars] <- dat[,vars]*10^6
write.csv(dat, paste0(infolder, "marea_transit_service.csv"), row.names = FALSE)
