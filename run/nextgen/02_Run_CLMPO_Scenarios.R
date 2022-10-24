# Objective: Run VE 3.0 with the CLMPO scenarios inputs
# By: Dongmei Chen (dchen@lcog.org)
# October 14th, 2022 
# Compare to T:\DCProjects\GitHub\VE-RSPM\run\firstrun\run_example_scenarios.R

# steps:
# 1. make a copy of T:\Models\VisionEval\VE-3.0-Installer-Windows-R4.1.3_2022-05-27\models\VERSPM-scenarios-cat\scenarios
# 2. review the folders in the scenarios
# 3. modify the scenarios based on the CLMPO data

library(visioneval)
require(VEModel)
library(stringr)
library(readxl)

# run after the scenarios-cat model is installed and this step is irreversible
# make sure a copy of the scenarios folder exist in case of errors

# make the copy when errors occur
wd <- getwd()
print
scenarios.cat <- openModel("VERSPM-scenarios-cat")
dirfiles <- scenarios.cat$dir(scenarios=TRUE,all.files=TRUE)
# check the existing category names
catnm <- unique(unlist(lapply(dirfiles[2:25], function(x) str_split(x, "/")[[1]][1])))
# check the clmpo (cl) category names
infolder <- "T:/DCProjects/Modeling/VE-RSPM/Notes/Scenarios"
infile <- read_excel(file.path(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
catnm_cl <- unique(infile$category_name)
# clean the existing files in the scenarios folder
clean.files <- function(){
  # delete files
  files <- list.files(path = 'models/VERSPM-scenarios-cat/scenarios', pattern = 'cnf',
                     all.files = TRUE, full.names = TRUE)
  file.remove(files)
  # delete files in folders
  unlink('models/VERSPM-scenarios-cat/scenarios', recursive = T)
}
clean.files()
# create a new list of folders
# check existing input files
#infiles <- unique(unlist(lapply(dirfiles[2:25], function(x) str_split(x, "/")[[1]][3])))
scefolder = "models/VERSPM-scenarios-cat"
infiles <- list.files(file.path(scefolder, "inputs"), recursive = FALSE)
infiles_cl <- unique(infile$file)
infiles[!(infiles %in% infiles_cl)]
infiles_cl[!(infiles_cl %in% infiles)]

# scefile refers the scenario table, scefolder refers to the path where scenarios'input files are saved
create_dir <- function(scefile = infile, scefolder = "models/VERSPM-scenarios-cat"){
  catnms <- unique(scefile$category_name)
  for(catnm in catnms){
    folder_to_create <- file.path(scefolder, "scenarios", catnm)
    if(file.exists(folder_to_create)){
      cat(paste0(folder_to_create, ' already exists.\n'))
    }else{
      dir.create(folder_to_create)
    }
    policynms <-unique(scefile[scefile$category_name == catnm,]$policy_name) 
    for(policynm in policynms){
      subfolder_to_create <- file.path(scefolder, "scenarios", catnm, policynm)
      if(file.exists(subfolder_to_create)){
        cat(paste0(subfolder_to_create, ' already exists.\n'))
      }else{
        dir.create(subfolder_to_create)
      }
    }
  }
}

create_dir()

# add the modified input file
copy_files <- function(scefile = infile, scefolder = "models/VERSPM-scenarios-cat"){
  catnms <- unique(scefile$category_name)
  for(catnm in catnms){
    policynms <- unique(scefile[scefile$category_name == catnm,]$policy_name) 
    for(policynm in policynms){
      filepath <- file.path(scefolder, "scenarios", catnm, policynm)
      inputfiles <- infile[infile$category_name==catnm & infile$policy_name == policynm,]$file
      for(inputfile in inputfiles){
        file.copy(from=file.path(scefolder, "inputs", inputfile), to=filepath, 
                  overwrite = TRUE, recursive = TRUE, copy.mode = TRUE)
        cat(paste0(filepath, "/", inputfile, '\n'))
      }
    }
  }
}
copy_files()


