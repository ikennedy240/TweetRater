# This script should deploy a shiny app with a new set of tweets and an attention check
library(tidyverse)
library(rsconnect)
# set vars

# number of tweets
n <-  30

# deployment name
deploy_name <- 'turker_rating_round'


## make tweet sample

# load sample
full_sample <- read_csv('resources/rater_resources/new_sample.csv', col_types = cols(.default = 'c'))
# load already rated tweets
rated <- read_csv('resources/rater_resources/rated_tweets.csv', col_types = cols(.default = 'c')) %>% mutate(rating_round = as.integer(rating_round))
# anti-join 
need_rating <- anti_join(full_sample, rated, by = c('user_id', 'status_id')) 

# select sample of size n
if(nrow(need_rating)>n) sample <- need_rating %>% sample_n(n) else stop("Not enough unrated tweets")

# add sample to rated
new_rated <- bind_rows(rated, sample %>% mutate(rating_round = max(rated$rating_round)+1))
# add attention check, randomize
att_check <- read_csv('resources/rater_resources/att_check.csv', col_types = cols(.default = 'c'))
sample <- bind_rows(sample, att_check) %>% sample_frac(1)

# write sample to file
write_csv(sample, '/Users/ikennedy/Work/UW/Code/GIT/TweetRater/Db/turker_tweets.csv')

if(readline(paste0("Deploy rater ",deploy_name,'_', max(new_rated$rating_round), "? (y/n)"))=='y'){
# deploy app
  deployApp(appDir = "/Users/ikennedy/Work/UW/Code/GIT/TweetRater/Db", 
            appFiles = c("helpers_db.R", "resources", "responses", "server.R", 'ui.r', 'turker_tweets.csv'), appFileManifest = NULL,
            appName = paste0(deploy_name,'_4'),# max(new_rated$rating_round)),
            upload = TRUE,
            launch.browser = FALSE,
            logLevel = "normal",
            forceUpdate = FALSE)
}
# write rated to csv
write_csv(new_rated, 'resources/rater_resources/rated_tweets.csv')
