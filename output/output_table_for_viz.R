# Objective: Organize scenario output data for Tableau viz
# Source: run_example_scenarios.R
# By: Dongmei Chen (dchen@lcog.org)
# September 29th, 2020

# path
outpath <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/"
outfile <- paste0(outpath, "Measures_Sensitivity_Output_2020-09-27_19_43_36.csv")
listscen <- paste0(outpath, "sensitivity_tests/scenario_list.csv")

# data
scen.list <- read.csv(listscen, stringsAsFactors = FALSE)
measures <- read.csv(outfile, stringsAsFactors = FALSE)

meas.t <- data.frame(t(measures[,which(colnames(measures) %in% scen.list$S)]))
colnames(meas.t) <- measures$Measure
sum(rownames(meas.t) == scen.list$S)
scen.df <- cbind(scen.list, meas.t)
write.csv(scen.df, paste0(outpath, "sensitivity_tests/scenarios_output.csv"), 
          row.names = FALSE)