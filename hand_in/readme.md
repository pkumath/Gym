
### Purpose
The purpose of this code is to create a user interface for a Shiny app that allows the user to analyze data from a CSV file. The user can specify the number of simulations to run and select one or more genders to include in the analysis. The app displays the results in an interactive table and a histogram plot.

### Description to server.r
The data() reactive expression is used to calculate the row-wise mean and standard deviation of the data, select the top 10 countries with the highest average number of medals, and return a data frame with the results. The barplot() function is then used to create a bar plot of the top 10 countries, with the appearance customized using various arguments. Finally, the arrows() function is used to add error bars to the plot. Note that there are alternative ways to calculate the top 10 countries with the highest average number of medals, and the country names are also included.

### Description to ui.r
This code defines the user interface for a Shiny app. The user interface contains a title panel, a sidebar panel with two input widgets (a numeric input and a select input), and a main panel with two output elements (an interactive table and a histogram plot). The numeric input allows the user to specify the number of simulations to run, while the select input allows the user to select one or more genders to include in the analysis. The data for the app is read in from a CSV file using the read.csv() function. The DTOutput() and plotOutput() functions are used to define the output elements for the interactive table and histogram plot, respectively.

### Description to prediction.py
The run_simulations method will automatically run given rounds of simulations upon called by server.r