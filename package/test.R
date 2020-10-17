# Objective: test the functions from R packages
# By: Dongmei Chen (dchen@lcog.org)
# October 8th, 2020
Rlib <- "C:/Users/DChen/all/VE-RSPM/VisionEval/ve-lib/"
lazyLoad(filebase = file.path(Rlib, "VELandUse/R/VELandUse"), envir = parent.frame(), filter = function(x) TRUE)

if(drive == 'C'){
  drive.path = 'C:/Users/DChen/all/VE-RSPM'
}else{
  drive.path = 'E:'
}


path <- paste0(drive.path, "/VisionEval/models/CLMPO-scenarios/01-Base-Year-2010/Datastore/2010/Bzone/")
load(paste0(path, "Pop.Rda"))
Pop <- Dataset
load(paste0(path, "UrbanArea.Rda"))
UrbanArea <- Dataset
Pop/UrbanArea 