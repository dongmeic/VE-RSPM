#===========
# View outputs for D1B with geo and acreage
#Author: Dan Flynn (Daniel.Flynn@dot.gov)
#===========

# Assumes finished model is VERSPM_CLMPO, change as appropriate for how you named the model directory
# Assumes that VisionEval was launched in RStudio by double-clicking 'VisionEval.Rproj'. By doing this, the working directory is set to 
# the location of your VisionEval folder on your machine. 

# Setup ----
library(tidyverse) # if fails, install.packages('tidyverse')

model_dir <- 'models/VERSPM_CLMPO' # Change as appropriate

geo <- read_csv(file.path(model_dir, 'defs', 'geo.csv'))

output_to_load = 'Datastore/2010/Bzone/D1B.Rda'

if(!file.exists(file.path(model_dir, output_to_load))){
  stop('File not found. Please complete the VERSPM base run before running this script')
}

load(file.path(model_dir, output_to_load))

# Load area file
bzone_unprotected_area <- read_csv(file.path(model_dir, 'inputs', 'bzone_unprotected_area.csv'))

# Join geography with output files ----

geo <- geo %>%
  mutate(D1B = Dataset) %>%
  left_join(bzone_unprotected_area, by = c('Bzone' = 'Geo'))

# Make a label column for only the most dense Bzones
geo <- geo %>%
  mutate(D1B_rank = rank(1/D1B),
         high_density_Bzones = ifelse(D1B_rank < 10, Bzone, NA))

# Make a plot of area by density
ggplot(geo %>% filter(Year == '2010'), aes(x = UrbanArea, 
                                           y = D1B,
                                           label = high_density_Bzones)) +
  geom_point() +
  geom_text(size = 4, hjust = -0.1)

ggsave('Density_vs_Area_by_Bzone.jpeg')


# Adding examination of dwelling units ----

bzdu <- read_csv(file.path(model_dir, 'inputs', 'bzone_dwelling_units.csv'))

bzdu10 <- bzdu %>%
  filter(Year == "2010") %>%
  select(Geo, SFDU, MFDU) %>%
  rename(Bzone = Geo) %>%
  mutate(AllDU = SFDU + MFDU)

# Join with the existing geo file by Bzone

geo <- geo %>%
  left_join(bzdu10, by = 'Bzone')

# Calculate proportions
geo <- geo %>%
  mutate(DUperArea = AllDU / UrbanArea)

# Plot
ggplot(geo, aes(x = DUperArea,
                y = D1B,
                color = UrbanArea,
                label = high_density_Bzones)) +
  geom_point() +
  geom_text(size = 4, hjust = 1.1)

ggsave('Density_vs_DUperArea_by_Bzone.jpeg')

