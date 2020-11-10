# Objective: Organize input CSV files following the example case and run the staged models for sensitivity testing
# Source: run_sensitivity_tests.R
# By: Dongmei Chen (dchen@lcog.org)
# September 21st, 2020 

drive = 'E'

if(drive == 'C'){
  drive.path = 'C:/Users/DChen/all/VE-RSPM'
}else{
  drive.path = 'E:'
}

library(readxl)
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
head(infile)
path <- paste0(drive.path, '/VisionEval/models/')

# remove existing files and folders
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
comb <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)
scenarios <- comb$S

clean.files <- function(){
  path <- "E:/VisionEval/models/CLMPO-scenarios/"
  file <- list.files(path = paste0(path, '01-Base-Year-2010'), pattern = 'txt',
                   all.files = TRUE, full.names = TRUE)
  file.remove(file)
  file.remove(paste0(path, '01-Base-Year-2010/ModelState.Rda'))
  unlink(paste0(path, '01-Base-Year-2010/Datastore'), recursive = T)
  
  for(s in scenarios){
    i = which(scenarios==s) + 1
    path <- "E:/VisionEval/models/CLMPO-scenarios/"
    path <- paste0(path, 0, i, '-', s)
    file <- list.files(path = path, pattern = 'txt', all.files = TRUE,
                       full.names = TRUE)
    file.remove(file)
    file.remove(paste0(path, '/ModelState.Rda'))
    unlink(paste0(path, '/Datastore'), recursive = T)
    file <- list.files(path = path, pattern = 'csv', all.files = TRUE,
                       full.names = TRUE)
    file.remove(file)
    print(s)
  }
}

clean.files()

# copy files
copy.files <- function(path, s, i){
  currentfiles <- list.files(paste0(path, 'model'), recursive = FALSE)
  newlocation <- paste0(path,'CLMPO-scenarios/', 0, i, '-', s)
  if(file.exists(newlocation)){
    cat(paste0(newlocation, ' already exists.\n'))
  }else{
    dir.create(newlocation)
  }
  
  file.copy(from=paste0(path, "CLMPO-scenarios/01-Base-Year-2010/", currentfiles), to=newlocation, 
            overwrite = TRUE, recursive = TRUE, 
            copy.mode = TRUE)
  file.copy(from = paste0(path, 'CLMPO-Staged/02-Scenario-1-2040/run_model.R'),
            to=paste0(newlocation, "/run_model.R"), overwrite = TRUE, copy.mode = TRUE)
}

# strategy names and levels
strategies <- unique(infile$strategy_name)
all.levels <- list(C=c(0, 1, 2, 3), M=c(1, 2, 3), P=c(1, 2, 3), V=c(0, 1, 2, 3),
                   F=c(1, 2, 3), I=c(1, 2, 3))

# apply a cartesian product on the levels to get all combinations
comb <- expand.grid(all.levels)

# check the function with below set-up
# C=0; M=1; P=1; V=0; F=1; I=1; df=infile
# categories <- c("B", "C", "D", "E", "F", "G","I","P","T","V")
get.scenario.name <- function(C=0, M=1, P=1, V=0, F=1, I=1, df=infile, 
                              out=c('dataframe', 'scenario')){
  df.s = rbind(df[df$strategy_name == 'C' & df$strategy_level == C,],
        df[df$strategy_name == 'M' & df$strategy_level == M,],
        df[df$strategy_name == 'P' & df$strategy_level == P,],
        df[df$strategy_name == 'V' & df$strategy_level == V,],
        df[df$strategy_name == 'F' & df$strategy_level == F,],
        df[df$strategy_name == 'I' & df$strategy_level == I,])
  df.s <- df.s[order(df.s$category_name),]
  df.s <- unique(df.s[,c('category_name', 'policy_name')])
  if(length(df.s$category_name) > length(unique(df.s$category_name))){
    cat.df <- data.frame(table(df.s$category_name))
    cats <- as.character(cat.df[cat.df$Freq > 1,]$Var1)
    for(cat in cats){
      policyname <- min(df.s[df.s$category_name==cat,]$policy_name)
      df.s <- df.s[-which(df.s$category_name==cat & df.s$policy_name != policyname),]
    }
  }
  df.ss <- data.frame(t(df.s))
  colnames(df.ss) <- as.character(df.ss[1,])
  df.ss <- df.ss[-1,]
  df.ss.copy <- df.ss
  for(colnm in colnames(df.ss)){
    df.ss.copy[, colnm] <- paste0(colnm, df.ss.copy[, colnm])
  }
  df.ss$S <- apply(df.ss.copy, 1, paste, collapse = "")
  if(out == 'dataframe'){
    rownames(df.ss) <- NULL
    return(df.ss)
  }else{
    return(df.ss$S)
  }
}

for(i in 1:dim(comb)[1]){
  if(i == 1){
    scen.list <- get.scenario.name(out = 'dataframe')
  }else{
    comb.s <- comb[i,]
    scen.s <- get.scenario.name(C=comb.s$C, M=comb.s$M, P=comb.s$P, 
                                V=comb.s$V, F=comb.s$F, I=comb.s$I,
                                out = 'dataframe')
    scen.list <- rbind(scen.list, scen.s)
  }
}
comb$S <- scen.list$S

dim(scen.list)
write.csv(scen.list, paste0(infolder, "scenario_list_with_categories.csv"), row.names = FALSE)
write.csv(comb, paste0(infolder, "scenario_list.csv"), row.names = FALSE)

# start from a few folders
tests <- comb$S[1:5]
# tests <- sample(comb$S, 100)
# random.scen <- comb[sample(1:nrow(comb), 100),]
# subset.scen <- scen.list[1:5,]
# write.csv(subset.scen, paste0(infolder, "selected_scenario_list.csv"), row.names = FALSE)
path <- paste0(drive.path, '/VisionEval/models/')
copy.files(path, tests[1], 2)

read.infile <- function(){
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
  infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
  return(infile)
}

# check the function with below set-up
# scenario = 'B0C1D1E1F0G1I1P0T1V1'; stra = 'I'; cat = 'I'; csv = 'azone_per_cap_inc.csv'; var = 'HHIncomePC.2010'; cty = 'Eugene'; lvl = 1
modify.single.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1',
                                stra = 'I',
                                cat = 'I',
                                csv = 'azone_per_cap_inc.csv', 
                                var = 'HHIncomePC.2010',
                                cty = 'Eugene',
                                lvl = 1){
  infile <- read.infile()
  path <- paste0(drive.path, '/VisionEval/models/')
  path <- paste0(path, 'CLMPO-scenarios/')
  cat(paste('Modifying', csv, '...\n'))
  cat(paste0('The strategy is ', unique(infile[infile$strategy_name == stra,]$strategy_label),
             ', the category is ', cat, ', the variable is ', var, ', and the level is ', lvl, '.\n'))
  # check the folder name with the scenario name
  foldernm = grep(pattern = scenario, list.files(path), value = TRUE)
  input.csv <- read.csv(paste0(path, foldernm, "/inputs/", csv), stringsAsFactors = FALSE)
  target.df <- subset(infile, strategy_name == stra & category_name == cat & file == csv & 
                        variable == var & city == cty & policy_name == lvl)
  
  if(cty != 'NA'){
    v1 <- unique(input.csv[input.csv$Year == 2040 & substring(input.csv$Geo, 1, 3) %in% substring(cty, 1, 3), var])
  }else{
    v1 <- unique(input.csv[input.csv$Year == 2040, var])
  }
  
  if(var == 'CarSvcLevel'){
    v2 <- unique(target.df$value)
  }else{
    v2 <- unique(as.numeric(target.df$value))
    if(length(v2) != 1){
      cat(paste0('!!!!!!!The number of target value is ', length(v2), '...\n'))
    }
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

modify.scenario.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1', df=scen.list){
  cat(paste0('Modifying inputs for the scenario ', scenario, '...\n'))
  infile <- read.infile()
  # category to check
  stra.cat <- unique(infile[, c('strategy_name', 'category_name')])
  
  for(stra in unique(stra.cat$strategy_name)){
    cats <- subset(stra.cat, strategy_name == stra)[, 'category_name']$category_name
    # csv files to check
    cat.file <- unique(infile[infile$strategy_name == stra, c('category_name', 'file')])
    for(cat in cats){
      csvs <- subset(cat.file, category_name == cat)[, 'file']$file
      # variables to check
      file.var <- unique(infile[infile$strategy_name == stra & infile$category_name == cat, 
                                c('file', 'variable')])
      for(csv in csvs){
        vars <- subset(file.var, file == csv)[, 'variable']$variable
        # cities to check
        var.cty <- unique(infile[infile$file == csv,
                                 c('variable', 'city')])
        # levels to check
        var.lvl <- unique(infile[infile$file == csv,
                                 c('variable', 'policy_name')])
        for(var in vars){
          cities <- subset(var.cty, variable == var)[, 'city']$city
          lvls <- subset(var.lvl, variable == var)[, 'policy_name']$policy_name
          lvl <- as.numeric(df[df$S == scenario, cat])
          if('NA' %in% cities){
            if(lvl %in% lvls){
              modify.single.input(scenario = scenario,
                                  stra = stra, 
                                  cat = cat, 
                                  csv = csv, 
                                  var = var,
                                  cty = 'NA',
                                  lvl = lvl)
            }else{
              # adjust the high-level setting with the common baseline with level 1
              modify.single.input(scenario = scenario,
                                  stra = stra,
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
                                    stra = stra,
                                    cat = cat, 
                                    csv = csv, 
                                    var = var,
                                    cty = city,
                                    lvl = lvl)
              }else{
                modify.single.input(scenario = scenario,
                                    stra = stra,
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
  }
  cat(paste0("The input folder for scenario ", scenario, " is ready!\n")) 
}

# test the functions
# modify.single.input()
# modify.scenario.input()

# step 1: copy folders and modify input files
#scenarios <- subset.scen$S
scenarios <- comb$S
start.time <- Sys.time()
for(s in scenarios){
  print(Sys.time())
  i = which(scenarios==s) + 1
  copy.files(path, s, i)
  modify.scenario.input(scenario = s)
}
Sys.time() - start.time
# 22.17732 mins
cat(paste('It took that much time to create', length(scenarios), 'folders...\n'))

# in case the process has been interruped 
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
comb <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)

# step 2: run the model
rspm <- openModel(paste0(path, 'CLMPO-scenarios'))
start.time <- Sys.time()
print(start.time)
rspm$run()
# for(i in 2:length(scenarios)){
#   rspm$run(stage = i)
# }
Sys.time() - start.time

# step 3: get the output measures
setwd(paste0(path, 'CLMPO-scenarios'))
start.time <- Sys.time()
for(runnm in c(10, 100, 1000,10000)){
  source(paste0(path,"CLMPO-scenarios/CLMPO-Query-Script.R"))
}
Sys.time() - start.time

# infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
scenarios <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)
scenarios <- scenarios$S
# tests <- scenarios$S[1:5]
combine.output <- function(tests){
  path = paste0(path, "CLMPO-scenarios/")
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
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/"
  WriteTime <- gsub("[^0-9.-]", "_", Sys.time())
  write.csv(output, paste0(infolder, 'Measures_Sensitivity_Output_', WriteTime, '.csv'), row.names = FALSE)
}

# step 4: combine all output files
combine.output(scenarios)
