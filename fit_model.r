final_selections <- list("m" = list(), "w" = list())

# For each gender
for (gender in names(nested_gender_athlete_dict)) {
  
  apparatuses <- unique(unlist(lapply(nested_gender_athlete_dict[[gender]], function(x) names(x)), recursive = FALSE))
  apparatuses <- setdiff(apparatuses, "Summary")  # Remove the 'Summary' entry
  
  # For each apparatus
  for (apparatus in apparatuses) {
    
    scores <- c()  # To store the best scores of each athlete for this apparatus
    ranks <- c()  # To store the corresponding ranks for the best scores
    athlete_names <- c()  # To store the athlete names
    
    # For each athlete
    for (athlete_name in names(nested_gender_athlete_dict[[gender]])) {
      athlete_data <- nested_gender_athlete_dict[[gender]][[athlete_name]]
      if (!is.null(athlete_data[[apparatus]])) {
        # Find the best score for this athlete for this apparatus
        best_score <- max(unlist(lapply(athlete_data[[apparatus]], function(x) x$Score)))
        corresponding_rank <- unlist(lapply(athlete_data[[apparatus]], function(x) ifelse(x$Score == best_score, x$Rank, NA)))
        corresponding_rank <- corresponding_rank[!is.na(corresponding_rank)]
        
        scores <- c(scores, best_score)
        ranks <- c(ranks, corresponding_rank[1])
        athlete_names <- c(athlete_names, athlete_name)
      }
    }
    
    # Combine the data
    df <- data.frame(Name = athlete_names, Score = scores, Rank = ranks)
    
    # Find top 5 athletes based on score and rank
    final_selections[[gender]][[apparatus]] <- list(
      Top5Score = df[order(-df$Score), ][1:5, ],
      Top5Rank = df[order(df$Rank), ][1:5, ]
    )
  }
  
  # For average score and rank
  avg_scores <- c()
  avg_ranks <- c()
  
  for (athlete_name in names(nested_gender_athlete_dict[[gender]])) {
    avg_scores <- c(avg_scores, (nested_gender_athlete_dict[[gender]][[athlete_name]]$Summary$`Max Score` + nested_gender_athlete_dict[[gender]][[athlete_name]]$Summary$`Min Score`) / 2)
    avg_ranks <- c(avg_ranks, nested_gender_athlete_dict[[gender]][[athlete_name]]$Summary$`Average Rank`)
  }
  
  avg_df <- data.frame(Name = names(nested_gender_athlete_dict[[gender]]), AvgScore = avg_scores, AvgRank = avg_ranks)
  final_selections[[gender]]$Top5AvgScore <- avg_df[order(-avg_df$AvgScore), ][1:5, ]
  final_selections[[gender]]$Top5AvgRank <- avg_df[order(avg_df$AvgRank), ][1:5, ]
}

final_selections
