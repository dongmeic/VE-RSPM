# Objective: Run the version 2022-05-27 with the example data
# By: Dongmei Chen (dchen@lcog.org)
# October 11th, 2022 
# Compare to T:\DCProjects\GitHub\VE-RSPM\run\exploration\run_VERSPM_CLMPO.R

# Open T:\Models\VisionEval\VE-3.0-Installer-Windows-R4.1.3_2022-05-27\VisionEval.Rproj
library(visioneval)

# reset work directory in case the default is changed
setwd("T:/Models/VisionEval/VE-3.0-Installer-Windows-R4.1.3_2022-05-27")

# run base model
rspm <- installModel("VERSPM")
rspm$run()
results <- rspm$results()
results$export()
query <- rspm$query("Full-Query")
query$run()
query$export()

# example scenarios
VEscenario <- installModel("VERSPM",var="scenarios-ms")
VEscenario$run()
VEs_results <- VEscenario$results()
VEs_results$extract()

# walk through
setwd(paste0(getwd(), "/walkthrough"))
# run 00-walkthrough.R line by line