library(dplyr)
library(tidyr)

# Read data
data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")

# For the "Apparatus" column, replace "VT_1", "VT_2" by "VT1", "VT2"
data_2022_2023$Apparatus <- ifelse(data_2022_2023$Apparatus == "VT_1", "VT1",
                                   ifelse(data_2022_2023$Apparatus == "VT_2", "VT2",
                                          ifelse(data_2022_2023$Apparatus == "hb", "HB", data_2022_2023$Apparatus)))

# Filter out NaN in the "Score" column
data_2022_2023 <- subset(data_2022_2023, !is.na(Score))

# Split data_2022_2023 by Gender
men_athletes_data <- subset(data_2022_2023, Gender == "m")
women_athletes_data <- subset(data_2022_2023, Gender == "w")

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_country_athlete_list <- split(men_athletes_data, men_athletes_data$Country)
women_country_athlete_list <- split(women_athletes_data, women_athletes_data$Country)

# Select the top 12 countries with the most entries for both men and women
k <- 12
men_top_12_countries <- names(sort(table(men_athletes_data$Country), decreasing = TRUE))[1:k]
women_top_12_countries <- names(sort(table(women_athletes_data$Country), decreasing = TRUE))[1:k]

# Filter the men_country_athlete_list and women_country_athlete_list by the top 12 countries
men_country_athlete_list_12 <- men_country_athlete_list[men_top_12_countries]
women_country_athlete_list_12 <- women_country_athlete_list[women_top_12_countries]

# Define a function to process the data for each gender
process_data <- function(data_list, apparatus_list) {
  for (country in names(data_list)) {
    data <- data_list[[country]]
    top_5_athletes <- names(sort(table(data$FirstName), decreasing = TRUE))[1:5]
    data <- subset(data, FirstName %in% top_5_athletes)
    
    data <- data %>%
      group_by(FirstName, Apparatus) %>%
      summarize(Score = mean(Score)) %>%
      ungroup()
    
    data_list[[country]] <- data
  }
  
  # Qualifying scores
  qualifying_scores <- lapply(names(data_list), function(country) {
    country_data <- data_list[[country]]
    sapply(apparatus_list, function(apparatus) {
      apparatus_data <- subset(country_data, Apparatus == apparatus)
      if (nrow(apparatus_data) == 0) return(10)
      
      top_2_athletes_scores <- tail(sort(apparatus_data$Score), 2)
      if (length(top_2_athletes_scores) < 2) return(mean(top_2_athletes_scores))
      
      selected_athlete <- country_data %>%
        group_by(FirstName) %>%
        summarize(total_score = sum(Score)) %>%
        arrange(-total_score) %>%
        slice(1) %>%
        pull(FirstName)
      
      selected_score <- subset(country_data, FirstName == selected_athlete & Apparatus == apparatus)$Score
      
      mean(c(top_2_athletes_scores, selected_score))
    })
  })
  
  qualifying_df <- as.data.frame(do.call(rbind, qualifying_scores))
  colnames(qualifying_df) <- apparatus_list
  rownames(qualifying_df) <- names(data_list)
  
  return(qualifying_df)
}

qual_men_apparatuses <- c('HB', 'PH', 'FX', 'PB', 'SR', 'VT')
qual_women_apparatuses <- c('BB', 'FX', 'UB', 'VT')
men_qualifying_df <- process_data(men_country_athlete_list_12, qual_men_apparatuses)
women_qualifying_df <- process_data(women_country_athlete_list_12, qual_women_apparatuses)

# Team final
men_total_scores <- rowSums(men_qualifying_df)
women_total_scores <- rowSums(women_qualifying_df)

top_8_men_countries <- names(sort(men_total_scores, decreasing = TRUE)[1:8])
top_8_women_countries <- names(sort(women_total_scores, decreasing = TRUE)[1:8])

men_team_final_df <- data.frame(Country = top_8_men_countries, Score = men_total_scores[top_8_men_countries], Rank = 1:8)
women_team_final_df <- data.frame(Country = top_8_women_countries, Score = women_total_scores[top_8_women_countries], Rank = 1:8)

print("Men's team final outcome:")
print(men_team_final_df)
print("Women's team final outcome:")
print(women_team_final_df)

# Individual final
calculate_individual_scores <- function(data_list, apparatus_list) {
  scores <- lapply(names(data_list), function(country) {
    country_data <- data_list[[country]]
    selected_athlete <- country_data %>%
      group_by(FirstName) %>%
      summarize(total_score = sum(Score)) %>%
      arrange(-total_score) %>%
      slice(1) %>%
      pull(FirstName)
    
    sapply(apparatus_list, function(apparatus) {
      apparatus_data <- subset(country_data, FirstName == selected_athlete & Apparatus == apparatus)
      if (nrow(apparatus_data) == 0) return(10)
      mean(apparatus_data$Score)
    })
  })
  
  scores_df <- as.data.frame(do.call(rbind, scores))
  colnames(scores_df) <- apparatus_list
  rownames(scores_df) <- names(data_list)
  
  scores_df$TotalScore <- rowSums(scores_df)
  return(scores_df)
}

men_individual_scores_df <- calculate_individual_scores(men_country_athlete_list_12, qual_men_apparatuses)
women_individual_scores_df <- calculate_individual_scores(women_country_athlete_list_12, qual_women_apparatuses)

men_individual_scores_df$TotalRank <- rank(-men_individual_scores_df$TotalScore, ties.method = "min")
women_individual_scores_df$TotalRank <- rank(-women_individual_scores_df$TotalScore, ties.method = "min")

print("Men's individual final:")
print(men_individual_scores_df)
print("Women's individual final:")
print(women_individual_scores_df)
