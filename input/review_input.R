
# Objective: Review CLMPO input data for reference scenario
# By: Dongmei Chen (dchen@lcog.org)
# July 24th, 2020

#library(xlsx)
library(readxl)

#setwd('//clsrv111.int.lcog.org/transpor/Models/VisionEval/CLMPO_VE-R3.6.1.2019-09-18/models/VERSPM')
setwd('C:/Users/DChen/all/VE-RSPM/VisionEval/models/model')
# list CSV files
# csvfiles <- list.files(path = "./SA_Reference/inputs", pattern = ".csv")
csvfiles <- list.files(path = "./inputs", pattern = ".csv")
print(csvfiles)
#csvfiles <- csvfiles[-1]

# check input in the file summary
# file.summary <- read.xlsx('C:/Users/clid1852/OneDrive - lanecouncilofgovernments/VE-RSPM/VE-RSPM_File_Summary_20200501.xlsx',
#                           startRow = 3, endRow = 61, sheetName = "Inputs")
file.summary <- read_excel('C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/guidance/FileSummary/VE-RSPM_File_Summary_20200501.xlsx',
                           skip=2, sheet = "Inputs")
inputs <- grep(".csv", as.character(file.summary$Input), value = TRUE)

# check what is missing 
missing <- inputs[!(inputs %in% c(csvfiles, 'deflators.csv', 'units.csv', 'geo.csv'))][-1]
# c('region_hh_driver_adjust_prop.csv',
#   'region_hh_ave_driver_per_capita.csv') %in% csvfiles
# check if there is extra
extra <- csvfiles[!(csvfiles %in% inputs)]

# from TR files
#TR_path <- "./SA_Reference/CLMPO_TR_Fileset"
TR_path <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/TR-Scenario/inputs"
TR_files <- list.files(path = TR_path, pattern = ".csv")
still.missing <- missing[!(missing %in% TR_files)]
replacement <- missing[(missing %in% TR_files)]
newfiles <- TR_files[!(TR_files %in% csvfiles)]

sum(TR_files %in% csvfiles)

# review input data
sink("data_review.txt")
for(file in csvfiles){
  dt <- read.csv(paste0("./SA_Reference/inputs/", file), stringsAsFactors = FALSE, 
                 header = TRUE, row.names = NULL)
  if('row.names' %in% names(dt)){
    colnames(dt) <- c(colnames(dt)[-1], NULL)
    if(NA %in% names(dt)){
      dt <- dt[,-which(is.na(names(dt)))]
    }
  }
  print(file)
  print(dt)
}
sink()

csvfiles <- list.files(path = "./inputs", pattern = ".csv")
sink("data_review.txt")
for(file in csvfiles){
  dt <- read.csv(paste0("./inputs/", file), stringsAsFactors = FALSE, 
                 header = TRUE, row.names = NULL)
  if('row.names' %in% names(dt)){
    colnames(dt) <- c(colnames(dt)[-1], NULL)
    if(NA %in% names(dt)){
      dt <- dt[,-which(is.na(names(dt)))]
    }
  }
  print(file)
  print(dt)
}
sink()
