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
tweet_df = read.csv(tweet_dir, row.names=NULL, colClasses = 'character')

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
 


