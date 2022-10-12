# Objective: Organize output files to compare the measurements
# By: Dongmei Chen (dchen@lcog.org)
# September 15th, 2020

# compare between the two VE versions
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/output/"
infile.pre <- "metro_measures_AllYears.csv"
infile.cur <- "Measures_CLMPO-test_2010,2040_Marea=CLMPO.csv"

output.pre <- read.csv(paste0(infolder, infile.pre), stringsAsFactors = FALSE)
length(output.pre$Measure)
output.cur <- read.csv(paste0(infolder, infile.cur), stringsAsFactors = FALSE)
length(output.cur$Measure)

output.pre <- output.pre[output.pre$Measure %in% output.cur$Measure,]
write.csv(output.pre, paste0(infolder, 'metro_measures_AllYears_copy.csv'), row.names = FALSE)
length(output.pre$Measure)
output.cur <- output.cur[output.cur$Measure %in% output.pre$Measure,]
length(output.cur$Measure)

output.cur <- output.cur[order(match(output.cur$Measure, output.pre$Measure)),]
write.csv(output.cur, paste0(infolder, 'Measures_CLMPO-test_output.csv'), row.names = FALSE)

# compare among the sensitivity tests
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/sensitivity_tests/" 
scenarios <- read.csv(paste0(infolder, "scenario_list.csv"), stringsAsFactors = FALSE)
tests <- scenarios$S[1:5]

# read the output files and combine all together
path <- "C:/Users/DChen/all/VE-RSPM/VisionEval/models/"
for(test in tests){
  files <- list.files(path = paste0(path, test), pattern = "(.*)csv$")
  outfile <- grep(files, pattern = test, value = TRUE)
  out <- read.csv(paste0(path, test, '/', outfile), stringsAsFactors = FALSE)
  if(test == tests[1]){
    output <- out
    if('X2010' %in% names(output)){
      names(output)[which(names(output) %in% c('X2010', 'X2040'))] <- c('Value2010', test)
    }else{
      names(output)[dim(output)[2]] <- test
    }
    
  }else{
    output <- cbind(output, out[,'X2040'])
    names(output)[dim(output)[2]] <- test
  }
  cat(paste('Added measures from scenario', test, '...\n'))
}
infolder <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/output/"
write.csv(output, paste0(infolder, 'Measures_Sensitivity_Output_2.csv'), row.names = FALSE)
