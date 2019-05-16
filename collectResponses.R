library(httr)
library(rdrop2)
library(tidyverse)

# set vars
drop_auth(rdstoken = 'resources/droptoken.rds')

db_dir <-  file.path('tweetratings','turker_ratings','responses')
local_dir <- file.path("turker_responses", "raw_responses")
full_ratings_file <- file.path("turker_responses","full_ratings_set.csv")

# Check downloaded files agianst files in dropbox 
new_files <- setdiff(drop_dir(db_dir)$name, list.files(local_dir))

# always download the updated feedback data
if(!"feedback.csv" %in% new_files) new_files <- c(new_files, "feedback.csv")

# Download new files to turker_responses/raw_responses
walk(file.path(db_dir, new_files), drop_download, local_path = local_dir, overwrite = TRUE)

# load exisiting collections of ratings
if(file.exists(full_ratings_file)) full_ratings_set <- read_csv("turker_responses/full_ratings_set.csv", col_types = cols(.default = 'c')) else full_ratings_set <- NULL

# collate new ratings, excluding incompletes, feedback by selecting filenames that begin with numbers
ratings_to_include <- str_subset(new_files, '^\\d')

# bind new ratings, confirm that there are no dupes
full_ratings_set <- bind_rows(full_ratings_set, map_dfr(file.path(local_dir, ratings_to_include), read_csv, col_types = cols(.default = 'c')))

# save new complete set
write_csv(full_ratings_set, full_ratings_file)
