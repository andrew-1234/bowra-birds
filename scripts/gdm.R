# Compute a GDM using tbl_03 (generated in ./scripts/data-prep.R)----

# tbl_03 is an x-y species list (bioFormat = 2 in the GDM package) where there is one row per species record rather than per site

# check structure of the table

str(tbl_03)

# drop unnecessary columns (fid, lat, lon)----
# drop shrub cover column due to a missing data point 

tbl_05 <- tbl_03 %>%
        select(-c(fid, lat, lon, area, HubName, shrub_cove))
sppTab_Bowra <- tbl_05[, c("common_name", "point_name", "X", "Y")]
envTab_Bowra <- tbl_05[, c(3:ncol(tbl_05))]
envTab_Bowra <- envTab_Bowra %>% select(-c(treatment, site_code))



# get site pair table----
gdmTab <- formatsitepair(bioData=sppTab_Bowra, 
                         bioFormat=2, #x-y spp list
                         XColumn="X", 
                         YColumn="Y",
                         sppColumn="common_name", 
                         siteColumn="point_name", 
                         predData=envTab_Bowra, verbose = TRUE)

