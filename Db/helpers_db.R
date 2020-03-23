library(httr)
library(rdrop2)
library(readr)
library(dplyr)
cat("loaded packages")


drop_auth(rdstoken = 'resources/droptoken.rds')

# image set up
b64 <- base64enc::dataURI(file="resources/tweet-example.png", mime="image/png")

# Helper functions
# human readable time
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

# time as a number for hasing
epochTime <- function() {
  as.integer(Sys.time())
}
#save main data
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
  write.csv(x = data, file = file.path(responsesDir,fileName),
            row.names = FALSE, quote = c(1:13))
  drop_upload(file = file.path(responsesDir,fileName), 
              path = file.path(db_dir,responsesDir))
  tweet_df <- tweet_df %>% full_join(read.csv(file.path(responsesDir,fileName), row.names=NULL, colClasses = 'character') %>% select(status_id, rating), by = 'status_id')  %>% 
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
  drop_upload(file = file.path(tweet_dir), 
              path = file.path(db_dir))
}

check_data <- function(data){
  write.csv(x = data, file = "hacky.csv",
            row.names = FALSE, quote = c(1:13))
  data <- read_csv("hacky.csv")
  return(sum(is.na(data$topic))/nrow(data)>.5)
}

append_feedback <- function(feedback){
  fbfile <- 'feedback.csv'
  if(drop_exists(file.path(db_dir,responsesDir,fbfile))){
    feedback_db <-drop_read_csv(file.path(db_dir,responsesDir,fbfile))
    feedback_db <- rbind(feedback_db, feedback)
    write.csv(x = feedback_db, file = file.path(fbfile), row.names = FALSE)
    drop_upload(file = file.path(fbfile), path = file.path(db_dir, responsesDir))
  }
  else{
    write.csv(x = feedback, file = file.path(fbfile), row.names = FALSE)
    drop_upload(file = file.path(fbfile), path = file.path(db_dir, responsesDir))
  }
}

# get the html to display a tweet
grab_html <- function(round){
  tweet_info = GET(paste0("https://publish.twitter.com/oembed?url=",tweet_df$status_url[round],
                          "?omit_script=TRUE?hide_media=TRUE?hide_thread=TRUE"))
  tweet_html = content(tweet_info, "parsed")$html
  return(tweet_html)
}

# give user a random ID
set_user <- function(){
  user <- digest::digest(humanTime()) # gives the user a hash based on the date and time
  if(file.exists('users.txt')){
    if(user %in% read_lines('users.txt')){
      user <- set_user()
    }
  }
  write_lines(user, 'users.txt', append = TRUE)
  return(user)
}



# which fields get saved
fieldsAll <- c('race_ethnicity', 'nationality', 'gender', 'age', 'state', "comment", "valence", "rating", "topic")
fieldsFeedback <- c("difficult_part","discomfort_yes", "discomfort_no","general_feeling")

# set directory to store responses
responsesDir <- file.path("responses")
db_dir <-  file.path('tweetratings','turker_ratings')
#db_dir <-  file.path('test')
if(!drop_exists(db_dir)){
  drop_create(db_dir)
}
if(!drop_exists(file.path(db_dir,responsesDir))){
  drop_create(file.path(db_dir,responsesDir))
}
tweet_dir <- "class_tweets.csv"
if(drop_exists(file.path(db_dir,tweet_dir))){
  full_df <- drop_read_csv(file.path(db_dir,tweet_dir), row.names=NULL, colClasses = 'character')
  cat('loaded from db')
} else {
  full_df <- read_csv(tweet_dir, col_types = cols(.default = 'c'))
  cat('loaded from local')
}
# preps raw tweets
if(!('status' %in% names(full_df))){
  full_df <- full_df %>%
    select(user_id, status_id, screen_name, text, starts_with('reply'), is_quote, is_retweet, contains('count'), urls_expanded_url, media_expanded_url, ext_media_expanded_url, status_url, name, location, description, url, protected, account_created_at, contains('profile'), has_keyword, query) %>%
    mutate(n_ratings = 0, status = 'waiting', rating_average = NA, rating_1 = NA, rating_2 = NA, rating_3 = NA, extra_rating_1 = NA, extra_rating_2 = NA) 
  full_df %>% write_csv(tweet_dir)
}
tweet_df <- full_df %>%
  filter(status == 'waiting') %>% 
  arrange(desc(n_ratings)) %>% 
  head(min(100, nrow(full_df %>% filter(status == 'waiting')))) %>% 
  sample_n(min(49, nrow(full_df %>% filter(status == 'waiting')))) %>% 
  bind_rows(read_csv('resources/attention_check.csv', col_types = cols(.default = 'c'))) %>% 
  sample_frac(1) %>%
  mutate(status = 'active')

completion_code <- digest::digest(tweet_df %>% arrange(screen_name))


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
 


likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)

cat("source complete")

