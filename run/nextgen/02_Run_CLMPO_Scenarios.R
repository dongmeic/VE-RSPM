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

scenarios.cat <- openModel("VERSPM-scenarios-cat")
dirfiles <- scenarios.cat$dir(scenarios=TRUE,all.files=TRUE)
# check the existing category names
catnm <- unique(unlist(lapply(dirfiles[2:25], function(x) str_split(x, "/")[[1]][1])))
# check the clmpo category names
infolder <- "T:/DCProjects/Modeling/VE-RSPM/Notes/Scenarios"
infile <- read_excel(file.path(infolder, "sensitivity_test_inputs.xlsx"), sheet = "clmpo")
catnm_cl <- unique(infile$category_name)
