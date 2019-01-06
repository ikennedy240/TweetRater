library(httr)
library(rdrop2)
library(readr)

drop_auth(rdstoken = 'resources/droptoken.rds')

# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
  fileName <- sprintf("%s_%s.csv",
                      humanTime(),
                      digest::digest(data))
  write.csv(x = data, file = file.path(responsesDir, fileName),
            row.names = FALSE, quote = TRUE)
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
likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)

# which fields get saved
fieldsAll <- c('race_ethnicity', 'nationality', 'gender', 'age', 'state', "comment", "valence", "rating", "topic", "example", "notes")

# set directory to store responses
responsesDir <- file.path("responses")
db_dir <-  file.path('tweetratings','TestHiT1')
if(!drop_exists(db_dir)){
  drop_create(db_dir)
}
tweet_df <- drop_read_csv(file.path(db_dir, "turker_tweets.csv"), colClasses = 'character')
# from local file
completion_code <- digest::digest(db_dir)
#tweet_df = read.csv("turker_tweets.csv", row.names=NULL, colClasses = 'character')
#Password to login for this session


# give user a random string
set_user <- function(){
  user <- digest::digest(humanTime()) # gives the user a hash based on the date and time
  if(file.exists('users.txt')){
    if(user %in% read_lines('users.txt')){
      return(set_user())
    }
  }
  write_lines(user, 'users.txt', append = TRUE)
  return(user)
}
user <- set_user()




# re-re

### Generate data here
###
###
###

# add an asterisk to an input label
labelMandatory <- function(label) {
  tagList(
    label,
    span("*", class = "mandatory_star")
  )
}

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
 
# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
  fileName <- sprintf("%s_%s.csv",
                      humanTime(),
                      digest::digest(data))
  write.csv(x = data, file = file.path(responsesDir, fileName),
            row.names = FALSE, quote = c(1:15))
  drop_upload(file = file.path(responsesDir, fileName), 
              path = file.path(db_dir,responsesDir))
}

epochTime <- function() {
  as.integer(Sys.time())
}

round = 10

grab_html <- function(round){
  tweet_info = GET(paste0("https://publish.twitter.com/oembed?url=",tweet_df$status_url[round],
                         "?omit_script=TRUE?hide_media=TRUE?hide_thread=TRUE"))
  tweet_html = content(tweet_info, "parsed")$html
  return(tweet_html)
}
likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)


