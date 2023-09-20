
# Read the dataset from data/data_2022_2023.csv
data <- read.csv("data/data_2022_2023.csv")
# print the size of the data
print(dim(data))

# Select the contry column from the data
country <- data$Country
# Select 12 contries from the data. Note that we should ignore repeated entries.
country <- unique(country)
country <- country[1:12]
# Select the rows in the data that matches the contries we selected
data <- data[data$Country %in% country,]
# print the size of the data
print(dim(data))

data <- data[!is.na(data$Total), ]

# Split the data based on the country
data_split <- split(data, data$Country)

# For each data frame in the list, select the top 5 gymnasts based on the total score
# write a function that returns the top k gymnasts based on the total score
# create a list that contains the top 5 gymnasts for each country
# create an empty list
top_5_list <- list()
for (i in 1:length(data_split)){
  country_data <- data_split[[i]] # country_data is a data frame with multiple gymnasts
  country_data_split <- split(country_data, country_data$LastName)
  # For each data frame (corresponding to each individual athlete) in the list, calculate the average total score
  average_score_lst <- list()
  last_name_list <- list()
  first_name_list <- list()
  for (j in 1:length(country_data_split)){
    # append the average score to the list
    average_score_lst <- c(average_score_lst, mean(country_data_split[[j]]$Total))
  }
  # create a data frame that contains the average total score and the name of the athlete, the data frame should contains 3 columns with the name "LastName", "FirstName", and "Score"
  df_new <- data.frame(last_name_list, first_name_list, total_sc_split)
  # rename the columns
  colnames(df_new) <- c("LastName", "FirstName", "Score")
  # sort the data frame based on the average total score
  df_new <- df_new[order(df_new$Score, decreasing = TRUE),]
  # select the top k athletes
  df_new <- df_new[1:k,]
  # append the data frame to the list
  top_5_list <- c(top_5_list, df_new)
}
# print the list
print(top_5_list)