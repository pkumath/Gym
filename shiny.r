library(shiny)
library(ggplot2)
# Define the run_simulations function
run_simulations <- function(num_simulations) {
  # Generate random scores for each apparatus
  apparatus_scores <- matrix(runif(n = 6 * num_simulations, min = 0, max = 10), ncol = 6)
  
  # Calculate the total score for each gymnast
  total_scores <- rowSums(apparatus_scores)
  
  # Create a data frame with the results
  results <- data.frame(
    "TotalScore" = total_scores
  )
 
  # Return the results
  return(results)
}


# Define the UI
ui <- fluidPage(
  titlePanel("Gymnastics Simulation"),
  sidebarLayout(
    sidebarPanel(
      numericInput("num_simulations", "Number of Simulations:", value = 100),
      selectInput("gender", "Gender:", choices = c("Men", "Women")),
      selectInput("country", "Country:", choices = c("USA", "Russia", "China")),
      actionButton("run_simulations", "Run Simulations")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Input", tableOutput("input_table")),
        tabPanel("Output", tableOutput("output_table"))
      )
    )
  )
)

# Define the server
server <- function(input, output) {
  # Define the input table
  input_table <- reactive({
    data.frame(
      "Number of Simulations" = input$num_simulations,
    )
  })
  
  # Define the output table
  output_table <- eventReactive(input$run_simulations, {
    # Call the run_simulations function with the user input
    output_data <- run_simulations(num_simulations = input$num_simulations)
    
    # Convert the output data to a data frame
    data.frame(output_data)
  })
  
  # histogram the "Total Score" column of the output table
    x    <- output_table$TotalScore
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    hist(x, breaks = bins, col = "#007bc2", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")


}

# Run the app
shinyApp(ui = ui, server = server)

