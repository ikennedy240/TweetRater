library(httr)
library(rdrop2)
library(googlesheets)

setwd('/srv/shiny-server/TweetRater')
token <- readRDS("droptoken.rds")
db_dir = 'tweetratings'
suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))
# which fields get saved
fieldsAll <- c("user", "rating", "stereotype")

# self-explanatory
responsesDir <- file.path("responses")

#loat tweet df 
  # from dropbox
tweet_df = drop_read_csv(file.path(db_dir, "test_tweets.csv"), dtoken=token, row.names=1, colClasses = 'character')
  # from local file
#tweet_df = read.csv("test_tweets.csv", row.names=1, colClasses = 'character')
# Password to login for this session
passwords = gs_title("Sign up for Ian's Tweet Rater (Responses)")
session_users = gs_read(passwords)

# Checking user and password agianst df of proper names
checkuser = function(user, password){
  
  if(any(session_users$users==user)){
    if(session_users$passwords[session_users$users==user]==password){
      return(TRUE)
    }
    else{
      return(FALSE)
    }
  }
  else{
    return(FALSE)
  }
}


# Check if there is a file with the user's name, if not, create 
start_tweet <- function(user){
  filename=paste0(tolower(user),".csv")
  path = file.path(db_dir,filename)
  if(drop_exists(path = path, dtoken=token)){
    start = as.integer(drop_read_csv(path, dtoken=token, row.names = 1, colClasses = "character")[2,1])
  }
  else{
    start = 1
    write.csv(c(user,start), filename)
    drop_upload(filename, db_dir, dtoken=token)
  }
  return(start)
}

update_tweet_count <- function(user, rounds){
  filename=paste(tolower(user),".csv",sep='')
  path = file.path(db_dir,filename)
  new_start = as.integer(drop_read_csv(path, dtoken=token, row.names = 1, colClasses = "character")[2,1])+rounds
  write.csv(c(user,new_start), filename)
  drop_upload(file=filename,path=db_dir, dtoken=token)
}  



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
            row.names = FALSE, quote = TRUE)
  drop_upload(file = file.path(responsesDir, fileName), 
              path = file.path(db_dir,responsesDir),
              dtoken = token)
}

epochTime <- function() {
  as.integer(Sys.time())
}



grab_html <- function(round){
  tweet_info = GET(paste("https://publish.twitter.com/oembed?url=https://twitter.com/",tweet_df$screenName[round],
                         "/status/",tweet_df$id[round],"?omit_script=TRUE", sep=''))
  tweet_html = content(tweet_info, "parsed")$html
  
  return(tweet_html)
}
tweet_html = "<blockquote class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">From the sets of <a href=\"https://twitter.com/hashtag/PSPK25?src=hash&amp;ref_src=twsrc%5Etfw\">#PSPK25</a> <a href=\"https://twitter.com/hashtag/Trivikram?src=hash&amp;ref_src=twsrc%5Etfw\">#Trivikram</a> <a href=\"https://twitter.com/hashtag/PawanKalyan?src=hash&amp;ref_src=twsrc%5Etfw\">#PawanKalyan</a> <a href=\"https://twitter.com/KeerthyOfficial?ref_src=twsrc%5Etfw\">@KeerthyOfficial</a> <a href=\"https://t.co/SxDzt745WZ\">pic.twitter.com/SxDzt745WZ</a></p>&mdash; Trivikram Dialogues (@TrivikramFans) <a href=\"https://twitter.com/TrivikramFans/status/928967148734636032?ref_src=twsrc%5Etfw\">November 10, 2017</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n"
likert = list("Very Negative" = -3, 
              "Somewhat Negative" = -2,
              "Mildly Negative" = -1,
              "Neutral" = 0,
              "Mildly Positive" = 1,
              "Somewhat Postive" = 2,
              "Very Positive" = 3)
