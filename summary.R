# Ruixiao Wang: summarize the rule and come up with the plan, basis framework for the codes
# Gang Wen: Determine the random sets of atheletes and clean the data
# Siyu Chen: Simulation Implementation and Evalution Design

# Read data from "data/data_2017_2021.csv" and "data/data_2022_2023.csv"
library(tidyverse)
library(dplyr)

# Read data
data_2017_2021 <- read_csv("data/data_2017_2021.csv")
data_2022_2023 <- read_csv("data/data_2022_2023.csv")

# For the "Apparatus" column, replace "VT_1", "VT_2" by "VT1", "VT2"
data_2022_2023$Apparatus <- str_replace_all(data_2022_2023$Apparatus, c("VT_1" = "VT1", "VT_2" = "VT2", "hb" = "HB"))
# Filter out NaN in the "Score" column
data_2022_2023 <- filter(data_2022_2023, !is.na(Score))

# Split data_2022_2023 by Gender
men_athletes_data <- filter(data_2022_2023, Gender == "m")
women_athletes_data <- filter(data_2022_2023, Gender == "w")

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_countries <- unique(men_athletes_data$Country)
men_country_athlete_dict <- split(men_athletes_data, men_athletes_data$Country)

women_countries <- unique(women_athletes_data$Country)
women_country_athlete_dict <- split(women_athletes_data, women_athletes_data$Country)

# For men_country_athlete_dict and women_country_athlete_dict, select the top 12 countries with most entries
k <- 12
men_top_12_countries <- names(sort(table(men_athletes_data$Country), decreasing = TRUE)[1:k])
women_top_12_countries <- names(sort(table(women_athletes_data$Country), decreasing = TRUE)[1:k])

# Filter the men_country_athlete_dict and women_country_athlete_dict by the top 12 countries
men_country_athlete_dict_12 <- men_country_athlete_dict[men_top_12_countries]
women_country_athlete_dict_12 <- women_country_athlete_dict[women_top_12_countries]

# Determine a 5-person team for each country based on the top 5 athletes who appear most frequently, and split the data for each country based on the selected athletes
for (country in names(men_country_athlete_dict_12)) {
  top_5_athletes <- names(sort(table(men_country_athlete_dict_12[[country]]$FirstName), decreasing = TRUE)[1:5])
  men_country_athlete_dict_12[[country]] <- filter(men_country_athlete_dict_12[[country]], FirstName %in% top_5_athletes)
}

for (country in names(women_country_athlete_dict_12)) {
  top_5_athletes <- names(sort(table(women_country_athlete_dict_12[[country]]$FirstName), decreasing = TRUE)[1:5])
  women_country_athlete_dict_12[[country]] <- filter(women_country_athlete_dict_12[[country]], FirstName %in% top_5_athletes)
}

# For each country, each athlete, group the data by "Apparatus" and calculate the average score of each apparatus, then replace the original data with the new data (average score)
for (country in names(men_country_athlete_dict_12)) {
  for (athlete in unique(men_country_athlete_dict_12[[country]]$FirstName)) {
    athlete_data <- filter(men_country_athlete_dict_12[[country]], FirstName == athlete)
    apparatus_scores <- athlete_data %>% group_by(Apparatus) %>% summarize(Score = mean(Score, na.rm = TRUE))
    for (i in 1:nrow(apparatus_scores)) {
      apparatus <- apparatus_scores$Apparatus[i]
      score <- apparatus_scores$Score[i]
      men_country_athlete_dict_12[[country]]$Score[men_country_athlete_dict_12[[country]]$FirstName == athlete & men_country_athlete_dict_12[[country]]$Apparatus == apparatus] <- score
    }
    men_country_athlete_dict_12[[country]] <- distinct(men_country_athlete_dict_12[[country]], FirstName, Apparatus, .keep_all = TRUE)
  }
}

for (country in names(women_country_athlete_dict_12)) {
  for (athlete in unique(women_country_athlete_dict_12[[country]]$FirstName)) {
    athlete_data <- filter(women_country_athlete_dict_12[[country]], FirstName == athlete)
    apparatus_scores <- athlete_data %>% group_by(Apparatus) %>% summarize(Score = mean(Score, na.rm = TRUE))
    for (i in 1:nrow(apparatus_scores)) {
      apparatus <- apparatus_scores$Apparatus[i]
      score <- apparatus_scores$Score[i]
      women_country_athlete_dict_12[[country]]$Score[women_country_athlete_dict_12[[country]]$FirstName == athlete & women_country_athlete_dict_12[[country]]$Apparatus == apparatus] <- score
    }
    women_country_athlete_dict_12[[country]] <- distinct(women_country_athlete_dict_12[[country]], FirstName, Apparatus, .keep_all = TRUE)
  }
}

# identify all apparatuses
apparatuses <- unique(data_2022_2023$Apparatus)
men_apparatuses <- unique(men_athletes_data$Apparatus)
women_apparatuses <- unique(women_athletes_data$Apparatus)

qual_men_apparatuses <- c('HB', 'PH', 'FX', 'PB', 'SR', 'VT')
qual_women_apparatuses <- c('BB', 'FX', 'UB', 'VT')

# Compute qualifying scores for men
apparatus_list <- qual_men_apparatuses
men_qualifying_scores <- list()
selected_athletes <- list()

for (country in names(men_country_athlete_dict_12)) {
  country_scores <- c()
  country_athlete_data <- men_country_athlete_dict_12[[country]]
  selected_athlete <- names(sort(tapply(country_athlete_data$Score, country_athlete_data$FirstName, sum), decreasing = TRUE)[1])[1]
  selected_athletes <- c(selected_athletes, selected_athlete)
  for (apparatus in apparatus_list) {
    apparatus_data <- filter(country_athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- sort(tapply(apparatus_data$Score, apparatus_data$FirstName, mean), decreasing = TRUE)[1:2]
      top_3_athletes <- c(top_2_athletes, mean(filter(country_athlete_data, FirstName == selected_athlete & Apparatus == apparatus)$Score))
      if (length(top_3_athletes) < 3) {
        country_scores <- c(country_scores, mean(top_3_athletes, na.rm = TRUE))
      } else {
        country_scores <- c(country_scores, mean(top_3_athletes, na.rm = TRUE))
      }
    }
  }
  men_qualifying_scores[[country]] <- country_scores
}

men_qualifying_df <- as.data.frame(do.call(rbind, men_qualifying_scores))
rownames(men_qualifying_df) <- names(men_qualifying_scores)
colnames(men_qualifying_df) <- apparatus_list

# Compute qualifying scores for women
apparatus_list <- qual_women_apparatuses
women_qualifying_scores <- list()
selected_athletes_w <- list()

for (country in names(women_country_athlete_dict_12)) {
  country_scores <- c()
  country_athlete_data <- women_country_athlete_dict_12[[country]]
  selected_athlete <- names(sort(tapply(country_athlete_data$Score, country_athlete_data$FirstName, sum), decreasing = TRUE)[1])[1]
  selected_athletes_w <- c(selected_athletes_w, selected_athlete)
  for (apparatus in apparatus_list) {
    apparatus_data <- filter(country_athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- sort(tapply(apparatus_data$Score, apparatus_data$FirstName, mean), decreasing = TRUE)[1:2]
      top_3_athletes <- c(top_2_athletes, mean(filter(country_athlete_data, FirstName == selected_athlete & Apparatus == apparatus)$Score))
      if (length(top_3_athletes) < 3) {
        country_scores <- c(country_scores, mean(top_3_athletes, na.rm = TRUE))
      } else {
        country_scores <- c(country_scores, mean(top_3_athletes, na.rm = TRUE))
      }
    }
  }
  women_qualifying_scores[[country]] <- country_scores
}

women_qualifying_df <- as.data.frame(do.call(rbind, women_qualifying_scores))
rownames(women_qualifying_df) <- names(women_qualifying_scores)
colnames(women_qualifying_df) <- apparatus_list

# select the top 8 countries with the highest total score on all apparatuses for men and women, separately
men_total_scores <- rowSums(men_qualifying_df, na.rm = TRUE)
women_total_scores <- rowSums(women_qualifying_df, na.rm = TRUE)

top_8_men_countries <- names(sort(men_total_scores, decreasing = TRUE)[1:8])
top_8_women_countries <- names(sort(women_total_scores, decreasing = TRUE)[1:8])

# Now for the team final, we just sort the top 8 countries by their total score on all apparatuses, for men and women separately, and arrange them in dataframes with columns "Country", "Score", "Rank"
men_team_final_df <- data.frame(Country = top_8_men_countries, Score = men_total_scores[top_8_men_countries])
men_team_final_df$Rank <- rank(-men_team_final_df$Score, ties.method = "min")
women_team_final_df <- data.frame(Country = top_8_women_countries, Score = women_total_scores[top_8_women_countries])
women_team_final_df$Rank <- rank(-women_team_final_df$Score, ties.method = "min")

print("men's team final outcome:")
print(men_team_final_df)
print("women's team final outcome:")
print(women_team_final_df)

# Individual Finals
# Men
men_selected_athletes_df <- data.frame(FirstName = selected_athletes)
for (apparatus in qual_men_apparatuses) {
  scores <- c()
  for (athlete in selected_athletes) {
    athlete_data <- filter(men_athletes_data, FirstName == athlete)
    apparatus_data <- filter(athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      scores <- c(scores, 10)
    } else {
      scores <- c(scores, mean(apparatus_data$Score, na.rm = TRUE))
    }
  }
  men_selected_athletes_df[[apparatus]] <- scores
}

# Women
women_selected_athletes_df <- data.frame(FirstName = selected_athletes_w)
for (apparatus in qual_women_apparatuses) {
  scores <- c()
  for (athlete in selected_athletes_w) {
    athlete_data <- filter(women_athletes_data, FirstName == athlete)
    apparatus_data <- filter(athlete_data, Apparatus == apparatus)
    if (nrow(apparatus_data) == 0) {
      scores <- c(scores, 10)
    } else {
      scores <- c(scores, mean(apparatus_data$Score, na.rm = TRUE))
    }
  }
  women_selected_athletes_df[[apparatus]] <- scores
}

# Append total score and ranking
men_selected_athletes_df$TotalScore <- rowSums(men_selected_athletes_df[qual_men_apparatuses], na.rm = TRUE)
women_selected_athletes_df$TotalScore <- rowSums(women_selected_athletes_df[qual_women_apparatuses], na.rm = TRUE)

for (apparatus in qual_men_apparatuses) {
  men_selected_athletes_df[[paste0(apparatus, "Rank")]] <- rank(-men_selected_athletes_df[[apparatus]], ties.method = "min")
}

for (apparatus in qual_women_apparatuses) {
  women_selected_athletes_df[[paste0(apparatus, "Rank")]] <- rank(-women_selected_athletes_df[[apparatus]], ties.method = "min")
}

men_selected_athletes_df$TotalRank <- rank(-men_selected_athletes_df$TotalScore, ties.method = "min")
women_selected_athletes_df$TotalRank <- rank(-women_selected_athletes_df$TotalScore, ties.method = "min")

print("men's individual final:")
print(men_selected_athletes_df)

print("women's individual final:")
print(women_selected_athletes_df)
