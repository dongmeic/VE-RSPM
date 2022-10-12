# Objective: Run the version 2022-05-27
# By: Dongmei Chen (dchen@lcog.org)
# October 11th, 2022 
# Compare to T:\DCProjects\GitHub\VE-RSPM\run\exploration\run_VERSPM_CLMPO.R

# Open T:\Models\VisionEval\VE-3.0-Installer-Windows-R4.1.3_2022-05-27\VisionEval.Rproj
library(visioneval)
rspm <- installModel("VERSPM")
rspm$run()
results <- rspm$results()
results$export()
query <- rspm$query("Full-Query")
query$run()
query$export()
