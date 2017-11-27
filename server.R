library(shiny)
require(digest)
require(dplyr)

source('helpers.R')


shinyServer(
  function(input, output, session) {
    
    ##########################################################
    ########### PART I: LOGIN ################################
    ##########################################################
    
    # When the Login button is clicked, check whether user name is in list
    observeEvent(input$login, {
      
      # User-experience stuff
      shinyjs::disable("login")
      
      # Check whether user name and password are correct
      user_ok <- checkuser(input$user, input$password)
      start_tweet(input$user)
      # If credentials are valid push user into experiment
      if(user_ok){
        shinyjs::hide("login_page")
        shinyjs::show("instructions")
        
        # Save username to write into data file
        output$username <- renderText({input$user})
      } else {
        # If credentials are invalid throw error and prompt user to try again
        shinyjs::reset("login_page")
        shinyjs::show("login_error")
        shinyjs::enable("login")
      }
      
    })
    
    ##########################################################
    ########### PART II: INSTRUCTIONS ########################
    ##########################################################
    
    observeEvent(input$confirm, {
      hide("instructions")
      show("form")
    })
    
    
    ## Initialize reactive values
    # round is an iterator that counts how often 'submit' as been clicked.
    values <- reactiveValues(round = 1)
    # Initialize Start Tweet
    output$tweet_html = renderText(grab_html(as.integer(start_tweet(input$user)+values$round)))
    
    # df will carry the responses submitted by the user
    values$df <- NULL
    output$goodbye_image = renderText('<img src="https://m.popkey.co/93d740/v49wk.gif">')
    
    
    ## This is the main experiment handler
    #Observe the finish button, if cliked, end experiment
    observeEvent(input$finish_rating, {
      # Increment the round by one
      
      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      #save the data
      saveData(values$df)
      output$end_message = renderText(paste0('You rateed ', values$round-1, ' Tweets, Thank you ', input$user,'!'))
      update_tweet_count(input$user, values$round)
      # Say good-bye
      hide(id = "form")
      show(id = "end")
      
    })
    # Observe the submit button, if clicked... FIRE
    observeEvent(input$submit, {
      
      # Increment the round by one
      isolate({
        values$round <- values$round +1
      })
      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      
      # Are there anymore tweets left?
      # If not then...
      
      if(values$round==dim(tweet_df)[[1]]){
        # Call function formData() (see below) to record submitted response
        newLine <- isolate(formData())
        
        # Write newLine into data frame df
        isolate({
          values$df <- rbind(values$df, newLine)
        })
        #save the data
        saveData(values$df)
        output$end_message = renderText(paste0('There are no more tweets. You rateed ', values$round-1, ' Tweets, Thank you!'))
        # Say good-bye
        hide(id = "form")
        show(id = "end")
      }
    })
    
    ## Utilities & functions

    # I take formData from Dean with minor changes.
    # When it is called, it creates a vector of data.
    # This will be a row added to values$df - one for each round.
    #
    # Gather all the form inputs (and add timestamp)
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(round = values$round-1, data, id = tweet_df$id[values$round], screenname = tweet_df$screenName[values$round], timestamp = humanTime())
      data <- t(data)
      data
    })
    
    # This renders the table of choices made by a participant that is shown
    # to them on the final screen
   
    # Tell user where she is
    output$round_info <- renderText({
      paste0("Tweet #",values$round)
    })
    #output$tweet_html <- "<blockquote class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">From the sets of <a href=\"https://twitter.com/hashtag/PSPK25?src=hash&amp;ref_src=twsrc%5Etfw\">#PSPK25</a> <a href=\"https://twitter.com/hashtag/Trivikram?src=hash&amp;ref_src=twsrc%5Etfw\">#Trivikram</a> <a href=\"https://twitter.com/hashtag/PawanKalyan?src=hash&amp;ref_src=twsrc%5Etfw\">#PawanKalyan</a> <a href=\"https://twitter.com/KeerthyOfficial?ref_src=twsrc%5Etfw\">@KeerthyOfficial</a> <a href=\"https://t.co/SxDzt745WZ\">pic.twitter.com/SxDzt745WZ</a></p>&mdash; Trivikram Dialogues (@TrivikramFans) <a href=\"https://twitter.com/TrivikramFans/status/928967148734636032?ref_src=twsrc%5Etfw\">November 10, 2017</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n"
    #output$tweet_html = renderText('<blockquote class=\"twitter-tweet\"><p lang=\"en\" dir=\"ltr\">From the sets of <a href=\"https://twitter.com/hashtag/PSPK25?src=hash&amp;ref_src=twsrc%5Etfw\">#PSPK25</a> <a href=\"https://twitter.com/hashtag/Trivikram?src=hash&amp;ref_src=twsrc%5Etfw\">#Trivikram</a> <a href=\"https://twitter.com/hashtag/PawanKalyan?src=hash&amp;ref_src=twsrc%5Etfw\">#PawanKalyan</a> <a href=\"https://twitter.com/KeerthyOfficial?ref_src=twsrc%5Etfw\">@KeerthyOfficial</a> <a href=\"https://t.co/SxDzt745WZ\">pic.twitter.com/SxDzt745WZ</a></p>&mdash; Trivikram Dialogues (@TrivikramFans) <a href=\"https://twitter.com/TrivikramFans/status/928967148734636032?ref_src=twsrc%5Etfw\">November 10, 2017</a></blockquote>\n<script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>\n')
    
  }
)