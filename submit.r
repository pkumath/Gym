library(tidyverse)
library(stringr)

# Read data
data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")

# For the "Apparatus" column, replace "VT_1", "VT_2" by "VT1", "VT2"
data_2022_2023$Apparatus <- str_replace_all(data_2022_2023$Apparatus, c("VT_1" = "VT1", "VT_2" = "VT2"))
# Filter out NaN in the "Score" column
data_2022_2023 <- filter(data_2022_2023, !is.na(Score))

# Split data_2022_2023 by Gender
men_athletes_data <- filter(data_2022_2023, Gender == "m")
women_athletes_data <- filter(data_2022_2023, Gender == "w")

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_country_athlete_list <- split(men_athletes_data, men_athletes_data$Country)
women_country_athlete_list <- split(women_athletes_data, women_athletes_data$Country)

# For men_country_athlete_dict and women_country_athlete_dict, select the top 9 countries with most entries
k <- 12
men_top_12_countries <- head(sort(table(men_athletes_data$Country), decreasing=TRUE), k)
women_top_12_countries <- head(sort(table(women_athletes_data$Country), decreasing=TRUE), k)
men_country_athlete_list_12 <- men_country_athlete_list[names(men_country_athlete_list) %in% names(men_top_12_countries)]
women_country_athlete_list_12 <- women_country_athlete_list[names(women_country_athlete_list) %in% names(women_top_12_countries)]

# Determine a 5-person team for each country based on the top 5 athletes who appear most frequently
for (country in names(men_country_athlete_list_12)) {
  top_5_athletes <- head(sort(table(men_country_athlete_list_12[[country]]$FirstName), decreasing=TRUE), 5)
  men_country_athlete_list_12[[country]] <- filter(men_country_athlete_list_12[[country]], FirstName %in% names(top_5_athletes))
}
for (country in names(women_country_athlete_list_12)) {
  top_5_athletes <- head(sort(table(women_country_athlete_list_12[[country]]$FirstName), decreasing=TRUE), 5)
  women_country_athlete_list_12[[country]] <- filter(women_country_athlete_list_12[[country]], FirstName %in% names(top_5_athletes))
}

# Group data by "Apparatus" and calculate average score, then replace original data
for (country in names(men_country_athlete_list_12)) {
  men_country_athlete_list_12[[country]] <- men_country_athlete_list_12[[country]] %>%
    group_by(FirstName, Apparatus) %>%
    summarize(Score = mean(Score)) %>%
    ungroup()
}
for (country in names(women_country_athlete_list_12)) {
  women_country_athlete_list_12[[country]] <- women_country_athlete_list_12[[country]] %>%
    group_by(FirstName, Apparatus) %>%
    summarize(Score = mean(Score)) %>%
    ungroup()
}
# Identify all apparatuses
apparatuses <- unique(data_2017_2021$Apparatus)

# Men's qualifying stage
apparatus_list <- apparatuses
men_qualifying_scores <- list()
selected_athletes <- c()

for (country in names(men_country_athlete_list_12)) {
  country_scores <- c()
  country_athlete_data <- men_country_athlete_list_12[[country]]
  selected_athlete <- country_athlete_data %>%
    group_by(FirstName) %>%
    summarize(total_score = sum(Score)) %>%
    arrange(-total_score) %>%
    slice(1) %>%
    pull(FirstName)
  
  selected_athletes <- c(selected_athletes, selected_athlete)
  
  for (apparatus in apparatus_list) {
    apparatus_data <- filter(country_athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- apparatus_data %>%
        group_by(FirstName) %>%
        summarize(average_score = mean(Score)) %>%
        arrange(-average_score) %>%
        slice(1:2) %>%
        pull(average_score)
      
      selected_score <- filter(country_athlete_data, FirstName == selected_athlete, Apparatus == apparatus) %>%
        pull(Score)
      
      top_3_scores <- c(top_2_athletes, selected_score)
      country_scores <- c(country_scores, mean(top_3_scores, na.rm = TRUE))
    }
  }
  
  men_qualifying_scores[[country]] <- country_scores
}

men_qualifying_df <- as.data.frame(do.call(rbind, men_qualifying_scores))
colnames(men_qualifying_df) <- apparatus_list
selected_athletes_df <- data.frame(Country = names(men_country_athlete_list_12), FirstName = selected_athletes)

# Compute the selected athletes' average score for each apparatus
selected_athletes_scores <- list()

for (athlete in selected_athletes_df$FirstName) {
  athlete_data <- filter(men_athletes_data, FirstName == athlete)
  athlete_scores <- c()
  
  for (apparatus in apparatuses) {
    apparatus_data <- filter(athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      athlete_scores <- c(athlete_scores, 10)
    } else {
      athlete_scores <- c(athlete_scores, mean(apparatus_data$Score, na.rm = TRUE))
    }
  }
  
  selected_athletes_scores[[athlete]] <- athlete_scores
}

selected_athletes_scores_df <- as.data.frame(do.call(rbind, selected_athletes_scores))
colnames(selected_athletes_scores_df) <- apparatuses
rownames(selected_athletes_scores_df) <- selected_athletes_df$FirstName
men_selected_athletes_df <- selected_athletes_scores_df

apparatus_list <- c('BB', 'FX', 'UE', 'VT')
women_qualifying_scores <- list()
selected_athletes <- c()

# Compute the selected athletes' average score for each apparatus
for (country in names(women_country_athlete_list_12)) {
  country_scores <- c()
  country_athlete_data <- women_country_athlete_list_12[[country]]
  selected_athlete <- country_athlete_data %>%
    group_by(FirstName) %>%
    summarize(total_score = sum(Score)) %>%
    arrange(-total_score) %>%
    slice(1) %>%
    pull(FirstName)
  
  selected_athletes <- c(selected_athletes, selected_athlete)
  
  for (apparatus in apparatus_list) {
    apparatus_data <- filter(country_athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- apparatus_data %>%
        group_by(FirstName) %>%
        summarize(average_score = mean(Score)) %>%
        arrange(-average_score) %>%
        slice(1:2) %>%
        pull(average_score)
      
      selected_score <- filter(country_athlete_data, FirstName == selected_athlete, Apparatus == apparatus) %>%
        pull(Score)
      
      top_3_scores <- c(top_2_athletes, selected_score)
      country_scores <- c(country_scores, mean(top_3_scores, na.rm = TRUE))
    }
  }
  
  women_qualifying_scores[[country]] <- country_scores
}

women_qualifying_df <- as.data.frame(do.call(rbind, women_qualifying_scores))
colnames(women_qualifying_df) <- apparatus_list
selected_athletes_df <- data.frame(Country = names(women_country_athlete_list_12), FirstName = selected_athletes)

# Compute the selected athletes' average score for each apparatus
selected_athletes_scores <- list()

for (athlete in selected_athletes_df$FirstName) {
  athlete_data <- filter(women_athletes_data, FirstName == athlete)
  athlete_scores <- c()
  
  for (apparatus in apparatus_list) {
    apparatus_data <- filter(athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      athlete_scores <- c(athlete_scores, 10)
    } else {
      athlete_scores <- c(athlete_scores, mean(apparatus_data$Score, na.rm = TRUE))
    }
  }
  
  selected_athletes_scores[[athlete]] <- athlete_scores
}

selected_athletes_scores_df <- as.data.frame(do.call(rbind, selected_athletes_scores))
colnames(selected_athletes_scores_df) <- apparatus_list
rownames(selected_athletes_scores_df) <- selected_athletes_df$FirstName
women_selected_athletes_df <- selected_athletes_scores_df

# Select the top 8 countries with the highest total score on all apparatuses for men and women, separately
men_total_scores <- rowSums(men_qualifying_df, na.rm = TRUE)
women_total_scores <- rowSums(women_qualifying_df, na.rm = TRUE)

top_8_men_countries <- names(sort(men_total_scores, decreasing = TRUE)[1:8])
top_8_women_countries <- names(sort(women_total_scores, decreasing = TRUE)[1:8])

# Create dataframes for the top 8 men's and women's countries with columns "Country", "Score", "Rank"
men_team_final_df <- data.frame(Country = top_8_men_countries, 
                                Score = men_total_scores[top_8_men_countries], 
                                Rank = 1:8)
women_team_final_df <- data.frame(Country = top_8_women_countries, 
                                  Score = women_total_scores[top_8_women_countries], 
                                  Rank = 1:8)

print("men's team final outcome:")
print(men_team_final_df)
print("women's team final outcome:")
print(women_team_final_df)


# Append a total score column
women_selected_athletes_df$TotalScore <- rowSums(women_selected_athletes_df[, c('BB', 'FX', 'UE', 'VT')], na.rm = TRUE)
men_selected_athletes_df$TotalScore <- rowSums(men_selected_athletes_df[, c('BB', 'FX', 'UE', 'VT', 'VT1', 'VT2')], na.rm = TRUE)

# Determine the men's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list_men <- c('BB', 'FX', 'UE', 'VT', 'VT1', 'VT2')
for (apparatus in apparatus_list_men) {
  men_selected_athletes_df[paste(apparatus, "Rank", sep = "")] <- as.integer(rank(-men_selected_athletes_df[[apparatus]], ties.method = "min"))
}

# Append a "TotalRank" column
men_selected_athletes_df$TotalRank <- as.integer(rank(-men_selected_athletes_df$TotalScore, ties.method = "min"))

print("men's individual final:")
print(men_selected_athletes_df)

# Determine the women's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list_women <- c('BB', 'FX', 'UE', 'VT')
for (apparatus in apparatus_list_women) {
  women_selected_athletes_df[paste(apparatus, "Rank", sep = "")] <- as.integer(rank(-women_selected_athletes_df[[apparatus]], ties.method = "min"))
}

# Append a "TotalRank" column
women_selected_athletes_df$TotalRank <- as.integer(rank(-women_selected_athletes_df$TotalScore, ties.method = "min"))

print("women's individual final:")
print(women_selected_athletes_df)

