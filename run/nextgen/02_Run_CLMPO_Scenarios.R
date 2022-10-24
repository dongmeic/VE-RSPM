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
      inputfiles <- unique(scefile[scefile$category_name==catnm & scefile$policy_name == policynm,]$file)
      for(inputfile in inputfiles){
        file.copy(from=file.path(scefolder, "inputs", inputfile), to=filepath, 
                  overwrite = TRUE, recursive = TRUE, copy.mode = TRUE)
        cat(paste0(filepath, "/", inputfile, '\n'))
      }
    }
  }
}
copy_files()

# modify the inputs
modify_single_input <- function(scefile = infile,
                                scefolder = "models/VERSPM-scenarios-cat",
                                cat = 'I',
                                csv = 'azone_per_cap_inc.csv', 
                                var = 'HHIncomePC.2010',
                                cty = 'Eugene',
                                lvl = 1,
                                writeout = TRUE){
  cat(paste('Modifying', csv, '...\n'))
  cat(paste0('The strategy is ', unique(scefile[scefile$category_name == cat,]$strategy_label),
             ', the category is ', cat, ', the variable is ', var, ', and the level is ', lvl, '.\n'))
  filepath <- file.path(scefolder, "scenarios", cat, lvl)
  input.csv <- read.csv(file.path(filepath, csv),  stringsAsFactors = FALSE)
  target.df <- subset(scefile, category_name == cat & file == csv & 
                        variable == var & city == cty & policy_name == lvl)
  
  # the value to check and modify
  if(cty != 'NA'){
    v1 <-  unique(input.csv[input.csv$Year == 2040 & input.csv$Geo %in% cty, var])
  }else{
    v1 <- unique(input.csv[input.csv$Year == 2040, var])
  }
  
  # the value is used to modify
  if(var == 'CarSvcLevel'){
    v2 <- unique(target.df$value)
  }else{
    v2 <- unique(as.numeric(target.df$value))
    if(length(v2) != 1){
      cat(paste0('!!!!!!!The number of target value is ', length(v2), '...\n'))
    }
  }
  
  if(v2 %in% v1){
    cat('The values are exactly the same or the modified value is in the original value list...\n')
  }else{
    cat('The values are possibly different in data types or completely different...\n')
    if(var %in% names(input.csv)){
      if(cty != 'NA'){
        cat(paste0('The original value for the variable ', var, ' is ', v1, ' in ', cty, ";\n"))
        input.csv[input.csv$Year == 2040 & input.csv$Geo %in% cty, var] <- v2
      }else{
        cat(paste0('The original value for the variable ', var, ' is ', v1, ";\n"))
        input.csv[input.csv$Year == 2040, var] <- v2
      }
      
      cat(paste0("The value has been changed to ", v2, ".\n"))
    }else{
      cat("The variable is NOT in the table, check again.\n")
    }
    
  }
  
  if(writeout){
    write.csv(input.csv, file.path(filepath, csv), row.names = FALSE)
  }else{
    return(input.csv)
  }
}

modify_inputs <- function(scefile = infile, scefolder = "models/VERSPM-scenarios-cat"){
  catnms <- unique(scefile$category_name)
  for(catnm in catnms){
    policynms <- unique(scefile[scefile$category_name == catnm,]$policy_name) 
    for(policynm in policynms){
      filepath <- file.path(scefolder, "scenarios", catnm, policynm)
      inputfiles <- scefile[scefile$category_name==catnm & scefile$policy_name == policynm,]$file
      for(inputfile in inputfiles){
        # file to change
        inputdata <- read.csv(file.path(filepath, inputfile))
        # data used for input change
        datainput <- scefile[scefile$category_name == catnm & 
                               scefile$policy_name == policynm &
                               scefile$file == inputfile,]
        vars <- unique(datainput$variable)
        # cities to check
        var.cty <- unique(scefile[scefile$file == inputfile,
                                 c('variable', 'city')])
        # levels to check
        var.lvl <- unique(scefile[scefile$file == inputfile,
                                 c('variable', 'policy_name')])
        for(var in vars){
          cities <- subset(var.cty, variable == var)[, 'city']$city
          lvls <- subset(var.lvl, variable == var)[, 'policy_name']$policy_name
          lvl <- policynm
          if('NA' %in% cities){
            if(lvl %in% lvls){
              modify_single_input(cat = catnm, 
                                  csv = inputfile, 
                                  var = var,
                                  cty = 'NA',
                                  lvl = lvl)
            }else{
              # adjust the high-level setting with the common baseline with level 1
              modify_single_input(cat = cat, 
                                  csv = inputfile, 
                                  var = var,
                                  cty = 'NA',
                                  lvl = 1)
            }
          }else{
            for(city in cities){
              if(lvl %in% lvls){
                modify_single_input(cat = cat, 
                                    csv = inputfile, 
                                    var = var,
                                    cty = city,
                                    lvl = lvl)
              }else{
                modify_single_input(cat = cat, 
                                    csv = inputfile, 
                                    var = var,
                                    cty = city,
                                    lvl = 1)
              }
            }
          }
        }
      }
    }
    cat(paste0("The input folder for category ", catnm, " is ready!\n")) 
  }
}

modify_inputs()
