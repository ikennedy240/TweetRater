library(shinyjs)
source('helpers_db.R')
shinyUI(fluidPage(
  useShinyjs(),
  div(
    id = "demo_page", 
    titlePanel("Welcome to the tweet rater!"),
    br(),
    sidebarLayout(
      
      sidebarPanel(
        h2("Welcome"),
        p("Please complete the brief demographic survey to begin")
      ),
      
      mainPanel(
        # this is where we're collecting demographic information
        # race
        p("Check all boxes which describe you or that you self-identify as"),
        checkboxGroupInput("race_ethnicity",
                           label = h3("Check all applicable groups"),
                           choices = c('Black/African American', 
                                       'Latino/Hispanic/Spanish', 
                                       'White/Caucasian/European',
                                       'Asian/Pacific Islander',
                                       'Native American/American Indian',
                                       'Other')),
        # nationality
        p("Optionally, provide a national/ethnic heritage, for instance 'Kenyan', 'Italian' or 'Peruvian'"),
        textInput("nationality", "Heritage", ""),
        # gender
        p("Indicate your gender identification"),
        checkboxGroupInput("gender","Gender",
                           choices = c('Female', 
                                       'Male', 
                                       'Gender-Fluid/Non-binary',
                                       'Other')),
        # age
        p("Enter your age"),
        selectInput("age", "Age", 18:121),
        # state of residence
        p("In which state do you primarily reside?"),
        selectInput('state', NULL, state.abb),
        # comment space
        p("Any further comments or info you'd like us to know?"),
        textInput("comment", "Comment", ""),
        actionButton("complete", "Begin", class = "btn-primary")
      )
    )
  ),
  
  hidden(
    div( id = "instructions",
         h3("Instructions"),
         p("You will be shown a series of tweets. For each tweet, there are THREE things we'd like you to rate
           ** First, indicate if Black men, Black women, or Black people are included as topics in the tweet. Check these
           boxes if you think the tweet concerns one of those groups, even if the tweet doesn't use the word 'black'.
           ** Next, please inidcate if you think the tweet is 'racist', 'anti-racist', or 'empowering.'
           ** Finally, please rate the level of anti-black racism you feel is present in that tweet. 
           The ratings are meant to be based on your subjective reading, not some objective standard. 
           You should also consider the overall tone of the tweet and, if possible, the context. 
           If it was tweeted in reply to another tweet, that tweet may appear about the key tweet. 
           Please rate the bottom tweet only, as in the example below. Make sure you click 'Save Ratings and Exit' to record your responses."),
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
          actionButton("submit", "Submit", class = "btn-primary")
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
          textOutput("end_message"),
          p("For more information about this study, you can contact us at ikennedy@uw.edu")
        ),
        
        mainPanel(
        )
      )
    )
  )
  )
  )
