# this version is meant for the simple rating of tweets to include in the training set

library(httr)
library(readr)
library(dplyr)


# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
  write_csv(x = as.data.frame(data), path = 'responses/ian.csv', append = TRUE)
}

grab_html <- function(round){
  tweet_info = GET(paste0("https://publish.twitter.com/oembed?url=",tweet_df$status_url[round],
                          "?omit_script=TRUE?hide_media=TRUE?hide_thread=TRUE"))
  tweet_html = content(tweet_info, "parsed")$html
  return(tweet_html)
}

# user is always Ian for this one
set_user <- function() return('ian')

user <- set_user()


# which fields get saved
fieldsAll <- c("blackmen", "blackwomen", "blackpeople", "example")

# set directory to store responses
responseFile <- 'responses/ian.csv'

# from local file
tweet_dir <- file.path("../data/tweets/full_tweet_sample.csv")
tweet_df <-  read.csv(tweet_dir, row.names=NULL, colClasses = 'character') %>% sample_frac(1)

# check and see if we have ratings for any of those tweets and remove them if we do
if(file.exists(responseFile)){
  existing <- read.csv(responseFile, row.names=NULL, colClasses = 'character')
  tweet_df <- tweet_df %>% filter(!(status_id %in% existing$status_id))
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
 

likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)
