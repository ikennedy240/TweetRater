library(httr)
library(readr)

setwd("/Users/ikennedy/Work/UW/Code/GIT/TweetRater")
# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data, mode = 'normal') {
  if(mode == 'forced_exit'){
    cat('forced exit, logging incomplete data')
    fileName <- sprintf("incomplete_%s_%s.csv",
                        humanTime(),
                        digest::digest(data))
  } else {
    fileName <- sprintf("%s_%s.csv",
                        humanTime(),
                        digest::digest(data))
  }
  write.csv(x = data, file = file.path(responsesDir, fileName),
            row.names = FALSE, quote = TRUE)

  tweet_df <- tweet_df %>% full_join(read.csv(file.path(responsesDir, fileName), row.names=NULL, colClasses = 'character') %>% select(status_id, rating), by = 'status_id')  %>% 
    mutate(rating_1 = if_else(n_ratings=='0', rating, rating_1),
           rating_2 = if_else(n_ratings=='1', rating, rating_2),
           rating_3 = if_else(n_ratings=='2', rating, rating_3),
           extra_rating_1 = if_else(as.numeric(n_ratings)==3, rating, extra_rating_1),
           extra_rating_2 = if_else(as.numeric(n_ratings)==4, rating, extra_rating_2),
           n_ratings = if_else(is.na(rating), n_ratings, as.character(as.numeric(n_ratings)+1)),
           n_ratings = if_else(n_ratings>=3&sign(as.numeric(rating_1))==sign(as.numeric(rating_2))&sign(as.numeric(rating_2))==sign(as.numeric(rating_3)), 
                               '10', n_ratings),
           status = if_else(as.numeric(n_ratings) >= 5, 'complete', status)) %>%
    select(-rating)

  full_df %>%
    filter(!(status_id %in% tweet_df$status_id)) %>%
    bind_rows(tweet_df) %>%
    inner_join(read.csv(tweet_dir, row.names=NULL, colClasses = 'character') %>%
                 transmute(alt_status = status, status_id), by = 'status_id') %>%
    mutate(status = case_when(as.character(n_ratings) >= 5 ~ 'complete',
                              status == 'complete' | alt_status == 'compelte' ~ 'complete',
                              status == 'active' ~ 'waiting',
                              status == 'in progress' & alt_status == 'waiting' ~ 'waiting',
    status == 'waiting' & alt_status == 'in progress' ~ 'in progress',
    status == alt_status ~ status
    )) %>%
    select(-alt_status) %>%
    write.csv(file = file.path(tweet_dir), row.names = FALSE, quote = TRUE)
}

epochTime <- function() {
  as.integer(Sys.time())
}

grab_html <- function(round){
  tweet_info = GET(paste0("https://publish.twitter.com/oembed?url=",tweet_df$status_url[round],
                          "?omit_script=TRUE?hide_media=TRUE?hide_thread=TRUE"))
  tweet_html = content(tweet_info, "parsed")$html
  return(tweet_html)
}


append_feedback <- function(feedback){
  fbfile <- 'responses/feedback.csv'
  
  if(file.exists(fbfile)){
    write.table(x = feedback, file = fbfile, sep = ',', append = TRUE, row.names = FALSE, col.names = FALSE)
  }
  else{
    write.table(x = feedback, file = fbfile, sep = ',', row.names = FALSE)
  }
}

# give user a random string
set_user <- function(){
  user <- digest::digest(humanTime()) # gives the user a hash based on the date and time
  if(file.exists('users.txt')){
    if(user %in% read_lines('users.txt')){
      return(digest::digest(runif(4)))
    }
  }
  write_lines(user, 'users.txt', append = TRUE)
  return(user)
}

### AUTO SET VALUES
fieldsAll <- c('race_ethnicity', 'nationality', 'gender', 'age', "comment", "valence", "rating", "topic", "example", "notes")
fieldsFeedback <- c("difficult_part","discomfort_yes", "discomfort_no","general_feeling")
# set directory to store responses
responsesDir <- file.path("responses")
db_dir <- file.path("db")
# from local file
tweet_dir <- file.path("fake_tweet.csv") 
completion_code <- digest::digest(tweet_dir)
full_df = read.csv(tweet_dir, row.names=NULL, colClasses = 'character')
# preps raw tweets
if(!('status' %in% names(full_df))){
  tweet_df %>%
    select(user_id, status_id, screen_name, text, starts_with('reply'), is_quote, is_retweet, contains('count'), urls_expanded_url, media_expanded_url, ext_media_expanded_url, status_url, name, location, description, url, protected, account_created_at, contains('profile'), has_keyword, query) %>%
    mutate(n_ratings = 0, status = 'waiting', rating_average = NA, rating_1 = NA, rating_2 = NA, rating_3 = NA, extra_rating_1 = NA, extra_rating_2 = NA) %>% write_csv('fake_tweet.csv')
}
tweet_df <- full_df %>%
  filter(status == 'waiting') %>% 
  arrange(desc(n_ratings)) %>% 
  head(min(100, nrow(full_df %>% filter(status == 'waiting')))) %>% 
  sample_n(min(20, nrow(full_df %>% filter(status == 'waiting')))) %>% 
  mutate(status = 'active')

full_df %>% 
  mutate(status = if_else(status_id %in% tweet_df$status_id, 'in progress', status)) %>% 
  write.csv(file = file.path(tweet_dir),
                                                                                                            row.names = FALSE, quote = TRUE)

likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)
#user <- set_user()


# CSS to use in the app
appCSS <- ".mandatory_star { color: red; }
.shiny-input-container { margin-top: 25px; }
.shiny-progress .progress-text {
font-size: 18px;
top: 50% !important;
left: 50% !important;
margin-top: -100px !important;
margin-left: -250px !important;
}"
 


