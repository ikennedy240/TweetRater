# TweetRater
an rShiny app for rating tweets

This app was created as part of a DataScience course at the University of Washington. Its aim is to improve methods for assessing racist sentiment in online discourse by providing a tool for creating human-rated test samples of tweets. 

IMPORTANT: This app was designed to run on the shiny.io servers which have no local storage. I (somewhat clumsily) used a combination of googlesheets (for login information) and dropbox (to save ratings and the set of tweets to be rated). If you want to use this code as is, you'll need to create a dropbox token, saved as 'droptoken.rds' and a googlesheets token, saved as 'googlesheets_token.rds' both uploaded to the same directory on the shiny.io server.

Tweet Set Setup: If you're using dropbox the way I did, you'll need to make a 'tweetratings' directory in your dropbox home folder. That's where you'll save you set of tweets as 'test_tweets.csv'. That csv file needs to include the tweet id numbers (as character strings) and the usernames with column names 'id' and 'screenName' respectively. 'tweeetratings' will need subdirectories like this:

├── tweetratings
│   ├── test_tweets.csv
│   ├── responses
│   ├── responsearchive
│   ├── trash
│   └── tweetarchive

User info setup: I used a google form to gather some user information and let users set their own passwords. The form-generated sheet has annoying titles based on the questions I asked to gather that information. You'll need to adjust to find the columns you use.


