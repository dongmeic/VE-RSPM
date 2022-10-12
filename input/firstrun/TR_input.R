# Objective: Add 2005 year data to TR input files from previous data folder
# By: Dongmei Chen (dchen@lcog.org)
# August 13th, 2020 

# Warning: there is some bug in this script on detecting the 
# existence of year 2005 in the original files

library(stringr)

path.TR <- "T:/Models/VisionEval/CLMPO_VE-R3.6.1.2019-09-18/models/VERSPM/SA_Reference/inputs-TR/"
path <- "T:/Models/VisionEval/VERSPM_User_Files_Copies/VERSPM_CLMPO_SA_Reference_2019_12_09_SAVE_FOR_NONMODEL_YEARS/inputs/"

# review year information
files <- list.files(path = path, pattern = "(.*)csv$")
for(file in files){
  dt <- read.csv(paste0(path, file), stringsAsFactors = FALSE, 
                 header = TRUE, row.names = NULL)
  if('row.names' %in% names(dt)){
    colnames(dt) <- c(colnames(dt)[-1], NULL)
    if(NA %in% names(dt)){
      dt <- dt[,-which(is.na(names(dt)))]
    }
  }
  if("Year" %in% names(dt) & 
     !(file %in% c("_input_template_bzone.csv",
                 "region_hh_driver_adjust_prop.csv")) & 
     !any(str_detect(file, c('ORIG', 'OLD')))){
    dt.TR <- read.csv(paste0(path.TR, file), stringsAsFactors = FALSE, 
                      header = TRUE, row.names = NULL)
    if(!(2005 %in% dt.TR$Year) & (2005 %in% dt$Year) &
       length(names(dt)) == length(names(dt.TR))){
      names(dt) <- names(dt.TR)
      dt.TR <- rbind(dt.TR, dt[dt$Year == 2005,])
      dt.TR <- dt.TR[order(dt.TR$Year),]
      write.csv(dt.TR, paste0(path.TR, file), row.names = FALSE)
      print(file)
    }else if (2005 %in% dt.TR$Year){
      print(paste(file, "has 2005 year data"))
    }else if(length(names(dt)) != length(names(dt.TR))){
      print(paste(file, "has different field names"))
    }else if(!(2005 %in% dt$Year)){
      print(paste(file, "has following years"))
      print(unique(dt$Year))
    }
  }
}

# "bzone_parking.csv has different field names"
# add "PropNonWrkTripPay"
file = "bzone_parking.csv"
dt <- read.csv(paste0(path, file), stringsAsFactors = FALSE, 
               header = TRUE, row.names = NULL)
dt.TR <- read.csv(paste0(path.TR, file), stringsAsFactors = FALSE, 
                  header = TRUE, row.names = NULL)
names(dt)
names(dt.TR)
dt.TR <- rbind(dt.TR[,names(dt)], dt[dt$Year == 2005,]) 
dt.TR <- dt.TR[order(dt.TR$Year),]
attach(dt.TR)
dt.TR$PropNonWrkTripPay = PropWkrPay * (1 - PropCashOut) 
detach(dt.TR)
write.csv(dt.TR, paste0(path.TR, file), row.names = FALSE)

# [1] "bzone_employment.csv has following years"
# [1] 2006 2010 2035 2040
file = "bzone_employment.csv"
dt <- read.csv(paste0(path, file), stringsAsFactors = FALSE, 
               header = TRUE, row.names = NULL)
dt.TR <- read.csv(paste0(path.TR, file), stringsAsFactors = FALSE, 
                  header = TRUE, row.names = NULL)
dt.TR <- rbind(dt.TR[,names(dt)], dt[dt$Year == 2006,]) 
dt.TR <- dt.TR[order(dt.TR$Year),]
dt.TR$Year <- ifelse(dt.TR$Year == 2006, 2005, dt.TR$Year)
write.csv(dt.TR, paste0(path.TR, file), row.names = FALSE)

# "bzone_hh_inc_qrtl_prop.csv and bzone_network_design.csv
# has following years: 2010 2040"
# use the 2010-year data for 2005
#file = "bzone_network_design.csv"
file = "bzone_hh_inc_qrtl_prop.csv"
dt.TR <- read.csv(paste0(path.TR, file), stringsAsFactors = FALSE, 
                  header = TRUE, row.names = NULL)
dim(dt.TR[dt.TR$Year == 2010,])
head(dt.TR)
dt.TR <- rbind(dt.TR, dt.TR[dt.TR$Year == 2010,])
dt.TR$Year[1:67] <- 2005
dt.TR <- dt.TR[order(dt.TR$Year),]
write.csv(dt.TR, paste0(path.TR, file), row.names = FALSE)


