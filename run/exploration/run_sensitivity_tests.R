# Objective: Organize input CSV files and run the staged models for sensitivity testing
# Source: sensitivity_testing_input.R, check_output.R
# By: Dongmei Chen (dchen@lcog.org)
# September 18th, 2020 

library(readxl)
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "plan")
head(infile)
path <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-scenarios/"

# copy files
copy.files <- function(path, s, i){
  currentfiles <- list.files(paste0(path, "01-Base-Year-2010"), recursive = FALSE)
  newlocation <- paste0(path, 0, i, "-", s)
  if(file.exists(newlocation)){
    cat(paste0(newlocation, ' already exists.\n'))
  }else{
    dir.create(newlocation)
  }
  
  file.copy(from=paste0(path, "01-Base-Year-2010/", currentfiles), to=newlocation, 
            overwrite = TRUE, recursive = TRUE, 
            copy.mode = TRUE)
  file.copy(from = "C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-Staged/02-Scenario-1-2040/run_model.R",
            to=paste0(newlocation, "/run_model.R"), overwrite = TRUE, copy.mode = TRUE)
}

# review categories and levels
categories <- unique(infile$category_name)
all.levels <- list(B=c(1, 2), C=c(1, 2, 3), D=c(1, 2, 3), E=c(1, 2, 3),
                   F=c(1, 2, 3), G=c(1, 2, 3), I=c(1, 2, 3), P=c(1, 2, 3), 
                   T=c(1, 2, 3), V=c(1, 2))

# apply a cartesian product on the levels to get all combinations
comb <- expand.grid(all.levels)
comb.letter <- comb
for(colnm in colnames(comb)){
  comb.letter[, colnm] <- paste0(colnm, comb.letter[, colnm])
}
comb$S <- apply(comb.letter, 1, paste, collapse = "")
dim(comb)
write.csv(comb, paste0(infolder, "scenario_list.csv"), row.names = FALSE)

# start from a few folders
#tests <- comb$S[1:5]
#tests <- sample(comb$S, 100)
#random.scen <- comb[sample(1:nrow(comb), 100),]
subset.scen <- comb[1:10,]
write.csv(subset.scen, paste0(infolder, "selected_scenario_list.csv"), row.names = FALSE)
#copy.files(path, tests[1], 2)

read.infile <- function(){
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
  infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "plan")
  return(infile)
}

modify.single.input <- function(scenario = 'B1C1D1E1F1G1I1P1T1V1',
                                cat = 'I',
                                csv = 'azone_per_cap_inc.csv', 
                                var = 'HHIncomePC.2010',
                                cty = 'Eugene',
                                lvl = 1){
  infile <- read.infile()
  path <- 'C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-scenarios/'
  cat(paste('Modifying', csv, '...\n'))
  cat(paste0('The category is ', cat, ', the variable is ', var, ', and the level is ', lvl, '.\n'))
  # check the folder name with the scenario name
  foldernm = grep(pattern = scenario, list.files(path), value = TRUE)
  input.csv <- read.csv(paste0(path, foldernm, "/inputs/", csv), stringsAsFactors = FALSE)
  target.df <- subset(infile, category_name == cat & file == csv & variable == var & city == cty & policy_name == lvl)
  
  if(cty != 'NA'){
    v1 <- unique(input.csv[input.csv$Year == 2040 & substring(input.csv$Geo, 1, 3) %in% substring(cty, 1, 3), var])
  }else{
    v1 <- unique(input.csv[input.csv$Year == 2040, var])
  }
  
  if(var == 'CarSvcLevel'){
    v2 <- target.df$value
  }else{
    v2 <- as.numeric(target.df$value)
  }
  
  if(v2 %in% v1){
    cat('The values are the same or the modified value is in the original value list...\n')
  }else{
    cat(paste0('The original value for the variable ', var, ' is ', v1, ";\n"))
    if(var %in% names(input.csv)){
      if(cty != 'NA'){
        input.csv[input.csv$Year == 2040 & substring(input.csv$Geo, 1, 3) %in% substring(cty, 1, 3), var] <- v2
      }else{
        input.csv[input.csv$Year == 2040, var] <- v2
      }
      
      cat(paste0("The value has been changed to ", v2, ".\n"))
    }else{
      cat("The variable is NOT in the table, check again.\n")
    }
    
  }
  
  #print(input.csv)
  write.csv(input.csv, paste0(path, foldernm, "/inputs/", csv), row.names = FALSE)
}

modify.scenario.input <- function(scenario = 'B1C1D1E1F1G1I1P1T1V1', df=comb){
  cat(paste0('Modifying inputs for the scenario ', scenario, '...\n'))
  infile <- read.infile()
  # csv files to check
  cat.file <- unique(infile[, c('category_name', 'file')])
  # variables to check
  file.var <- unique(infile[, c('file', 'variable')])
  # cities to check
  var.cty <- unique(infile[, c('variable', 'city')])
  # levels to check
  var.lvl <- unique(infile[, c('variable', 'policy_name')])
  
  for(cat in unique(infile$category_name)){
    csvs <- subset(cat.file, category_name == cat)[, 'file']$file
    for(csv in csvs){
      vars <- subset(file.var, file == csv)[, 'variable']$variable
      for(var in vars){
        cities <- subset(var.cty, variable == var)[, 'city']$city
        lvls <- subset(var.lvl, variable == var)[, 'policy_name']$policy_name
        lvl <- df[df$S == scenario, cat]
        if('NA' %in% cities){
          if(lvl %in% lvls){
            modify.single.input(scenario = scenario,
                                cat = cat, 
                                csv = csv, 
                                var = var,
                                cty = 'NA',
                                lvl = lvl)
          }else{
            modify.single.input(scenario = scenario,
                                cat = cat, 
                                csv = csv, 
                                var = var,
                                cty = 'NA',
                                lvl = 1)
          }
        }else{
          for(city in cities){
            if(lvl %in% lvls){
              modify.single.input(scenario = scenario,
                                  cat = cat, 
                                  csv = csv, 
                                  var = var,
                                  cty = city,
                                  lvl = lvl)
            }else{
              modify.single.input(scenario = scenario,
                                  cat = cat, 
                                  csv = csv, 
                                  var = var,
                                  cty = city,
                                  lvl = 1)
            }
          }
        }
      }
    }
  }
  
  cat(paste0("The input folder for scenario ", scenario, " is ready!\n")) 
}

# test the functions
modify.single.input()
modify.scenario.input()

# step 1: copy folders and modify input files
tests <- subset.scen$S
start.time <- Sys.time()
for(s in tests){
  print(Sys.time())
  i = which(tests==s) + 1
  copy.files(path, s, i)
  modify.scenario.input(scenario = s)
}
Sys.time() - start.time
cat(paste('It took that much time to create', length(tests), 'folders...\n'))

# step 2: run the model
rspm <- openModel("CLMPO-scenarios")
start.time <- Sys.time()
print(start.time)
rspm$run()
Sys.time() - start.time

# step 3: get the output measures
setwd("C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-scenarios")
source("CLMPO-Query-Script.R")

# infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
# scenarios <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)
# tests <- scenarios$S[1:5]
combine.output <- function(tests, n){
  path = "C:/Users/DChen/all/VE-RSPM/VisionEval/models/CLMPO-scenarios/"
  for(test in tests){
    foldernm <- grep(pattern = test, list.files(path), value = TRUE)
    outfile <- grep(pattern = test, list.files(foldernm), value = TRUE)
    out <- read.csv(paste0(path, foldernm, '/', outfile), stringsAsFactors = FALSE)
    if(test == tests[1]){
      output <- out
      if('X2010' %in% names(output)){
        names(output)[which(names(output) %in% c('X2010', 'X2040'))] <- c('Value2010', test)
      }else{
        names(output)[dim(output)[2]] <- test
      }
      
    }else{
      output <- cbind(output, out[,'X2040'])
      names(output)[dim(output)[2]] <- test
    }
    cat(paste('Added measures from scenario', test, '...\n'))
  }
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/output/"
  write.csv(output, paste0(infolder, 'Measures_Sensitivity_Output_', n, '.csv'), row.names = FALSE)
}

# step 4: combine all output files
combine.output(tests, 5)
