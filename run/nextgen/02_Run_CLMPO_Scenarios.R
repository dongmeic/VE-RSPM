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
print(wd)
scenarios.cat <- installModel("VERSPM",var="scenarios-cat")
scenarios.cat$run()
#scenarios.cat <- openModel("VERSPM-scenarios-cat")
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
  files <- list.files(path = 'models/CLMPO-scenarios-cat/scenarios', pattern = 'cnf',
                     all.files = TRUE, full.names = TRUE)
  file.remove(files)
  # delete files in folders
  unlink('models/CLMPO-scenarios-cat/scenarios', recursive = T)
}
# cleaned files and renamed the folder
#clean.files()

# create a new list of folders
# check existing input files
#infiles <- unique(unlist(lapply(dirfiles[2:25], function(x) str_split(x, "/")[[1]][3])))
scefolder = "models/CLMPO-scenarios-cat"
infiles <- list.files(file.path(scefolder, "inputs"), recursive = FALSE)
infiles_cl <- unique(infile$file)
infiles[!(infiles %in% infiles_cl)]
infiles_cl[!(infiles_cl %in% infiles)]

# scefile refers the scenario table, scefolder refers to the path where scenarios'input files are saved
create_dir <- function(scefile = infile, scefolder = "models/CLMPO-scenarios-cat"){
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

#create_dir()

# add the modified input file
copy_files <- function(scefile = infile, scefolder = "models/CLMPO-scenarios-cat"){
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
                                scefolder = "models/CLMPO-scenarios-cat",
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

  if((v2 %in% v1) | (abs(v2-v1) < 0.00000001)){
    cat('The values are the same or the modified value is in the original value list...\n')
  }else{
    # if(class(v1) != class(v2)){
    #   cat('The values are different in data types...\n')
    # }else{
    #   cat(paste('The value difference is', v1-v2))
    # }
    #cat('The values are possibly different in data types or completely different...\n')

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

modify_inputs <- function(scefile = infile, scefolder = "models/CLMPO-scenarios-cat"){
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

# create cnf files for configuration
# category (cat)
clmpo_scen_config_cat <- function(scefile = infile){
  catconfig <- lapply(unique(scefile$category_name), function(cat){
    i <- scefile$category_name==cat
    Label <- scefile$category_label[i][1]
    Description <- scefile$category_description[i][1]
    Files <- unique(scefile$file[i])
    Levels <- structure(names=NULL,lapply(unique(scefile$policy_name[i]), function(level){
      Label <- scefile$policy_label[i & scefile$policy_name==level][1]
      Description <- scefile$policy_description[i & scefile$policy_name==level][1]
      attr(Label, "quoted") <- TRUE
      attr(Description, "quoted") <- TRUE
      return((list(Name=as.integer(level),
                   Label=Label,
                   Description=Description)))
    }))
    attr(Label, "quoted") <- TRUE
    attr(Description, "quoted") <- TRUE
    return(list(Name=cat,
                Label=Label,
                Description=Description,
                Files=Files,
                Levels=Levels))
  })
  return(catconfig)
}

viewSetup(Param_ls=clmpo_scen_config_cat())

# strategy (str)
clmpo_scen_config_str <- function(scefile = infile){
  catconfig <- lapply(unique(scefile$strategy_name), function(str){
    i <- scefile$strategy_name==str
    Label <- scefile$strategy_label[i][1]
    Description <- scefile$strategy_description[i][1]
    Levels <- structure(names=NULL,lapply(unique(scefile$strategy_level[i]), function(level){
      Name <- as.integer(level)
      CatNames <- scefile$category_name[i & scefile$strategy_level==level]
      j <- i & scefile$strategy_level==level
      Inputs <- structure(names=NULL,lapply(unique(CatNames), function(Name){
        # possibly with multiple variables for different levels
        Level <- max(scefile$policy_name[j & scefile$category_name==Name])
        return((list(Name=Name,
                     Level=as.integer(Level))))
      }))
      return((list(Name=Name,
                   Inputs=Inputs)))
    }))
    attr(Label, "quoted") <- TRUE
    attr(Description, "quoted") <- TRUE
    return(list(Name=Label,
                Description=Description,
                Levels=Levels))
  })
  return(catconfig)
}
viewSetup(Param_ls=clmpo_scen_config_str())

clmpo_scen_config <- list(
  StartFrom = "stage-pop-future",
  ScenarioElements = clmpo_scen_config_cat(),
  ScenarioCategories = clmpo_scen_config_str()
)

configFile <- file.path(scefolder, "scenarios", "visioneval.cnf")
cat(configFile,"\n")
yaml::write_yaml(clmpo_scen_config,configFile)



self=private=NULL
ve.scenario.scenconfig <- function() {
  scenconfig <- lapply( self$Elements,
                        function(scen) {
                          Instructions <- if( "Instructions" %in% names(scen) )
                          { scen$Instructions } else { scen$Description }
                          Levels <- list()
                          Levels[[1]] <- baseScenarioLevel
                          for ( level in scen$Levels ) Levels[[length(Levels)+1]] <- level
                          return( list(
                            NAME=scen$Name,
                            LABEL=scen$Label,
                            DESCRIPTION=scen$Description,
                            INSTRUCTIONS=Instructions,
                            LEVELS=structure(
                              names=NULL,
                              lapply( Levels,
                                      function(level) {
                                        return( list(
                                          NAME=level$Name,
                                          LABEL=level$Label,
                                          DESCRIPTION=level$Description
                                        ) )
                                      }
                              )
                            )
                          ) )
                        }
  )
  names(scenconfig) <- NULL # Don't have named objects (visualizer does not like that!)
  return( scenconfig )
}
















ve.scenario.catconfig <- function() {
  # iterate over self$Categories
  catconfig <- structure( names=NULL,
                          lapply( self$Categories,
                                  function(cat) {
                                    Label <- if ( "Label" %in% names(cat) ) cat$Label else cat$Name
                                    Description <- if ( "Description" %in% names(cat) ) cat$Description else NULL
                                    baseCategoryLevel <- cat$Levels[[1]]
                                    baseCategoryLevel$Name <- "0"
                                    baseCategoryLevel$Inputs <- lapply( baseCategoryLevel$Inputs,
                                                                        function(inp) {
                                                                          return( ( list( Name=inp$Name, Level="0" ) ) )
                                                                        }
                                    )
                                    # Build baseCategoryLevel as list of of NAME/LEVEL pairs
                                    # where NAME is the NAME from each cat$Levels, and LEVEL is "0"
                                    Levels <- list()
                                    Levels[[1]] <- baseCategoryLevel
                                    for ( level in cat$Levels ) Levels[[length(Levels)+1]] <- level
                                    return( list(
                                      NAME=cat$Name,
                                      LABEL=Label,
                                      DESCRIPTION=Description,
                                      LEVELS=lapply( Levels,
                                                     function(level) {
                                                       return( list(
                                                         NAME=level$Name,
                                                         INPUTS=lapply(level$Inputs,
                                                                       function(input) {
                                                                         return( list(
                                                                           NAME=input$Name,
                                                                           LEVEL=input$Level
                                                                         ) )
                                                                       }
                                                         )
                                                       ) )
                                                     }
                                      )
                                    ) )
                                  }
                          )
  )
  return(catconfig)
}
self=private=NULL
ve.scenario.scenconfig <- function() {
  scenconfig <- lapply( self$Elements,
                        function(scen) {
                          Instructions <- if( "Instructions" %in% names(scen) )
                          { scen$Instructions } else { scen$Description }
                          Levels <- list()
                          Levels[[1]] <- baseScenarioLevel
                          for ( level in scen$Levels ) Levels[[length(Levels)+1]] <- level
                          return( list(
                            NAME=scen$Name,
                            LABEL=scen$Label,
                            DESCRIPTION=scen$Description,
                            INSTRUCTIONS=Instructions,
                            LEVELS=structure(
                              names=NULL,
                              lapply( Levels,
                                      function(level) {
                                        return( list(
                                          NAME=level$Name,
                                          LABEL=level$Label,
                                          DESCRIPTION=level$Description
                                        ) )
                                      }
                              )
                            )
                          ) )
                        }
  )
  names(scenconfig) <- NULL # Don't have named objects (visualizer does not like that!)
  return( scenconfig )
}

ve.scenario.scenconfig()


# try out running the scenarios
scenarios.cat.cl <- openModel("CLMPO-scenarios-cat")
scenarios.cat.cl$run()
