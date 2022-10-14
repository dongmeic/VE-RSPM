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

installModel("VERSPM",var="") # this will list all the available models
dir("models") # check what is installed

rspm <- openModel("VERSPM-base") # this will open an installed model in the "models" folder or the parent folder the same with the Rproj

# > names(rspm)
# [1] ".__enclos_env__" "settings"        "Workers"         "FuturePlan"      "overallStatus"   "specSummary"     "loadedParam_ls"  "RunParam_ls"    
# [9] "modelResults"    "modelScenarios"  "modelStages"     "modelPath"       "modelName"       "clone"           "query"           "findstages"     
# [17] "results"         "archive"         "copy"            "setting"         "log"             "clear"           "dir"             "list"           
# [25] "scenarios"       "updateStatus"    "printStatus"     "stageStatus"     "print"           "run"             "plan"            "load"           
# [33] "valid"           "addstage"        "initstages"      "configure"       "initialize"     

rspm$run()
results <- rspm$results()
results$export()
query <- rspm$query("Full-Query")
query$run()
query$export()

# run example scenarios
VEscenario <- installModel("VERSPM",var="scenarios-ms")
VEscenario$run()
VEs_results <- VEscenario$results()
VEs_results$extract()

# run walkthrough steps
setwd(paste0(getwd(), "/walkthrough"))
# run 00-walkthrough.R line by line