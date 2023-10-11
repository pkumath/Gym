#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyverse)
library(shiny)
d = read_csv('/Users/ruixiaowang/Desktop/Yale/2023 Fall/Case Studies/Week3Day2/women_total_number_of_medals_results.csv')
view(d)
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("2024 Olympic Gymnastic Competition Results"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          
            # sliderInput("bins",
            #             "Number of bins:",
            #             min = 1,
            #             max = 50,
            #             value = 30),
            
    
            selectInput(inputId='Country Names', 
                        label = 'Name', 
                        choices = sort(unique(d$'Country Names')), 
                        selected = c('GBR'), 
                        multiple = T),
            
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tableOutput('simTable'),  # Table to display Simulation1 and Simulation2
          #plotOutput("distPlot"), 
          #dataTableOutput('data'), 
          fluidRow(
            column(6, plotOutput('map')), 
            column(6, dataTableOutput('data'))
          )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$simTable <- renderTable({
    selected_countries <- d %>% filter(`Country Names` %in% input$'Country Names')
    data.frame(
      Country = selected_countries$`Country Names`,
      Simulation1 = selected_countries$simulation1,  # Assume you have a column named Simulation1
      Simulation2 = selected_countries$simulation2   # Assume you have a column named Simulation2
    )
  })
    
    
  
    
}

# Run the application 
shinyApp(ui = ui, server = server)
