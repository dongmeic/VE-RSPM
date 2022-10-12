# Objective: compare the results from running the reference, STSRec and TR scenarios
# By: Dongmei Chen (dchen@lcog.org)
# November 10th, 2020

library(ggplot2)
library(dplyr)

infolder <- "E:/VisionEval/models/CLMPO/outputs/"
scen <- 'Ref'

read.outdata <- function(scen){
  file.path <- paste0(infolder, scen)
  file <- list.files(path = file.path, pattern = 'Measures_CLMPO_2010,2040_Marea=CLMPO', all.files = TRUE,
                     full.names = TRUE)
  data <- read.csv(file, stringsAsFactors = FALSE)
  #colnames(data)[which(colnames(data)=='X2040')] <- scen
  data$Scenario <- rep(scen, dim(data)[1])
  return(data)
}

ref_out <- read.outdata('Ref')
STSRec_out <- read.outdata('STSRec')
TR_out <- read.outdata('TR')

data <- rbind(ref_out, STSRec_out, TR_out)
head(data)
data$No <- rep(1:dim(ref_out)[1], 3)

ggplot(data, aes(No, X2040, colour=Scenario)) + geom_point() + 
  labs(title = 'RSPM Scenario Output Comparison', 
       x='Measure ID', 
       y='Measure value')

# check the top values
unique(data[data$X2040 > 7500000000, c('Measure', 'Units', 'Description')])
# Measure        Units                                                     Description
# 85              UrbanTotalHhIncome USD per year                     Total annual household income in urban area
# 86 UrbanTotalHhIncomeLowInc.100000 USD per year  Total annual low household income (0to20K 2010$) in urban area


