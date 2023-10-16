library(shiny)
library(DT)
library(reticulate)
# prediction <- import("src/prediction")

function(input, output) {
    data <- reactive({
        # Pass the parameters to the Python script
        # command <- sprintf("/Users/wengang/opt/anaconda3/envs/casestudy_env/bin/python demo.py -p %d -a %f", input$people, input$ageMultiplier)
        # system(command)
        # read.csv("output_data.csv")
        source_python('src/prediction.py')
        run_simulations(input$times, input$gender)
        read.csv('_total_number_of_medals_results.csv')
    })
    
    # table of top 10 countries with three columns: Country, average medals and standard deviation across all simulations
    # top10 <- reactive({
    #     tmp_data <- data()
    #     rowsum <- rowMeans(tmp_data)
    #     rowstd <- apply(tmp_data, 1, sd)

    #     # Choose the top 10 countries with the highest average number of medals
    #     top10 <- data.frame(rowsum, rowstd)
    #     top10 <- top10[order(-top10$rowsum),]
    #     top10 <- top10[1:10,]

    #     # return the top 10 countries
    #     top10
    # })

    output$table <- renderDT({
        # Give a title to the table
        # datatable(data(), options = list(dom = 't', paging = FALSE, ordering = FALSE, searching = FALSE, info = FALSE), rownames = FALSE, colnames = c("Country", "Average number of medals", "Standard deviation"))
        datatable(data())
    })
    
    # histogram of top 10 countries
    output$hist <- renderPlot({
        tmp_data <- data()
        # calculate the row average with respect to all the columns other than the first column
        rowsum <- rowMeans(tmp_data[,2:ncol(tmp_data)])
        rowstd <- apply(tmp_data[,2:ncol(tmp_data)], 1, sd)
        country_name <- tmp_data[,1]
        # rowsum <- rowMeans(tmp_data)
        # rowstd <- apply(tmp_data, 1, sd)

        # Choose the top 10 countries with the highest average number of medals
        top10 <- data.frame(country_name, rowsum, rowstd)
        top10 <- top10[order(-top10$rowsum),]
        top10 <- top10[1:10,]

        # Create a data frame with three columns: Country, average medals and standard deviation across all simulations
        df <- data.frame(country = top10$country_name, avg_medals = top10$rowsum, sd = top10$rowstd)

        # Plot the histogram of the top 10 countries with the highest average number of medals, plot the average number of medals and also the standard deviation
        # hist(top10$rowsum, main = "Histogram of the top 10 countries with the highest average number of medals", xlab = "Average number of medals", ylab = "Frequency", col = "blue", border = "red")
        bp <- barplot(df$avg_medals, names.arg = df$country, ylim = c(0, 6), 
              xlab = "Country", ylab = "Average number of medals", 
              col = "blue", border = "red", 
              main = "Average number of medals for the top 10 country", plot = FALSE)

        barplot(df$avg_medals, names.arg = df$country, ylim = c(0, 6), 
        xlab = "Country", ylab = "Average number of medals", 
        col = "blue", border = "red", 
        main = "Average number of medals for the top 10 country")
        arrows(x0 = bp, y0 = df$avg_medals - df$sd, 
            x1 = bp, y1 = df$avg_medals + df$sd, 
            length = 0.05, angle = 90, code = 3)
    })
    
}
