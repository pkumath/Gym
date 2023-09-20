---
  title: "Gymastics Case Study, Part 2"
author: "425/625"
date: "September 06, 2023"
output:
  pdf_document: default
word_document: default
urlcolor: blue
---


## Predicting outcomes for a set of 5-person teams

## Read the dataset from data_2022_2023.csv
  

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

  # Split the data based on the country
  data_split <- split(data, data$Country)


## For each country, select 5 gymnasts for the team


  # For each data frame in the list, select the top 5 gymnasts based on the total score
  # write a function that returns the top k gymnasts based on the total score
  top_k <- function(df, k){
    # delete the rows that have NA in the total score column
    df <- df[!is.na(df$Total), ]
    # split the data based on the athlete's LastName and FirstName
df_split <- split(df, df$LastName)
# For each data frame (corresponding to each individual athlete) in the list, calculate the average total score
total_sc_split <- lapply(df_split, function(x) mean(x$Total))
# get a name list of the athletes
last_name_list <- lapply(df_split, function(x) x$LastName[1])
first_name_list <- lapply(df_split, function(x) x$FirstName[1])
# create a data frame that contains the average total score and the name of the athlete, the data frame should contains 3 columns with the name "LastName", "FirstName", and "Score"
df_new <- data.frame(last_name_list, first_name_list, total_sc_split)
# rename the columns
colnames(df_new) <- c("LastName", "FirstName", "Score")
# sort the data frame based on the average total score
df_new <- df_new[order(df_new$Score, decreasing = TRUE),]
# select the top k athletes
df_new <- df_new[1:k,]
}



# create a list that contains the top 5 gymnasts for each country
top_5_list <- lapply(data_split, function(x) top_k(x, 5))
# print the list
print(top_5_list)
