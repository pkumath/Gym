library(shiny)
library(DT)

d = read.csv('data/summary_data.csv')
fluidPage(
    titlePanel("Python CSV Data Display in Shiny"),
    sidebarLayout(
        sidebarPanel(
            numericInput("times", "Number of sim:", value = 1000, min = 1, max = 1001),
            # sliderInput("gender", "Gender:", min = 0.5, max = 2, value = 1, step = 0.1)
            # select gender 
            selectInput(inputId='gender', 
                        label = 'Gender', 
                        choices = sort(unique(d$'Gender')), 
                        selected = c('w'), 
                        multiple = T),
        ),
        mainPanel(
            DTOutput("table"), 
            plotOutput("hist")
        )

    )
)
