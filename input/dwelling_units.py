# Get MTAZ-to-B-zone cross-reference values from developed `MTAZ16_with_Zones` feature class in `Geo.gdb`. 
# Place these in the proper rows in the CSV, to get each row an associated B-zone
import arcpy

mtaz_path = (
    "\\\\cltmod01.int.lcog.org\\Models\\GHG_Planning\\VisionEval\\Data_Work"
    "\\Geo.gdb\\MTAZ16_with_Zones"
)
cursor = arcpy.da.SearchCursor(mtaz_path, field_names=["taz_num", "b_zone"])py
taz_b_zones = sorted(cursor)
for taz_num, b_zone in taz_b_zones:
    print("{}\t{}".format(taz_num, b_zone))

# Aggregate the MTAZ dwelling unit counts to the B-zone level. Output of this is in model input format
from collections import defaultdict
import csv
import os

import arcpy

WORK_PATH = "\\\\cltmod01\\Models\\GHG_Planning\\VisionEval\\Data_Work"
MTAZ16_PATH = os.path.join(WORK_PATH, "Geo.gdb\\MTAZ16_with_Zones")
TAZ_COUNTS_PATH = os.path.join(
    WORK_PATH, "Dwelling_Units\\mtaz16_dwelling_unit_counts_by_type.csv"
)

cursor = arcpy.da.SearchCursor(
    in_table=MTAZ16_PATH, field_names=["taz_num", "b_zone"]
)
mtaz_b_zone = {taz_num: b_zone for taz_num, b_zone in cursor}
b_zone_year_counts = {
    (b_zone, year): defaultdict(float)
    for b_zone in mtaz_b_zone.values()
    for year in [2009, 2011, 2035]
}
with open(TAZ_COUNTS_PATH, "r") as csv_file:
    reader = csv.DictReader(csv_file)
    for taz in reader:
        b_zone_year = mtaz_b_zone[int(taz["taz_num"])], int(taz["year"])
        for unit_type in ["SFDU", "MFDU", "GQDU"]:
            if unit_type == "GQDU":
                b_zone_year_counts[b_zone_year][unit_type] = "unk"
                continue

            b_zone_year_counts[b_zone_year][unit_type] += round(
                float(taz[unit_type]), 2
            )
print("Geo,Year,SFDU,MFDU,GQDU")
for b_zone_year, counts in sorted(b_zone_year_counts.items()):
    print("{},{},{SFDU},{MFDU},{GQDU}".format(*b_zone_year, **counts))

# Derive estimates of 2005, 2010, & 2040 from the 2009/2011/2035 collection in the model input CSV
from collections import defaultdict
import csv
import os

MODEL_PATH = "\\\\cltmod01.int.lcog.org\\Models\\GHG_Planning\\VisionEval"
INPUTS_PATH = os.path.join(MODEL_PATH, "Model\\models\\VERSPM\\CLMPO_Base\\inputs")
B_ZONE_DWELLING_UNITS_PATH = os.path.join(INPUTS_PATH, "bzone_dwelling_units.csv")

def dwelling_units(year, ref_year_0, ref_year_1):
    """Get B-zone dwelling unit type counts."""
    du_keys = ["SFDU", "MFDU", "GQDU"]
    # Ex. {"D41039000100": {2035: {"SFDU": 16, "MFDU": 8, "GQDU": 2}}}
    b_zone_year_dus = defaultdict(dict)
    with open(B_ZONE_DWELLING_UNITS_PATH, "r") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            b_zone_year_dus[row["Geo"]][int(row["Year"])] = {
                key: row[key] for key in du_keys
            }
    b_zone_dus = defaultdict(dict)
    for b_zone, year_dus in b_zone_year_dus.items():
        for key in du_keys:
            if key == "GQDU":
                b_zone_dus[b_zone][key] = "unk"
                continue

            val0 = float(year_dus[ref_year_0][key])
            val1 = float(year_dus[ref_year_1][key])
            rate_span = ref_year_1 - ref_year_0
            if year < ref_year_1:
                estimate_span = year - ref_year_0
                base_val = val0
            else:
                estimate_span = year - ref_year_1
                base_val = val1
            if val0 == 0.0:
                if val1 == 0.0:
                    annual_rate = 0.0
                else:
                    annual_rate = val1 / rate_span
            else:
                annual_rate = (val1 - val0) / rate_span
            b_zone_dus[b_zone][key] = round(base_val + annual_rate * estimate_span, 2)
            if b_zone_dus[b_zone][key] < 0.0:
                b_zone_dus[b_zone][key] = 0.0
    print("Geo,Year,SFDU,MFDU,GQDU")
    for b_zone, count in sorted(b_zone_dus.items()):
        print("{},{},{SFDU},{MFDU},{GQDU}".format(b_zone, year, **count))

if __name__ == "__main__":
    dwelling_units(year=2005, ref_year_0=2009, ref_year_1=2011)
    print("\n\n")
    dwelling_units(year=2010, ref_year_0=2009, ref_year_1=2011)
    print("\n\n")
    dwelling_units(year=2040, ref_year_0=2011, ref_year_1=2035)

    