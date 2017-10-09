# Define UI for application 
shinyUI(fluidPage(
  # You can pick out these from here: https://rstudio.github.io/shinythemes/
  # Must install ggthemes package
  theme = shinytheme("united"), #Others to try include 'paper','slate','sandstone'
  
  # Application title
  titlePanel("R Ladies San Diego: Shiny Demo"),
    
    navbarPage("Shiny Tabs",  
               
               tabPanel("Topic Explorer",
                    sidebarLayout(position = "left",
                        sidebarPanel(
                          selectInput("level", "Experience Level:",
                                      c("Beginner (1)" = "Beginner",
                                        "Intermediate (2,3)" = "Intermediate",
                                        "Advanced (4,5)" = "Advanced"))
                        ),
                      # Render Plot in Main Panel
                        mainPanel(
                           plotOutput("topicPlot")
                                ))),
               tabPanel("R Ladies Map",
                        h2("Map of R ladies Chapters"),
                        leafletOutput("rladiesMap")
                        )
              )))
