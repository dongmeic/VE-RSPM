# Objective: Organize scenario output data for Tableau viz
# Source: run_example_scenarios.R
# By: Dongmei Chen (dchen@lcog.org)
# September 29th, 2020

library(readxl)
library(stringr)
# path
path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/"
outfile <- paste0(path, "Measures_Sensitivity_Output_2020-10-25_12_12_44.csv")
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
input_file <- paste0(path, "sensitivity_tests/sensitivity_test_inputs.xlsx")
scen.test.inputs <- read_excel(input_file, sheet = "clmpo")
fields <- unique(scen.test.inputs$variable)

get.input.value.by.strategy <- function(C=0, M=1, P=1, V=0, F=1, I=1, df=scen.test.inputs, 
                               variable='PropSovDvmtDiverted'){
  df.s = rbind(df[df$strategy_name == 'C' & df$strategy_level == C,],
               df[df$strategy_name == 'M' & df$strategy_level == M,],
               df[df$strategy_name == 'P' & df$strategy_level == P,],
               df[df$strategy_name == 'V' & df$strategy_level == V,],
               df[df$strategy_name == 'F' & df$strategy_level == F,],
               df[df$strategy_name == 'I' & df$strategy_level == I,])
  if(variable %in% df.s$variable){
    if(sum(df.s$variable==variable)==3){
      return(paste(df.s[df.s$variable==variable,]$value, "in", 
                   df.s[df.s$variable==variable,]$city, collapse=", "))
    }else{
      return(df.s[df.s$variable==variable,]$value)
    }
  }else{
    df.s = rbind(df[df$strategy_name == 'C' & df$strategy_level == 0,],
                 df[df$strategy_name == 'M' & df$strategy_level == 1,],
                 df[df$strategy_name == 'P' & df$strategy_level == 1,],
                 df[df$strategy_name == 'V' & df$strategy_level == 0,],
                 df[df$strategy_name == 'F' & df$strategy_level == 1,],
                 df[df$strategy_name == 'I' & df$strategy_level == 1,])
    return(df.s[df.s$variable==variable,]$value)
  }
}

# test
get.input.value.by.strategy()

input.df <- scen.list
for(field in fields){
  v <- vector()
  for(i in 1:dim(scen.list)[1]){
    v[i] <- get.input.value.by.strategy(C=scen.list[i,"C"], M=scen.list[i,"M"], P=scen.list[i,"P"], 
                                        V=scen.list[i,"V"], F=scen.list[i,"F"], I=scen.list[i,"I"], 
                                        variable=field)
  }
  input.df[,field] <- v
  cat(paste('Got', field, '\n'))
}
write.csv(input.df, paste0(path, "sensitivity_tests/scenariou_inputs.csv"), row.names = FALSE)
