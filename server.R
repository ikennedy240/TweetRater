library(shiny)
require(digest)
require(dplyr)

source('helpers.R')

shinyServer(
  function(input, output, session) {
    
    output$testnumber = renderText("Tweet Count and Save Data")
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
        shinyjs::show("form")
        
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
    #output$tweet_html = renderText("tweet_df$text[as.integer(start_tweet(input$user)+values$round)]")
    #output$tweet_alt = renderText(as.integer(start_tweet(input$user)+values$round))
    # df will carry the responses submitted by the user
    values$df <- NULL
    output$goodbye_image = renderText('<img src="https://media.giphy.com/media/osjgQPWRx3cac/giphy.gif" height="100" width="100">')
    # Tell user where she is
    output$round_info <- renderText({
      paste0("Tweet #",as.integer(start_tweet(input$user)+values$round))
    })
    ## This is the main experiment handler
    #Observe the finish button, if cliked, end experiment
    observeEvent(input$finish_rating, {
      disable("submit")
      disable("finish_rating")
      # Call function formData() (see below) to record submitted response
      newLine <- isolate(formData())
      
      # Write newLine into data frame df
      isolate({
        values$df <- rbind(values$df, newLine)
      })
      #save the data
      saveData(values$df)
      if(values$round==1){
        output$end_message = renderText(paste0('You rated ', values$round, ' Tweet, Thank you ', input$user,'!'))
      } else{
        output$end_message = renderText(paste0('You rated ', values$round, ' Tweets, Thank you ', input$user,'!'))
      }
      output$response_form = renderText("See you next time!")
      if(start_tweet(input$user)+values$round>=dim(tweet_df)[[1]]){
        output$response_form = renderText('<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSclOxuQ5dEX0MYDOhobDiWz1wndGUp6Uf74fuv_6KEQgCaIrw/viewform?embedded=true" width="700" height="520" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>')
      }
      update_tweet_count(input$user, values$round)
      # Say good-bye
      hide(id = "form")
      show(id = "end")
      
    })
    # Observe the submit button, if clicked... FIRE
    observeEvent(input$submit, {
      disable("submit")
      disable("finish_rating")
  
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
      enable("finish_rating")
      # Are there anymore tweets left?
      # If not then...
      
      #print(paste("is it true?",start_tweet(input$user)+values$round>=dim(tweet_df)[[1]]))
      if(start_tweet(input$user)+values$round>dim(tweet_df)[[1]]){
        disable("submit")
        disable("finish_rating")
        # Call function formData() (see below) to record submitted response
        newLine <- isolate(formData())

        # Write newLine into data frame df
        isolate({
          values$df <- rbind(values$df, newLine)
        })
        #save the data
        saveData(values$df)
        output$end_message = renderText(paste0('There are no more tweets. You rateed ', values$round, ' Tweets, Thank you!'))
        output$response_form = renderText('<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSclOxuQ5dEX0MYDOhobDiWz1wndGUp6Uf74fuv_6KEQgCaIrw/viewform?embedded=true" width="700" height="520" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>')
          
        # Say good-bye
        update_tweet_count(input$user, values$round)
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
      data <- c(index = start_tweet(input$user)+values$round, data, status_id = tweet_df$status_id[start_tweet(input$user)+values$round], screen_name = tweet_df$screen_name[start_tweet(input$user)+values$round], timestamp = humanTime())
      data <- t(data)
      data
    })

  }
)
