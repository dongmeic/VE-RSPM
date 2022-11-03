# Objective: Run VE 3.0 with the CLMPO scenarios inputs with the staged model setup
# By: Dongmei Chen (dchen@lcog.org)
# November 3rd, 2022
# References: 
# 1. T:\DCProjects\GitHub\VE-RSPM\run\firstrun\run_example_scenarios.R;
# 2. T:\DCProjects\GitHub\VE-RSPM\run\nextgen\02_Run_CLMPO_Scenarios.R


# steps:
# 1. create a folder and organize the input files (copy from scenarios-cat);
# 2. run the model

folder_to_create = "models/CLMPO-scenarios"
if(file.exists(folder_to_create)){
  cat(paste0(folder_to_create, ' already exists.\n'))
}else{
  dir.create(folder_to_create)
}

# copy the folders "defs", "inputs", "scripts" from scenarios-cat
folders <- c("defs", "inputs", "scripts")
for(folder in folders){
  file.copy(file.path("models/CLMPO-scenarios-cat", folder), "models/CLMPO-scenarios", recursive=TRUE)
  print(file.path("models/CLMPO-scenarios", folder))
}

# edit the scripts folder

# write the configuration

# create a base year folder
folder_to_create = "models/CLMPO-scenarios/BaseYear"
if(file.exists(folder_to_create)){
  cat(paste0(folder_to_create, ' already exists.\n'))
}else{
  dir.create(folder_to_create)
}

# configure the base year model
BaseYear_config <- list(
  Scenario = "CLMPO Scenario Base Year",
  Description = "Model base year for the CLMPO selected scenarios set up by stage",
  Years = '2010'
)
viewSetup(Param_ls=BaseYear_config)
configFile <- file.path(folder_to_create, "visioneval.cnf")
cat(configFile,"\n")
yaml::write_yaml(BaseYear_config,configFile)

# create a future year folder
folder_to_create = "models/CLMPO-scenarios/FutureYear"
if(file.exists(folder_to_create)){
  cat(paste0(folder_to_create, ' already exists.\n'))
}else{
  dir.create(folder_to_create)
}

# configure the base year model
FutureYear_config <- list(
  Scenario = "CLMPO Scenario Future Year",
  Description = "Model future year for the CLMPO selected scenarios set up by stage",
  Years = '2040'
)
viewSetup(Param_ls=FutureYear_config)
configFile <- file.path(folder_to_create, "visioneval.cnf")
cat(configFile,"\n")
yaml::write_yaml(FutureYear_config,configFile)

# configure the model stages for scenarios
path <- "T:/DCProjects/Modeling/VE-RSPM/Notes/Scenarios"
scelist <- read.csv(file.path(path, "scenario_list_with_categories.csv"))

for(sce in scelist$S){
  print(sce)
  folder_to_create = file.path("models/CLMPO-scenarios/", sce)
  if(file.exists(folder_to_create)){
    cat(paste0(folder_to_create, ' already exists.\n'))
  }else{
    dir.create(folder_to_create)
    folder_to_create = file.path("models/CLMPO-scenarios", sce, "inputs")
    dir.create(folder_to_create)
  }
  for(cat in names(scelist)[1:10]){
    folder <- file.path("models/CLMPO-scenarios-cat/scenarios", 
                        cat, scelist[scelist$S == sce, cat])
    files <- list.files(folder)
    for(file in files){
      file.copy(file.path(folder,file), folder_to_create)
      print(file)
    }
  }
}

for(sce in scelist$S){
  AltFuture_config <- list(
    Scenario = "CLMPO Scenario Alternative Future",
    Description = paste("Model alternative future scenario",  sce, "for the CLMPO selected scenarios set up by stage"),
    Years = '2040'
  )
  configFile <- file.path("models/CLMPO-scenarios", sce, "visioneval.cnf")
  cat(configFile,"\n")
  yaml::write_yaml(AltFuture_config,configFile)
}

Scenario_Stage_config <- list(
  Model = "Staged Model for CLMPO Selected Scenarios",
  Region = "CLMPO",
  State = "OR",
  BaseYear = '2010',
  ModelStages = c(list(BaseYear = list(Dir = "BaseYear", Reportable = "yes"), 
                     FutureYear = list(Dir = "FutureYear", Reportable = "yes")),
            structure(names=scelist$S,
            lapply(scelist$S, function(s){
              return(list(Dir = s, Reportable = "yes"))}
            )))
)
viewSetup(Param_ls=Scenario_Stage_config)
configFile <- "models/CLMPO-scenarios/visioneval.cnf"
cat(configFile,"\n")
yaml::write_yaml(Scenario_Stage_config,configFile)

# try running the model
CLMPO_scenarios <- openModel("CLMPO-scenarios")
CLMPO_scenarios$run()

# try out running the base model (for debugging; need to set up the model folder first)
base.cl <- openModel("CLMPO-base")
base.cl$run()
