# Explanations

Adjustments on some input files are made to run through the model.

## Recalculate carbon intensity

The utility shapefile is provided by ODOT and the green house emissions data is provided by Ellen.

The pop-weighting is calculated by the percentages of areas for each of utility names (EWEB, Springfield Utility Board, Emerald PUD, Lane Elec) in each of the three cities (Eugene, Springfield, and Coburg). This step is processed using both ArcMap and R to compare the results.

The carbon intensity is calculated using the approach explained in *VE_State_InputsTo_MPO_20200518.pdf* and using the script *carbon_intensity.R*.

### Recalculate unprotected area
The unbuildable proportion data is from *T:\Trans Projects\Model Development\UrbanSim_LandUse\Working2020-2045\DataPrep\Parcels\parcels.shp*. The unprotected area is calculated as '(100 - Proportion)/100 * ShapeArea' in parcels and summarized by bzone using the [Summary Within](https://pro.arcgis.com/en/pro-app/tool-reference/analysis/summarize-within.htm) function in ArcGIS Pro. The calculated data is organized in the new input CSV file using the script *population_density.R*.

## Debug population density
The population density by BZone is warned too high in some tracts. To examine the input values, several steps are followed. The BZone boundary is *T:\Trans Projects\Model Development\UrbanSim_LandUse\Inputs\VisionEval\CLTracts_GsBoundary.shp*. The BZone population density is defined as "gross population density (people/acre) on unprotected (i.e. developable) land in bzone" ([D1B](https://github.com/VisionEval/VisionEval/blob/master/sources/modules/VELandUse/R/Calculate4DMeasures.R)). The developable land in 2040 remains the same as the 2010 data. The population is generated from the "[PredictHousing](https://github.com/VisionEval/VisionEval-Docs/blob/main/tutorials/verspm/Modules_and_Outputs.md#predicthousing)" from the dwelling units data ([*bzone_dwelling_units.csv*](https://github.com/VisionEval/VisionEval-Docs/blob/main/tutorials/verspm/Modules_and_Outputs.md#user-input-files-4)). For this issue, check the notes ('bzone_unprotected_area.md' and 'bzone_dwelling_units.md') for the original ideas in the folder -T:\Models\VisionEval\VERSPM_User_Files_Copies\VERSPM_CLMPO_SA_Reference_2020_03_09\inputs. The GQDU is suggested to include only non-institutional use data (e.g., dorms and military bases) (see "RE Population density validation.msg" in T:\DCProjects\Modeling\VE-RSPM\Notes\Emails). However, the census tract that is extremely high in population density contains only non-institutional group quarters. The percentage of non-institutional group quarter population was calculated but not applied in the recalculation, since it didn't help resolve the high density issue and the existing data is rough estimation. 
