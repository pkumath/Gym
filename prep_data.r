library(dplyr)
library(readr)

combined_data <- bind_rows(data_2017_2021, data_2022_2023)

# Create a full name column to use as the key for our dictionary
combined_data$FullName <- paste(combined_data$LastName, combined_data$FirstName)

# Convert the dataframe to a list where the key is the full name and the value is a list of records for that athlete
athlete_dict <- split(combined_data, combined_data$FullName)

# For example: athlete_dict[['ABDUL HADI']]
# Create a nested list structure: Gender -> Athlete Name -> Apparatus -> Records
nested_gender_athlete_dict <- list()

for(i in 1:nrow(combined_data)) {
  row <- combined_data[i, ]
  gender <- as.character(row$Gender)
  name <- as.character(row$FullName)
  apparatus <- as.character(row$Apparatus)
  
  if(!gender %in% names(nested_gender_athlete_dict)) {
    nested_gender_athlete_dict[[gender]] <- list()
  }
  
  if(!name %in% names(nested_gender_athlete_dict[[gender]])) {
    nested_gender_athlete_dict[[gender]][[name]] <- list()
  }
  
  if(!apparatus %in% names(nested_gender_athlete_dict[[gender]][[name]])) {
    nested_gender_athlete_dict[[gender]][[name]][[apparatus]] <- list()
  }
  
  nested_gender_athlete_dict[[gender]][[name]][[apparatus]] <- c(nested_gender_athlete_dict[[gender]][[name]][[apparatus]], list(row))
}

# Enhance the nested list with a summary section for each athlete under each gender
for(gender in names(nested_gender_athlete_dict)) {
  for(athlete in names(nested_gender_athlete_dict[[gender]])) {
    total_entries <- 0
    total_rank <- 0
    
    max_score <- -Inf
    min_score <- Inf
    max_score_apparatus <- ""
    min_score_apparatus <- ""
    max_score_rank <- NA
    min_score_rank <- NA
    
    best_rank <- Inf
    worst_rank <- -Inf
    best_rank_apparatus <- ""
    worst_rank_apparatus <- ""
    best_rank_score <- NA
    worst_rank_score <- NA
    
    for(apparatus in names(nested_gender_athlete_dict[[gender]][[athlete]])) {
      for(record in nested_gender_athlete_dict[[gender]][[athlete]][[apparatus]]) {
        if(!is.na(record$Score) && !is.na(record$Rank)) {
          total_entries <- total_entries + 1
          total_rank <- total_rank + as.numeric(record$Rank)
          
          if(as.numeric(record$Score) > max_score) {
            max_score <- as.numeric(record$Score)
            max_score_apparatus <- apparatus
            max_score_rank <- as.numeric(record$Rank)
          }
          
          if(as.numeric(record$Score) < min_score) {
            min_score <- as.numeric(record$Score)
            min_score_apparatus <- apparatus
            min_score_rank <- as.numeric(record$Rank)
          }
          
          if(as.numeric(record$Rank) < best_rank) {
            best_rank <- as.numeric(record$Rank)
            best_rank_apparatus <- apparatus
            best_rank_score <- as.numeric(record$Score)
          }
          
          if(as.numeric(record$Rank) > worst_rank) {
            worst_rank <- as.numeric(record$Rank)
            worst_rank_apparatus <- apparatus
            worst_rank_score <- as.numeric(record$Score)
          }
        }
      }
    }
    
    avg_rank <- total_rank / total_entries
    summary <- list(
      "Total Entries" = total_entries,
      "Average Rank" = avg_rank,
      "Max Score" = max_score,
      "Max Score Apparatus" = max_score_apparatus,
      "Max Score Rank" = max_score_rank,
      "Min Score" = min_score,
      "Min Score Apparatus" = min_score_apparatus,
      "Min Score Rank" = min_score_rank,
      "Best Rank" = best_rank,
      "Best Rank Apparatus" = best_rank_apparatus,
      "Best Rank Score" = best_rank_score,
      "Worst Rank" = worst_rank,
      "Worst Rank Apparatus" = worst_rank_apparatus,
      "Worst Rank Score" = worst_rank_score
    )
    
    nested_gender_athlete_dict[[gender]][[athlete]][["Summary"]] <- summary
  }
}

# Plot for Score Distribution by Gender
library(ggplot2)

ggplot(combined_data, aes(x = Apparatus, y = Score, fill = Apparatus)) +
  geom_boxplot() +
  labs(title = "Score Distribution by Apparatus", x = "Apparatus", y = "Score") +
  facet_wrap(~Gender, scales = "free", ncol = 1) + 
  theme_minimal()
