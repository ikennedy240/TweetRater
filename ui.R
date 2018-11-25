library(shinyjs)

source('helpers.R')
shinyUI(fluidPage(
  useShinyjs(),
  div(
    id = "login_page",
    titlePanel("Welcome to the tweet rater!"),
    br(),
    sidebarLayout(
      
      sidebarPanel(
        h2("Login"),
        p("Please use the user name and password from your invite email to login."),
        hidden(
          div(
            id = "login_error",
            span("Your user name is invalid. Please check for typos and try again.
                 If you're really sure about them, email Ian at", style = "color:red"),
            a("ikennedy@uw.edu", href="mailto:ikennedy@uw.edu")
          )
        )
      ),
      
      mainPanel(
        textInput("user", "Name", ""),
        #textInput("password", "Password", ""),
        actionButton("login", "Begin", class = "btn-primary")
      )
    )
  ),
  
  hidden(
    div( id = "instructions",
         h3("Instructions"),
         p("You will be shown a series of tweets. For each tweet, please rate the level of anti-black
           racism you feel is present in that tweet. The rating is meant to be based on your subjective
           reading, not some objective standard. You should also consider the overall tone of the tweet and, if possible,
           the context. If it was tweeted in reply to another tweet, that tweet will appear about the key tweet. 
           Please rate the bottom tweet only, as in the example below. You can record any notes you have about the text
           as well. Make sure you click 'Save Ratings and Exit' to record your responses."),
         actionButton("confirm", label = "Ok, I got it... let's start"),
         img(src='http://indulgencezine.com/wp-content/uploads/2017/11/tweet-example-with-text.png', class="img-responsive")
         #add instructions vis tweet context
         )
    ),
  
  hidden(
    div(
      id = "form",
      titlePanel("Main rating screen"),
      
      sidebarLayout(
        
        sidebarPanel(
          p("Look at the tweet or tweet conversation. Use the sentiment rater to evaluate
            the sentiment the tweet presents."),br(),
          checkboxGroupInput("topic",
                       label = h3("Check all applicable topics"),
                       choices = c('Black Men', 'Black Women', 'Black People')),
          checkboxGroupInput("valence",
                             label = h3("Check all applicable topics"),
                             choices = c('Racist', 'Anti-Racist', 'Empowering')),
          radioButtons("rating",
                       label = h3("Sentiment Rating towards black people"),
                       choices = likert,
                       selected = 0),
          h3("Would this tweet be a good example for turkers?"),
          checkboxInput("example",
                        label = "Tweet is a good example"),
          textInput("notes",
                    label = h3("Any notes about your rating here?"),
                    placeholder = "notes"
                    ),
          actionButton("submit", "Submit", class = "btn-primary"),
          br(),br(),
          actionButton("finish_rating", "Save Ratings and Exit", class = "btn-primary")
        ),
        mainPanel(
          h4(textOutput("round_info")),
          uiOutput("tweet_html", inline = TRUE),
          br(),p("Tweet Text:"),br(),
          p(textOutput("tweet_text")),
          br(),p("Average Rating:"),br(),
          p(textOutput("tweet_rating"))
          #HTML(uiOutput("tweet_html"))
        )
      )
    )
  ),
  
  hidden(
    div(
      id = "end",
      titlePanel("Thank you!"),
      
      sidebarLayout(
        
        sidebarPanel(
          uiOutput("goodbye_image"),
          textOutput("end_message")
        ),
        
        mainPanel(
          uiOutput('response_form')
        )
      )
    )
  )
  )
  )
