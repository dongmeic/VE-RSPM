# Objective: Run the version 2022-05-27 with the example data and document the function usages
# By: Dongmei Chen (dchen@lcog.org)
# October 11th, 2022 
# Compare to T:\DCProjects\GitHub\VE-RSPM\run\firstrun\run_VERSPM_CLMPO.R

# Open T:\Models\VisionEval\VE-3.0-Installer-Windows-R4.1.3_2022-05-27\VisionEval.Rproj
library(visioneval)

# reset work directory in case the default is changed
getwd()
# run only if the work directory has changed
setwd("T:/Models/VisionEval/VE-3.0-Installer-Windows-R4.1.3_2022-05-27")

# run example model
rspm <- installModel("VERSPM") # run base model, require an action y/n/c - n & c will return an error message "not installed"
rspm$run()
results <- rspm$results()
results$export()
query <- rspm$query("Full-Query")
query$run()
query$export()

######################################## Walkthrough 01-install ################################################################
installModel("VERSPM",var="") # this will list all the available models
dir("models") # check what is installed

######################################## Walkthrough 02-running ################################################################

rspm <- openModel("VERSPM-base") # this will open an installed model in the "models" folder or the parent folder the same with the Rproj

# > names(rspm)
# [1] ".__enclos_env__" "settings"        "Workers"         "FuturePlan"      "overallStatus"   "specSummary"     "loadedParam_ls"  "RunParam_ls"    
# [9] "modelResults"    "modelScenarios"  "modelStages"     "modelPath"       "modelName"       "clone"           "query"           "findstages"     
# [17] "results"         "archive"         "copy"            "setting"         "log"             "clear"           "dir"             "list"           
# [25] "scenarios"       "updateStatus"    "printStatus"     "stageStatus"     "print"           "run"             "plan"            "load"           
# [33] "valid"           "addstage"        "initstages"      "configure"       "initialize"     

rspm$dir() # show all the directory in the model

mod <- openModel("VERSPM-run")
mod$modelStages # confirm the scenario, e.g. "$`VERSPM-run` Scenario: VERSPM-run (Run Complete, Reportable)"
mod$modelResults # return results path
mod$setting() # return a list of setting options in character

# > mod$setting()
# [1] "Seed"                 "LogLevel"             "DatastoreName"        "ModelDir"             "ModelScript"          "ModelStateFile"      
# [7] "InputPath"            "InputDir"             "RunParamFile"         "GeoFile"              "UnitsFile"            "DeflatorsFile"       
# [13] "ModelParamFile"       "ParamDir"             "DatastoreType"        "SaveDatastore"        "ArchiveResultsName"   "ModelRoot"           
# [19] "ScriptsDir"           "ResultsDir"           "OutputDir"            "QueryDir"             "ScenarioDir"          "ScenarioConfig"      
# [25] "ExtractRootName"      "DisplayUnitsFile"     "QueryFileName"        "QueryOutputTemplate"  "QueryExtractTemplate" "RunStatusDelay"      
# [31] "RunPollDelay"         "Notes"                "Model"                "Region"               "State"                "Scenario"            
# [37] "Description"          "BaseYear"             "Years"                "ParamPath"        

######################################## Walkthrough 03-structure ################################################################
#   Tour the model directory structure

inputs <- mod$list(inputs = TRUE)
print(inputs[1:10,])
# > print(inputs[1:10,])
# SPEC      STAGE         PACKAGE           MODULE GROUP TABLE         NAME
# 2   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone     Age0to14
# 3   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    Age15to19
# 4   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    Age20to29
# 5   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    Age30to54
# 6   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    Age55to64
# 7   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    Age65Plus
# 8   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone    AveHhSize
# 9   Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone   Prop1PerHh
# 10  Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone  GrpAge0to14
# 11  Inp VERSPM-run VESimHouseholds CreateHouseholds  Year Azone GrpAge15to19

print( names(inputs) )
print( names( mod$list(inputs=TRUE,details=TRUE ) ) ) #  print all the names of possible metadata fields

details <- mod$list(inputs=TRUE,details=c("FILE","INPUTDIR"))
print(details[1:10,])                     # show 10 of input file name and directories
print(details[sample(nrow(details),10),]) # show a random selection of 10

required.files <- unique(file.path(details$INPUTDIR,details$FILE))
print(required.files[1:10]) 
print(sub( getRuntimeDirectory(),"",required.files )) # trim the paths

mod.pop <- openModel("VERSPM-pop")
print(mod.pop) # print three stages (scenarios)

######################################## Walkthrough 04-extract ################################################################
#   Examples of retrieving raw data from a finished model run
run_res <- mod.pop$results()

if ( is.list(run_res) ) { # TRUE if there are multiple Reportable stages
  message("All the reportable model stages:")
  print(names(run_res))
  message("Just using the last one")
  run_res <- run_res[[length(run_res)]]  # or select a different stage by name or index
  # See "model-stages.R" for how to work with a staged model (run_res list)
}

datastore.list <- results$list() # default is to show the Group/Table/Name list
print(length(datastore.list))    # number of fields in the results
print(datastore.list[sample(length(datastore.list),10)])

# here are all the fields available (see how to use it below in DisplayUnits example)
datastore.full.list <- results$list(details=TRUE)
print(names(datastore.full.list))
print(datastore.full.list[sample(nrow(datastore.full.list),10),])

results$extract()
rspm$dir(output=TRUE)    # Just shows the sub-directory names holding outputs

print(
  outputs <- rspm$dir(output=TRUE,all.files=TRUE,shorten=FALSE) # Lists all the extracted output files
  # shorten=FALSE says do not strip off model path - return absolute path
)

# Inspect one of the metadata files (metadata is very basic: just the field
# group/table/name and units (plus display units if those are different)
metadata.HH2038 <- read.csv( file=grep("2038_Household.*metadata\\.csv",outputs,value=TRUE)) # outputs should be generated with absolute paths

# See what is selected
print(results)
sl <- results$select() # Get list of all the available fields (uses results$list() database)

# show the selected fields (in short form)
print(sl)
sl$fields()[1:10]

fnd <- results$find()   # Does essentially the same thing as select, but can do more (see below)
fnd$fields()[1:10]      # Same list as above

# Get lists of groups and tables.
print( sl$groups() )    # Typically, "Global" plus one group for each model run year
print( sl$tables() )    # All the tables, along with their groups

# Just fields in the workers table, but in any available years:
# Special Group "Year" (or "Years") leaves out the "Global" group without having
# to look up the actual years that this model ran for.
wkr <- results$find(Group="Year",Table="Worker")
print(wkr)
print(wkr$fields()) # same...

# Provide a list of table names to find
# Can also do that with Group or Field
# Will get both tables in all Groups (unless you select a specific Group)
wkr.veh <- results$find(Table=c("Worker","Vehicle"))
print(wkr.veh)
rm(wkr.veh)

# Explore more selection features:
print(wkr$show()[1:10,]) # shows the detailed modelIndex for selected fields
# the table that comes out resembles results$list(), but only shows the selection

print(results) # All fields selected in results

wkr <- results$select( wkr ) # filters results on selected fields
print(results) # Just the Worker tables selected

sl <- results$select(NA) # get the results that are currently selected
print(sl)

results$select() # clear selection (selects all)
print(results)

# "all-in-one" instruction to find and select fields
wkr <- results$find(Group="Year",Table="Worker",select=TRUE)
print(results) # Just the Worker tables selected

######################################## Walkthrough 05-mini-model ################################################################
models.dir <- file.path(getwd(),"models")
mini.dir <- file.path(models.dir,"MINI")
message("Making MINI model in ",mini.dir)

mini.script <- file.path(mini.dir,visioneval::getRunParameter("ScriptsDir"))
mini.inputs <- file.path(mini.dir,visioneval::getRunParameter("InputDir"))
mini.defs   <- file.path(mini.dir,visioneval::getRunParameter("ParamDir"))
dir.create(mini.dir)            # Model directory
dir.create(mini.script)         # Scripts directory
dir.create(mini.inputs)         # Inputs directory
dir.create(mini.defs)           # Defs directory
print( dir(mini.dir,full.names=TRUE) ) # Show everything using R dir function

message("Create the model configuration / run parameters")
runConfig_ls <-  list(
  Model       = "Mini Model Test",
  Scenario    = "MiniModel",
  Description = "Minimal model constructed programmatically",
  Region      = "RVMPO",
  State       = "OR",
  BaseYear    = "2010",
  Years       = c("2010")
)
viewSetup(Param_ls=runConfig_ls)  # Helper function to display a configuration

configFile <- file.path(mini.dir,"visioneval.cnf")
cat(configFile,"\n")
yaml::write_yaml(runConfig_ls,configFile)

runModelFile <- file.path(mini.script,"run_model.R")
runModel_vc <- c(
  '', # Don't ask why (it's an R thing): without this blank line the script gets written wrong...
  'for(Year in getYears()) {',
  'runModule("CreateHouseholds","VESimHouseholds",RunFor = "AllYears",RunYear = Year)',
  'runModule("PredictWorkers","VESimHouseholds",RunFor = "AllYears",RunYear = Year)',
  '}'
)
cat(runModelFile,paste(runModel_vc,collapse="\n"),sep="\n")
writeLines(runModel_vc,con=runModelFile)

######################################## Walkthrough 06-model-stages ##############################################################

mini <- openModel("MINI")

# Add stages to the mini model
mini$modelStages # list the one stage constructed from the root folder

# Recreate the mini model with two stages, for base and future years
if ( file.exists( file.path("models","MINI-Stages") ) ) {
  unlink("models/MINI-stages",recursive=TRUE)
}
mini.1 <- mini$copy("MINI-Stages",copyResults=FALSE)

# Overall model configuration identifies the stages
modelParam_ls <- list(
  Model       = "Implicit Staged Mini Model Test",
  Region      = "RVMPO",
  State       = "OR",
  BaseYear    = "2010",
  ModelStages = list(
    "BaseYear" = list (
      Dir = "BaseYear",
      Reportable = TRUE
    ), # Dir need not match name of stage
    "FutureYear" = list(
      Dir = "FutureYear",
      Reportable = TRUE
    )
  )
)
yaml::write_yaml(modelParam_ls,file.path(mini.1$modelPath,"visioneval.cnf"))

######################################## Walkthrough 07-queries ##############################################################
# Clean up leftovers from previous walkthrough
qfiles <- grep("Full-Query",mod$query(),invert=TRUE,value=TRUE)
qfiles <- file.path(mod$modelPath,mod$setting("QueryDir"),qfiles)
unlink(qfiles)

mod$clear(force=TRUE,outputOnly=TRUE) # blow away previous extractions or queries

message("Show query directory (has Full-Query.VEqry)...")
print(mod$query())

# Show the "Reportable" stages (the ones that will be queried)
print(mod)

######################################## Walkthrough 08-scenarios ############################################################
# run example scenarios
VEscenario <- installModel("VERSPM",var="scenarios-ms")
VEscenario$run()
VEs_results <- VEscenario$results()
VEs_results$extract()

######################################## Walkthrough 09-run-parameters ########################################################

# examine model parameters
# default visioneval and VEModel parameters
# other parameters exist (e.g. a stage's RunPath) but they do not have defaults
viewSetup(Param_ls=visioneval::defaultVERunParameters())

# parameters defined in ve.runtime (initially, none)
viewSetup(fromFile=TRUE)

# parameters defined in model configuration
viewSetup(mini,fromFile=TRUE)

# all parameters
viewSetup(mini)

# parameters defined in stage configuration file
# note: there are additional parameters in the stage, even for a one-stage model
viewSetup(mini$modelStages[[1]])

# inspect parameters in configuration file versus loaded model
print(names(getSetup(mini,fromFile=TRUE))) # in the file
print(names(getSetup(mini)))               # all constructed parameters in memory

# easier to inspect constructed parameter with the model's "setting" function
mini$setting() # list the names


######################################## Walkthrough 10-debugging ########################################################
# run walkthrough steps
setwd(paste0(getwd(), "/walkthrough"))
# run 00-walkthrough.R line by line