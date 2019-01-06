library(shiny)
require(digest)
require(dplyr)

#source('helpers.R')
#print('loaded helpers')
shinyServer(
  function(input, output, session) {
    
    output$testnumber = renderText("Tweet Count and Save Data")
    ##########################################################
    ########### PART I: LOGIN ################################
    ##########################################################
    #initialize values
    values <- reactiveValues(round = 1)
    # When the Login button is clicked, check whether user name is in list
    observeEvent(input$complete, {
      
      # User-experience stuff
      shinyjs::disable("complete")
      start_k <- 0
      values$round <- values$round+start_k
      print(values$round)
      user_ok <- TRUE
      # If credentials are valid push user into experiment
      if(user_ok){
        shinyjs::hide("demo_page")
        shinyjs::show("instructions")
        
        # Save username to write into data file
        output$username <- renderText({user})}
 
      
    })
    
    ##########################################################
    ########### PART II: INSTRUCTIONS ########################
    ##########################################################
    
    observeEvent(input$confirm, {
      hide("instructions")
      show("form")
    })
    
    # Initialize Start Tweet
    output$tweet_html = renderText(grab_html(values$round))
    output$tweet_text = renderText(tweet_df$text[[values$round]])
    output$tweet_rating = renderText(tweet_df$rating[[values$round]])
    values$df <- NULL
    output$goodbye_image = renderText('<img src="https://media.giphy.com/media/osjgQPWRx3cac/giphy.gif" height="100" width="100">')
    # Tell user where she is
    output$round_info <- renderText({
      paste0("Tweet #",as.integer(values$round))
    })
    ## This is the main experiment handler
    #Observe the finish button, if cliked, end experiment
  
    # Observe the submit button, if clicked... FIRE
    observeEvent(input$submit, {
      disable("submit")

      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      
      # Increment the round by one
      isolate({
        values$round <- values$round +1
      })
      
      shinyjs::reset('form')
      enable("submit")
      # Are there anymore tweets left?
      # If not then...
      
      if(values$round>dim(tweet_df)[[1]]){
        disable("submit")
        # Call function formData() (see below) to record submitted response
        # newLine <- isolate(formData())

        # Write newLine into data frame df
        # isolate({
        #   values$df <- rbind(values$df, newLine)
        # })
        #save the data
        saveData(values$df)
        output$end_message = renderText(paste0("You're all done with this set!. You rated ", values$round-1, ' Tweets, Thank you!\n Your completion code is: ', completion_code))
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
    # Gather all the form inputs 
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) input[[x]])
      data <- c(index = values$round, user = user, data, status_id = tweet_df$status_id[values$round], screen_name = tweet_df$screen_name[values$round])
      data <- t(data)
      data
    })

  }
)
