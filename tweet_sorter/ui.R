library(shinyjs)
source('helpers_sorter.R')
shinyUI(fluidPage(
  useShinyjs(),
  div(
      id = "form",
      titlePanel("Main rating screen"),
      
      sidebarLayout(
        sidebarPanel(
          p("Look at the tweet or tweet conversation. Use the sentiment rater to evaluate
            the sentiment the tweet presents."),br(),
          checkboxInput("blackmen","Black Men"),
          checkboxInput("blackwomen","Black Women"),
          checkboxInput("blackpeople","Black People"),
          checkboxInput("example",
                        label = "Tweet is a good example"),
          actionButton("submit", "Submit", class = "btn-primary"),
          actionButton("finish_rating", "Save and Exit", class = "btn-primary")
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