
copy.files <- function(path, s, i, f='CLMPO-scenarios'){
  currentfiles <- list.files(paste0(path, 'model'), recursive = FALSE)
  newlocation <- paste0(path, f, '/', 0, i, '-', s)
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

read.infile <- function(){
  infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/"
  infile <- read_excel(paste0(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
  return(infile)
}

modify.single.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1',
                                stra = 'I',
                                cat = 'I',
                                csv = 'azone_per_cap_inc.csv', 
                                var = 'HHIncomePC.2010',
                                cty = 'Eugene',
                                lvl = 1,
                                f = 'CLMPO-scenarios'){
  infile <- read.infile()
  path <- paste0(drive.path, '/VisionEval/models/')
  path <- paste0(path, f, '/')
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

modify.scenario.input <- function(scenario = 'B0C1D1E1F0G1I1P0T1V1', df=scen.list,
                                  f = 'CLMPO-scenarios'){
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
                                  lvl = lvl,
                                  f = f)
            }else{
              # adjust the high-level setting with the common baseline with level 1
              modify.single.input(scenario = scenario,
                                  stra = stra,
                                  cat = cat, 
                                  csv = csv, 
                                  var = var,
                                  cty = 'NA',
                                  lvl = 1,
                                  f = f)
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
                                    lvl = lvl,
                                    f = f)
              }else{
                modify.single.input(scenario = scenario,
                                    stra = stra,
                                    cat = cat, 
                                    csv = csv, 
                                    var = var,
                                    cty = city,
                                    lvl = 1,
                                    f = f)
              }
            }
          }
        }
      }
    }
  }
  cat(paste0("The input folder for scenario ", scenario, " is ready!\n")) 
}

copy.output <- function(s="02-Scenario1", f="ETSP-scenarios"){
  if(s=="reference"){
    inpath <- paste0("E:/VisionEval/models/", s)
  }else{
    inpath <- paste0("E:/VisionEval/models/", f, "/", s)
  }
  df <- file.info(list.files(inpath, pattern =s, full.names = T))
  target <- rownames(df)[which.max(df$mtime)]
  newlocation <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/memo/output"
  file.copy(from=target, to=newlocation, 
            overwrite = TRUE, copy.mode = TRUE)
  if(s=="reference"){
    file.rename(paste0(newlocation, "/", gsub(paste0(inpath, "/"), "", target)),
                paste0(newlocation, "/Reference.csv"))
  }else{
    file.rename(paste0(newlocation, "/", gsub(paste0(inpath, "/"), "", target)),
                paste0(newlocation, "/", gsub(".*-", "", s), ".csv"))
  }
}