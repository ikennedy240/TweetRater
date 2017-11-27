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
        textInput("user", "User", ""),
        textInput("password", "Password", ""),
        actionButton("login", "Login", class = "btn-primary")
      )
    )
  ),
  
  hidden(
    div( id = "instructions",
         h3("Instructions"),
         p("You will be shown a series of tweets. For each tweet, please rate the level of anti-black
           racism you feel is present in that tweet. The rating is meant to be based on your subjective
           reading, not some objective standard. Then, record whether, based on your reading, the tweet
           has any stereotypes about black people in it."),
         img(src='http://indulgencezine.com/wp-content/uploads/2017/11/tweet-example-with-text.png', class="img-responsive"),
         br(),
         actionButton("confirm", label = "Ok, I got it... let's start")
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
            the sentiment the tweet presents."),
          radioButtons("rating",
                       label = h3("Sentiment Rating towards black folks"),
                       choices = likert,
                       selected = 0),
          radioButtons("stereotype",
                       label = h3("Was there a stereotype present?"),
                       choices = list("Yes"=1, "No"=0),
                       selected = 0),
          actionButton("submit", "Submit", class = "btn-primary"),
          br(),br(),
          actionButton("finish_rating", "Save Ratings and Exit", class = "btn-primary")
        ),
        
        mainPanel(
          h4(textOutput("round_info")),
          uiOutput("tweet_html")
          #h3(textOutput("tweet_html"))
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
          textOutput("end_message")
        ),
        
        mainPanel(
          uiOutput("goodbye_image")
        )
      )
    )
  )
  )
  )
