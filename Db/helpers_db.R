library(httr)
library(rdrop2)
library(readr)
library(dplyr)
cat("loaded packages")

drop_auth(rdstoken = 'resources/droptoken.rds')

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
  write.csv(x = data, file = file.path(fileName),
            row.names = FALSE, quote = c(1:13))
  drop_upload(file = file.path(fileName), 
              path = file.path(db_dir,responsesDir))
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
tweet_df <- read_csv("turker_tweets.csv", col_types = cols(.default = 'c'))
# from local file
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


