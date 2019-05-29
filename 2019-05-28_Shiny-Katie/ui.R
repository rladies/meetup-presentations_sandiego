library(shiny)

# Define UI for application 
shinyUI(fluidPage(
    
    theme = shinytheme("spacelab"), 
    # Application title
    titlePanel("R Ladies San Diego: Shiny Demo"),
    
    # Define Two Tabs in the Navigation Bar
    navbarPage("Shiny Tabs",  
               
               tabPanel("Topic Explorer"
                        ,sidebarLayout(position = "left",
                                       sidebarPanel(
                                           selectInput("level", "Experience Level:",
                                                       c("Beginner (1)" = "Beginner",
                                                         "Intermediate (2,3)" = "Intermediate",
                                                         "Advanced (4,5)" = "Advanced"))
                                       ),
                                       # Main Panel where plot will render
                                       mainPanel(
                                           plotOutput("topicPlot")
                                       )
                        )
               ),
               tabPanel("R Ladies Map"
               )
    )
    ###########  
 
))
