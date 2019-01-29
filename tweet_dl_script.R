#!/usr/bin/env Rscript

library(rtweet)
library(readr)
library(dplyr)
library(stringr)

setwd('/Users/ikennedy/work/UW/code/GIT/TweetRater')

term_list <- read_lines('resources/term_list_3')

# grab n tweets matching each of the terms in our list
n = 300
tweet_sample <- search_tweets2(q=term_list, n=n, include_rts = FALSE, lang = "en")

# make a search term column and remove duplicate texts
tweet_sample <- tweet_sample %>% 
  mutate(has_keyword = TRUE, status_id = as.character(status_id),
         user_id = as.character(user_id))

write_as_csv(tweet_sample, 
             paste0('data/tweets/tweet_sample_',format(Sys.time(), "%m_%d_%Y"),'.csv'), 
             prepend_ids = FALSE)

reply_sample <- search_tweets(q='racist', n=5000, include_rts = FALSE, lang = "en")
in_reply_to <- reply_sample %>% filter(!is.na(reply_to_screen_name))
replied_to <- lookup_statuses(in_reply_to$reply_to_status_id, parse = TRUE, token = NULL) %>% 
  mutate(has_keyword = str_detect(text,regex('black|nigger|african', ignore_case = T)), 
         query = 'reply',
         status_id = as.character(status_id),
         user_id = as.character(user_id))

write_as_csv(replied_to, 
             paste0('data/tweets/reply_sample_',format(Sys.time(), "%d_%m_%Y"),'.csv'), 
             prepend_ids = FALSE)

col_types = cols(status_id = col_character(), user_id = col_character(), has_keyword = col_logical())
# re-read the written csvs (for flattening reasons) and then bind them together
todays_tweets <- bind_rows(
  read_csv(paste0('data/tweets/reply_sample_',format(Sys.time(), "%d_%m_%Y"),'.csv'), col_types = col_types),
  read_csv(paste0('data/tweets/tweet_sample_',format(Sys.time(), "%m_%d_%Y"),'.csv'), col_types = col_types),
  read_csv('data/tweets/full_tweet_sample.csv', col_types = col_types)
) %>% distinct(status_id, .keep_all = TRUE)

# add today's sample to the full sample
write_csv(todays_tweets, 'data/tweets/full_tweet_sample.csv')


