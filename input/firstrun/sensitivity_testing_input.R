# Objective: Organize input CSV files for sensitivity testing
# By: Dongmei Chen (dchen@lcog.org)
# September 11th, 2020 

library(readxl)
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "plan")
head(infile)
path <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/"

# copy files
# can remove datastore, log, modelstate before copying, and create a new folder
copy.files <- function(path, s){
  currentfiles <- list.files(paste0(path, "model"), recursive = FALSE)
  newlocation <- paste0(path, s)
  if(file.exists(newlocation)){
    cat(paste0(newlocation, ' already exists.\n'))
  }else{
    dir.create(newlocation)
  }
   
  file.copy(from=paste0(path, "model/", currentfiles), to=newlocation, 
            overwrite = TRUE, recursive = TRUE, 
            copy.mode = TRUE)
}

# review categories and levels
categories <- unique(infile$category_name)
all.levels <- list(B=c(0, 1, 2), C=c(1, 2, 3), D=c(1, 2, 3), E=c(1, 2, 3),
                   F=c(0, 1, 2, 3), G=c(1, 2, 3), I=c(1, 2, 3), P=c(0, 1, 2, 3), 
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
tests <- comb$S[1:5]
copy.files(path, tests[1])


read.infile <- function(){
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
  infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "scenario")
  return(infile)
}

modify.single.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1',
                                cat = 'I',
                                csv = 'azone_per_cap_inc.csv', 
                                var = 'HHIncomePC.2010',
                                cty = 'Eugene',
                                lvl = 1){
  infile <- read.infile()
  path <- 'C:/Users/DChen/all/VE-RSPM/VisionEval/models/'
  cat(paste('Modifying', csv, '...\n'))
  cat(paste0('The category is ', cat, ', the variable is ', var, ', and the level is ', lvl, '.\n'))
  input.csv <- read.csv(paste0(path, scenario, "/inputs/", csv), stringsAsFactors = FALSE)
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
  write.csv(input.csv, paste0(path, scenario, "/inputs/", csv), row.names = FALSE)
}

modify.scenario.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1', df=comb){
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


modify.single.input()
modify.scenario.input()


for(s in tests){
  start.time <- Sys.time()
  print(start.time)
  copy.files(path, s)
  modify.scenario.input(scenario = s)
}
Sys.time() - start.time
cat(paste('It took that much time to create', length(tests), 'folders...\n'))
