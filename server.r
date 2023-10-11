library(shiny)
library(DT)
library(reticulate)
prediction <- import("src/prediction")

function(input, output) {
    data <- reactive({
        # Pass the parameters to the Python script
        # command <- sprintf("/Users/wengang/opt/anaconda3/envs/casestudy_env/bin/python demo.py -p %d -a %f", input$people, input$ageMultiplier)
        # system(command)
        # read.csv("output_data.csv")
        prediction$run_simulations(input$times, input$gender)
        read.csv('_total_number_of_medals_results.csv')
    })
    
    output$table <- renderDT({
        datatable(data())
    })
}
