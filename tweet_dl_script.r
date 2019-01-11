library(rtweet)
library(readr)
library(dplyr)
library(stringr)

term_list <- read_lines('resources/term_list_3')

# grab n tweets matching each of the terms in our list
n = 100
tweet_sample <- search_tweets2(q=term_list, n=n, include_rts = FALSE, lang = "en")

# make a search term column and remove duplicate texts
tweet_sample <- tweet_sample %>% 
  mutate(search_term = str_replace(rownames(tweet_sample), '\\..+',''))

write_as_csv(tweet_sample, 
             paste0('data/tweets/tweet_sample_',format(Sys.time(), "%m_%d_%Y"),'.csv'), 
             prepend_ids = FALSE)

reply_sample <- search_tweets(q='racist', n=1000, include_rts = FALSE, lang = "en")
in_reply_to <- reply_sample %>% filter(!is.na(reply_to_screen_name))
replied_to <- lookup_statuses(in_reply_to$reply_to_status_id, parse = TRUE, token = NULL) %>% 
  mutate(has_keyword = str_detect(text,regex('black|nigger|african', ignore_case = T)))
write_as_csv(replied_to, 
             paste0('data/tweets/reply_sample_',format(Sys.time(), "%d_%m_%Y"),'.csv'), 
             prepend_ids = FALSE)
