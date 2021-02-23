# Objective: generate graphs for the ETSP memo
# By: Dongmei Chen (dchen@lcog.org)
# November 23rd, 2020
# Reference: RSPM_for_ETSP.R

# load libraries
library(ggplot2)

path <- "C:/Users/DChen/OneDrive - lanecouncilofgovernments/VE-RSPM/memo/output/"
#scenarios <- c("Reference", "Scenario1", "Scenario2")
scenarios <- c('B1C1D1E1F1G1I1P1T1V1', 
               'B2C2D2E2F2G2I2P2T2V2', 
               'B2C3D3E3F3G3I3P3T3V2')

# combine tables
for(s in scenarios) {
  if(s == "Reference" | s == scenarios[1]){
    data <- read.csv(paste0(path, s, ".csv"), stringsAsFactors = FALSE)
    colnames(data)[dim(data)[2]] <- s
  }else{
    df <- read.csv(paste0(path, s, ".csv"), stringsAsFactors = FALSE)
    df <- df[dim(df)[2]]
    colnames(df) <- s
    data <- cbind(data, df)
  }
}

head(data)
#data$Measure

# select variables
get.var.df <- function(key="CO2e", keynm="GHG emissions"){
  if(key %in% c("CO2e", "GGE")){
    vars <- grep("Ldv|HvyTrk", grep(key, data$Measure, value = TRUE), value = TRUE)
    vars <- vars[!grepl("Rate", vars)]
  }else{
    vars <- grep(key, data$Measure, value = TRUE)
  }

  df <- data[data$Measure %in% vars,]
  outdf <- df[,4:7]
  out <- colSums(outdf)
  out <- sapply(out, function(x) (x-out[1])/out[1])
  
  outdata <- data.frame(out[2:4])
  colnames(outdata) <- "Value"
  rownames(outdata) <- NULL
  outdata$Variable <- keynm
  outdata$Scenario <- c("2040 Adopted Plans", "2040 What If #1", "2040 What If #2")
  return(outdata)
}

dat <- rbind(get.var.df(), get.var.df(key="GGE", keynm="Fuel consumption"),
             get.var.df(key="AveHhDVMT", keynm="DVMT"),
             get.var.df(key="WalkTrips", keynm="Walk trips"),
             get.var.df(key="VehCostPM", keynm="Vehicle cost per mile"))

#get.var.df(key="OwnershipCost", keynm="AVG household vehicle ownership cost")

# bar chart
plot_base <- ggplot(data = dat, mapping = aes(x=Variable, y=Value, fill=Scenario))
plot_base_clean <- plot_base + 
  # apply basic black and white theme - this theme removes the background colour by default
  theme_bw() + 
  # remove gridlines. panel.grid.major is for vertical lines, panel.grid.minor is for horizontal lines
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        # remove borders
        panel.border = element_blank(),
        # removing borders also removes x and y axes. Add them back
        axis.line = element_line())


p <- plot_base_clean +
  # bar graph
  geom_bar(stat="identity", position=position_dodge(), colour="black", aes(alpha = Scenario))+
  # color settings
  scale_fill_brewer(palette="Dark2")+
  scale_alpha_manual(values = c(0.6,0.8,1))+
  # change y from decimal to percentage
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))+
  # add labels
  geom_text(aes(label = paste0(round(Value * 100, 1), "%"),
                vjust=ifelse(sign(Value)>0, -1, 1.5)), size = 3,
            position = position_dodge(width=1), show.legend = FALSE)+
  # edit x and y labels
  labs(x=NULL, y="Percent change from 2010 to 2040")

ppi <- 300
png(paste0(path, "change_sensitivity.png"), width=9*ppi, height=6*ppi, res=ppi)
#par(mar=c(2,0,2,1))
print(p)
dev.off()

