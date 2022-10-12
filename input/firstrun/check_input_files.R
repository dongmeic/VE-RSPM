# Objective: Examine input data from ODOT data files in the most recent VE version
# By: Dongmei Chen (dchen@lcog.org)
# August 24th, 2020 


inpath <- "C:/Users/DChen/all/VE-RSPM/runs/"
files <- list.files(path = paste0(inpath, "RSPM-Test/inputs"), pattern = "(.*)csv$")
inpath <- "C:/Users/DChen/all/VE-RSPM/VE-Installer-Windows-R4.0.2_2020-08-21.-.Copy/models/"
files1 <- list.files(path = paste0(inpath, "VERSPM/inputs"), pattern = "(.*)csv$")

files1[!(files1 %in% files)]
files[!(files %in% files1)]