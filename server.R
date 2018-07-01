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
    observeEvent(input$login, {
      
      # User-experience stuff
      shinyjs::disable("login")
      start_k <- start_tweet(input$user)
      values$round <- values$round+start_k
      print(values$round)
      # Check whether user name and password are correct
      user_ok <- checkuser(input$user, input$password)
      
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
    
    # Initialize Start Tweet
    output$tweet_html = renderText(grab_html(values$round))
    values$df <- NULL
    output$goodbye_image = renderText('<img src="https://media.giphy.com/media/osjgQPWRx3cac/giphy.gif" height="100" width="100">')
    # Tell user where she is
    output$round_info <- renderText({
      paste0("Tweet #",as.integer(values$round))
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
        output$end_message = renderText(paste0("You've rated ", values$round, ' Tweet, Thank you ', input$user,'!'))
      } else{
        output$end_message = renderText(paste0("You've rated ", values$round, ' Tweets, Thank you ', input$user,'!'))
      }
      output$response_form = renderText("See you next time!")
      if(values$round>=dim(tweet_df)[[1]]){
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
      
      if(values$round>dim(tweet_df)[[1]]){
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
      data <- c(index = values$round, data, status_id = tweet_df$status_id[values$round], screen_name = tweet_df$screen_name[values$round], timestamp = humanTime())
      data <- t(data)
      data
    })

  }
)
