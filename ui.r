library(shiny)
library(DT)

fluidPage(
    titlePanel("Python CSV Data Display in Shiny"),
    sidebarLayout(
        sidebarPanel(
            numericInput("people", "Number of People:", value = 4, min = 1, max = 4),
            sliderInput("ageMultiplier", "Age Multiplier:", min = 0.5, max = 2, value = 1, step = 0.1)
        ),
        mainPanel(
            DTOutput("table")
        )
    )
)
