# Objective: Organize scenario output data for Tableau viz
# Source: run_example_scenarios.R
# By: Dongmei Chen (dchen@lcog.org)
# September 29th, 2020

library(readxl)
library(stringr)
# path
path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/"
# modify the output file name
outfile <- paste0(path, "Measures_Sensitivity_Output_2020-11-19_06_31_48.csv")
listscen <- paste0(path, "sensitivity_tests/scenario_list.csv")
catscen <- paste0(path, "sensitivity_tests/scenario_list_with_categories.csv")

# output data
scen.list <- read.csv(listscen, stringsAsFactors = FALSE)
catscen <- read.csv(catscen, stringsAsFactors = FALSE)
measures <- read.csv(outfile, stringsAsFactors = FALSE)

meas.t <- data.frame(t(measures[,which(colnames(measures) %in% scen.list$S)]))
colnames(meas.t) <- measures$Measure
sum(rownames(meas.t) == scen.list$S)
scen.df <- cbind(scen.list, meas.t)
write.csv(scen.df, paste0(path, "sensitivity_tests/scenarios_output.csv"), 
          row.names = FALSE)

# input data
0.5