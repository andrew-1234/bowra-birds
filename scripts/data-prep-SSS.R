# Small spatial scale (SSS) data ----

# read and prepare data for GDM

## read in bird IDs ----

sss_birds <- read.csv(file = "./data/data-SSS/data-bowra-SSS-birdID.csv")

# data is in format of site by species (sites are rows, species are columns; bioformat 1 in gdm package)

# drop the "point" column, and veg_desc; Point with capital will be used to match with sss_env column
sss_birds <- sss_birds %>% 
        dplyr::select(c(-point, 
                        -veg_description2))

## read in recorder sites metadata (vegetation etc) ----

sss_env <- read.csv(file = "./data/data-SSS/data-bowra-SSS-sites-3577.csv")

# sss_env is in format of site by environment table (sites are rows, predictors are columns)

# select desired predictors

# str(sss_env)
sss_env <- sss_env %>% 
        dplyr::select(c(Point, 
                        CanopyCover:SubcanopyHeight, 
                        DistWater, 
                        X, 
                        Y))

# prepare site-pair table----

library(gdm)

# get site pair table----

gdm_tab_SSS <- formatsitepair(bioData=sss_birds, 
                         bioFormat=1, #site-species table
                         XColumn="X", 
                         YColumn="Y",
                         siteColumn="Point", 
                         predData=sss_env, 
                         verbose = TRUE)

# add X Y data to site-species table to work with raster input as predictor

# subset 
sss_env_merging <- sss_env %>% 
        dplyr::select(c(Point, X, Y))

sss_birds_sat <- sss_birds %>% dplyr::left_join(sss_env_merging, by = "Point")
str(sss_birds_sat)
