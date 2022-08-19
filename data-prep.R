# Load packages ----
library(tidyverse)
read_plus <- function(flnm) {
        read_csv(flnm) %>% 
                mutate(filename = flnm)
}

# Data preparation (birds)----
tbl_01 <-
        list.files(
                path = "./data/acoustic-detections",
                pattern = "*.csv",
                full.names = T) %>% 
                map_df(~read_plus(.))

## clean filename column
tbl_01$filename <- gsub(".*/", "", tbl_01$filename)

## match to metadata
## list file names used and put manually into metadata file
list.files(
        path = "./data/acoustic-detections",
        pattern = "*.csv")

## left join acoustic records and metadata file
metadata <- read.csv(file = "data/site-metadata.csv")

tbl_02 <- left_join(tbl_01, metadata, by = "filename")

## filter records (common_name_tags)
tbl_03_p1 <- tbl_02 %>% select(common_name_tags, 33:42) %>%
        separate(common_name_tags, 
                 into = c("tag_number", "common_name"), 
                 sep = ":", remove = F) %>% 
        filter(common_name != "NA" & common_name != "Goat") %>% 
        select(-c(common_name_tags))


## filter records (general_tags) and attach rows to previous table
tbl_03_p2 <- tbl_02 %>% select(other_tags, 33:42) %>%
        separate(other_tags, 
                 into = c("tag_number", "other", "discard"), 
                 sep = ":", remove = F) %>% 
        filter(other != "NA" & other != "Cow" & other !="insect") %>% 
        select(-c(other_tags, discard)) %>% rename(common_name = other)

## join the common_name tags to the general tags
tbl_03 <- bind_rows(tbl_03_p1, tbl_03_p2)

### check for consistency in names and fix errors
#view(tbl_03 %>% count(common_name))

tbl_03 <- mutate(tbl_03, common_name = case_when(common_name == "Grey shike-thrush" ~ "Grey Shrike-thrush", TRUE ~ common_name))

#---- format as a species frequency table
tbl_04 <- tbl_03 %>% group_by(site_code) %>% count(common_name) %>% 
        pivot_wider(names_from = site_code, values_from = n)

#---- format as a species presence/absence matrix
tbl_04[,2:10] <- ifelse(is.na(tbl_04[,2:10]), 0, 1)

#view(tbl_04 %>% count(common_name))
### further standardise name formatting if required
### complete_df$common_name <- tolower(complete_df$common_name)
### complete_df$common_name <- str_replace(complete_df$common_name, "-", " ")
### complete_df$common_name <- str_remove(complete_df$common_name, "'")

# Data preparation (vegetation) ----

# Attach feeding guild information (necessary?) ----
# feeding <- read.csv("C:/Users/n10393021/OneDrive - Queensland University of Technology/Documents/_Soundscapes/Brendan_BowraData/birds_feedinghabits.csv") 
# feeding$Row.Labels <- tolower(feeding$Row.Labels)
# feeding$Row.Labels <- str_replace(feeding$Row.Labels, "-", " ")
# feeding$Row.Labels <- str_remove(feeding$Row.Labels, "'")
# join <- right_join(feeding, complete_df, by = c("Row.Labels" = "common_name")) %>% 
#         select(everything(), -c(X, X.1, X.2)) %>% 
#         write.csv("C:/Users/n10393021/OneDrive - Queensland University of Technology/Documents/_Soundscapes/Brendan_BowraData/final_df_feeding.csv", row.names = F)

