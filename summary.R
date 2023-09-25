# Read data from "data/data_2017_2021.csv" and "data/data_2022_2023.csv"
library(tidyverse)

# Read data
data_2017_2021 <- read_csv("data/data_2017_2021.csv")
data_2022_2023 <- read_csv("data/data_2022_2023.csv")

# For the "Apparatus" column, replace "VT_1", "VT_2" by "VT1", "VT2"
data_2022_2023$Apparatus <- str_replace_all(data_2022_2023$Apparatus, c("VT_1" = "VT1", "VT_2" = "VT2"))
# Filter out NaN in the "Score" column
data_2022_2023 <- data_2022_2023 %>% filter(!is.na(Score))

# Split data_2022_2023 by Gender
men_athletes_data <- data_2022_2023 %>% filter(Gender == "m")
women_athletes_data <- data_2022_2023 %>% filter(Gender == "w")

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_countries <- unique(men_athletes_data$Country)
men_country_athlete_dict <- list()
for (country in men_countries) {
  men_country_athlete_dict[[country]] <- men_athletes_data %>% filter(Country == country)
}

women_countries <- unique(women_athletes_data$Country)
women_country_athlete_dict <- list()
for (country in women_countries) {
  women_country_athlete_dict[[country]] <- women_athletes_data %>% filter(Country == country)
}

# For men_country_athlete_dict and women_country_athlete_dict, select the top 9 countries with most entries
# Select the top 9 countries with the most entries for both men and women
k <- 12
men_top_12_countries <- men_athletes_data %>% count(Country) %>% top_n(k, n) %>% pull(Country)
women_top_12_countries <- women_athletes_data %>% count(Country) %>% top_n(k, n) %>% pull(Country)
# Filter the men_country_athlete_dict and women_country_athlete_dict by the top 9 countries
men_country_athlete_dict_12 <- men_country_athlete_dict %>% keep(names(.) %in% men_top_12_countries)
women_country_athlete_dict_12 <- women_country_athlete_dict %>% keep(names(.) %in% women_top_12_countries)

# Determine a 5-person team for each country based on the top 5 athletes who appear most frequently, and split the data for each country based on the selected athletes
for (country in names(men_country_athlete_dict_12)) {
  top_5_athletes <- men_country_athlete_dict_12[[country]] %>% count(FirstName) %>% top_n(5, n) %>% pull(FirstName)
  men_country_athlete_dict_12[[country]] <- men_country_athlete_dict_12[[country]] %>% filter(FirstName %in% top_5_athletes)
}
for (country in names(women_country_athlete_dict_12)) {
  top_5_athletes <- women_country_athlete_dict_12[[country]] %>% count(FirstName) %>% top_n(5, n) %>% pull(FirstName)
  women_country_athlete_dict_12[[country]] <- women_country_athlete_dict_12[[country]] %>% filter(FirstName %in% top_5_athletes)
}

# For each country, each athlete, group the data by "Apparatus" and calculate the average score of each apparatus, then replace the original data with the new data (average score)
for (country in names(men_country_athlete_dict_12)) {
  for (athlete in unique(men_country_athlete_dict_12[[country]]$FirstName)) {
    athlete_data <- men_country_athlete_dict_12[[country]] %>% filter(FirstName == athlete)
    apparatus_scores <- athlete_data %>% group_by(Apparatus) %>% summarize(Score = mean(Score))
    for (apparatus in apparatus_scores$Apparatus) {
      men_country_athlete_dict_12[[country]]$Score[men_country_athlete_dict_12[[country]]$FirstName == athlete & men_country_athlete_dict_12[[country]]$Apparatus == apparatus] <- apparatus_scores$Score[apparatus_scores$Apparatus == apparatus]
    }
    men_country_athlete_dict_12[[country]] <- men_country_athlete_dict_12[[country]] %>% distinct(FirstName, Apparatus, .keep_all = TRUE)
  }
}
for (country in names(women_country_athlete_dict_12)) {
  for (athlete in unique(women_country_athlete_dict_12[[country]]$FirstName)) {
    athlete_data <- women_country_athlete_dict_12[[country]] %>% filter(FirstName == athlete)
    apparatus_scores <- athlete_data %>% group_by(Apparatus) %>% summarize(Score = mean(Score))
    for (apparatus in apparatus_scores$Apparatus) {
      women_country_athlete_dict_12[[country]]$Score[women_country_athlete_dict_12[[country]]$FirstName == athlete & women_country_athlete_dict_12[[country]]$Apparatus == apparatus] <- apparatus_scores$Score[apparatus_scores$Apparatus == apparatus]
    }
    women_country_athlete_dict_12[[country]] <- women_country_athlete_dict_12[[country]] %>% distinct(FirstName, Apparatus, .keep_all = TRUE)
  }
}

# identify all apparatuses
apparatuses <- unique(data_2017_2021$Apparatus)


# The men's qualifying stage, for each country, first select an athlete to compete on all apparatus. Then, for each apparatus, select the top 2 athletes with the highest score and calculate the average score of the these 3 athletes. If the apparatus's total entry is less than 3, then the total score is the average of this apparatus's entries. If the apparatus's total entry is 0, then the total score is 10.
# The apparatus list is ["FX", "PH", "SR", "VT", "PB", "HB"]
# Also return the selected athletes that compete on all apparatuses

apparatus_list <- c("FX", "PH", "SR", "VT", "PB", "HB")
men_qualifying_scores <- list()
selected_athletes <- c()

for (country in names(men_country_athlete_dict_12)) {
  country_scores <- c()
  country_athlete_data <- men_country_athlete_dict_12[[country]]
  selected_athlete <- names(sort(tapply(country_athlete_data$Score, country_athlete_data$FirstName, sum), decreasing=TRUE)[1])
  selected_athletes <- c(selected_athletes, selected_athlete)
  for (apparatus in apparatus_list) {
    apparatus_data <- country_athlete_data[country_athlete_data$Apparatus == apparatus,]
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- tapply(apparatus_data$Score, apparatus_data$FirstName, mean)
      top_2_athletes <- sort(top_2_athletes, decreasing=TRUE)[1:2]
      top_3_athletes <- c(top_2_athletes, country_athlete_data[country_athlete_data$FirstName == selected_athlete & country_athlete_data$Apparatus == apparatus, "Score"])
      if (length(top_3_athletes) < 3) {
        country_scores <- c(country_scores, mean(top_3_athletes))
      } else {
        country_scores <- c(country_scores, mean(top_3_athletes))
      }
    }
  }
  men_qualifying_scores[[country]] <- country_scores
}

men_qualifying_df <- data.frame(men_qualifying_scores, row.names=names(men_country_athlete_dict_12))
selected_athletes_df <- data.frame(Country=names(men_country_athlete_dict_12), FirstName=selected_athletes)

# compute the selected athletes' average score for each apparatus
selected_athletes_scores <- list()
for (athlete in selected_athletes_df$FirstName) {
  athlete_data <- men_athletes_data[men_athletes_data$FirstName == athlete,]
  athlete_scores <- c()
  for (apparatus in apparatuses) {
    apparatus_data <- athlete_data[athlete_data$Apparatus == apparatus,]
    if (nrow(apparatus_data) == 0) {
      athlete_scores <- c(athlete_scores, 10)
    } else {
      athlete_scores <- c(athlete_scores, mean(apparatus_data$Score))
    }
  }
  selected_athletes_scores[[athlete]] <- athlete_scores
}

selected_athletes_scores_df <- data.frame(selected_athletes_scores, row.names=selected_athletes_df$FirstName)
colnames(selected_athletes_scores_df) <- apparatuses
men_selected_athletes_df <- selected_athletes_scores_df

apparatus_list <- c('BB', 'FX', 'UE', 'VT')
women_qualifying_scores <- list()
selected_athletes <- c()

for (country in names(women_country_athlete_dict_12)) {
  country_scores <- c()
  country_athlete_data <- women_country_athlete_dict_12[[country]]
  selected_athlete <- names(sort(tapply(country_athlete_data$Score, country_athlete_data$FirstName, sum), decreasing=TRUE)[1])
  selected_athletes <- c(selected_athletes, selected_athlete)
  for (apparatus in apparatus_list) {
    apparatus_data <- country_athlete_data[country_athlete_data$Apparatus == apparatus,]
    if (nrow(apparatus_data) == 0) {
      country_scores <- c(country_scores, 10)
    } else {
      top_2_athletes <- tapply(apparatus_data$Score, apparatus_data$FirstName, mean)
      top_2_athletes <- sort(top_2_athletes, decreasing=TRUE)[1:2]
      top_3_athletes <- c(top_2_athletes, country_athlete_data[country_athlete_data$FirstName == selected_athlete & country_athlete_data$Apparatus == apparatus, "Score"])
      if (length(top_3_athletes) < 3) {
        country_scores <- c(country_scores, mean(top_3_athletes))
      } else {
        country_scores <- c(country_scores, mean(top_3_athletes))
      }
    }
  }
  women_qualifying_scores[[country]] <- country_scores
}

women_qualifying_df <- data.frame(women_qualifying_scores, row.names=names(women_country_athlete_dict_12))
selected_athletes_df <- data.frame(Country=names(women_country_athlete_dict_12), FirstName=selected_athletes)

# compute the selected athletes' average score for each apparatuses
selected_athletes_scores <- list()
for (athlete in selected_athletes_df$FirstName) {
  athlete_data <- women_athletes_data[women_athletes_data$FirstName == athlete,]
  athlete_scores <- c()
  for (apparatus in apparatus_list) {
    apparatus_data <- athlete_data[athlete_data$Apparatus == apparatus,]
    if (nrow(apparatus_data) == 0) {
      athlete_scores <- c(athlete_scores, 10)
    } else {
      athlete_scores <- c(athlete_scores, mean(apparatus_data$Score))
    }
  }
  selected_athletes_scores[[athlete]] <- athlete_scores
}

selected_athletes_scores_df <- data.frame(selected_athletes_scores, row.names=selected_athletes_df$FirstName)
colnames(selected_athletes_scores_df) <- apparatus_list
women_selected_athletes_df <- selected_athletes_scores_df

# select the top 8 countries with the highest total score on all apparatuses for men and women, separately
men_total_scores <- rowSums(men_qualifying_df)
women_total_scores <- rowSums(women_qualifying_df)

top_8_men_countries <- names(sort(men_total_scores, decreasing=TRUE)[1:8])
top_8_women_countries <- names(sort(women_total_scores, decreasing=TRUE)[1:8])

# Now for the team final, we just sort the top 8 countries by their total score on all apparatuses, for men and women separately, and arrange them in dataframes with columns "Country", "Score", "Rank"
# Create dataframes for the top 8 men's and women's countries with columns "Country", "Score", "Rank"
men_team_final_df <- data.frame(Country=top_8_men_countries, Score=men_total_scores[top_8_men_countries], Rank=1:8)
women_team_final_df <- data.frame(Country=top_8_women_countries, Score=women_total_scores[top_8_women_countries], Rank=1:8)

print("men's team final outcome:", men_team_final_df)
print("women's team final outcome:", women_team_final_df)

# Combine women_selected_athletes_df and men_selected_athletes_df into a single dataframe and give and rank based on AverageScore
# selected_athletes_df <- rbind(women_selected_athletes_df, men_selected_athletes_df)
# selected_athletes_df$Rank <- dense_rank(-selected_athletes_df$AverageScore)
# print("individual final", selected_athletes_df)
women_selected_athletes_df
men_selected_athletes_df

# append a total score column
women_selected_athletes_df$TotalScore <- rowSums(women_selected_athletes_df[,c('BB', 'FX', 'UE', 'VT')])
men_selected_athletes_df$TotalScore <- rowSums(men_selected_athletes_df[,c('BB', 'FX', 'UE', 'VT', 'VT1', 'VT2')])

# determine the men's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list <- c('BB', 'FX', 'UE', 'VT', 'VT1', 'VT2')
for (apparatus in apparatus_list) {
  # append a "Rank" column for each apparatus
  men_selected_athletes_df[paste0(apparatus, "Rank")] <- dense_rank(-men_selected_athletes_df[,apparatus])
}
# append a "TotalRank" column
men_selected_athletes_df$TotalRank <- dense_rank(-men_selected_athletes_df$TotalScore)
print("men's individual final:", men_selected_athletes_df)

# determine the women's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list <- c('BB', 'FX', 'UE', 'VT')
for (apparatus in apparatus_list) {
  women_selected_athletes_df[paste0(apparatus, "Rank")] <- dense_rank(-women_selected_athletes_df[,apparatus])
}

# append a "TotalRank" column
women_selected_athletes_df$TotalRank <- dense_rank(-women_selected_athletes_df$TotalScore)

print("women's individual final:", women_selected_athletes_df)