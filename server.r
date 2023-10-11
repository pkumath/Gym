library(shiny)
library(DT)

function(input, output) {
    data <- reactive({
        # Pass the parameters to the Python script
        command <- sprintf("/Users/wengang/opt/anaconda3/envs/casestudy_env/bin/python demo.py -p %d -a %f", input$people, input$ageMultiplier)
        system(command)
        read.csv("output_data.csv")
    })
    
    output$table <- renderDT({
        datatable(data())
    })
}
