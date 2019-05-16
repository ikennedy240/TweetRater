library(shiny)
require(digest)
require(dplyr)

#source('helpers.R')
#print('loaded helpers')
shinyServer(
  function(input, output, session) {
    end_ok <- onSessionEnded(function(x) try(isolate({saveData(values$df, mode = 'forced_exit')})))
    output$testnumber = renderText("Tweet Count and Save Data")
    ##########################################################
    ########### PART I: LOGIN ################################
    ##########################################################
    #initialize values
    values <- reactiveValues(round = 1, user = set_user())
    # When the Login button is clicked, check whether user name is in list
    observeEvent(input$complete, {
      print(values$user)
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
        output$username <- renderText({values$user})}
 
      
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
    output$goodbye_image_2 = renderText('<img src="https://media.giphy.com/media/osjgQPWRx3cac/giphy.gif" height="100" width="100">')
    # Tell user where she is
    output$round_info <- renderText({
      paste0("Tweet #",as.integer(values$round))
    })
    ## This is the main experiment handler
    #Observe the finish button, if cliked, end experiment
  
    # Observe the submit button, if clicked... FIRE
    observeEvent(input$submit, {
      disable("submit")
      print(isolate(values$user))
      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      if(newLine[[length(newLine)]]=='uwsian'){
        if(newLine[8]!='Empowering'|newLine[9]!='2'){
          disable("submit")
          #save the data
          saveData(values$df, mode = 'forced_exit')
          end_ok()
          # Say good-bye
          hide(id = "form")
          show(id = "failure")
        }
      }
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      
      # Increment the round by one
      isolate({
        values$round <- values$round +1
      })
      
      shinyjs::reset('form')
      
      # Are there anymore tweets left?
      # If not then...
      
      if(values$round>dim(tweet_df)[[1]]){
        disable("submit")
        #save the data
        saveData(values$df)
        end_ok()
        output$end_message = renderText(paste0("You're all done with this set!. You rated ", values$round-1, ' Tweets, Thank you!\n Your completion code is: ', completion_code))
        # Say good-bye
        hide(id = "form")
        show(id = "end")
        observeEvent(input$complete_feedback,{
          output$end_message_2 = renderText(paste0("You're all done with this set!. You rated ", values$round-1, ' Tweets, Thank you!\n Your completion code is: ', completion_code))
          disable('complete_feedback')
          feedback <- isolate(feedbackData())
          append_feedback(feedback)
          hide(id = "end")
          show(id = "post_feedback")
        })
      }
      enable("submit")
    })
    
    ## Utilities & functions

    # I take formData from Dean with minor changes.
    # When it is called, it creates a vector of data.
    # This will be a row added to values$df - one for each round.
    #
    # Gather all the form inputs 
    formData <- reactive({
      data <- sapply(fieldsAll, function(x) paste(input[[x]], collapse = '+'))
      data <- c(index = values$round, user = values$user, data, status_id = tweet_df$status_id[values$round], screen_name = tweet_df$screen_name[values$round])
      data <- t(data)
      data
    })
    feedbackData <- reactive({
      cat("Inside feedbackData")
      data <- sapply(fieldsFeedback, function(x) input[[x]])
      data <- c(user = values$user, data)
      data <- t(data)
      data
    })
  }
)
