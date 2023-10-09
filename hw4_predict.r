
data_prep <- function(Load_data = TRUE) {
  
  if (Load_data) {
    data <- Gymnastic_Data_Analyst$new(load_dir = "data/formatted_data/")
  } else {
    data <- Gymnastic_Data_Analyst$new(data_dir = "data/data_2022_2023.csv", data_name = "gymnasts")
    data$save_all_data("data/formatted_data/")
  }
  
  summary_data <- data$summary_for_each_country_by_gender(data_name="summary_men_gymnasts", country_name="COL", k_top_for_apparatus=5, k_top_for_score=2)
  write(as.character(summary_data), file="data/summary_data.txt")
  
  num_of_gymnasts <- table(data$data$gymnasts$Country)
  sorted_num_of_gymnasts <- sort(num_of_gymnasts, decreasing = TRUE)
  top_24_countries <- names(sorted_num_of_gymnasts)[1:24]
  men_countries <- top_24_countries[1:12]
  women_countries <- top_24_countries[1:12]
  
  qual_men_12_team <- list()
  qual_women_12_team <- list()
  max_num_of_gymnasts_men = 5
  max_num_of_gymnasts_women = 5
  
  for (men_country in men_countries) {
    summary_data_for_country <- data$summary_for_each_country_by_gender(data_name="summary_men_gymnasts", country_name=men_country, k_top_for_apparatus=5, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts_men)
    
    matrix <- matrix(0, nrow=max_num_of_gymnasts_men, ncol=length(data$men_apparatus_ls))
    random_index <- sample(1:max_num_of_gymnasts_men, 1)
    matrix[random_index, ] <- 1
    
    gymnast_index_list <- setdiff(1:max_num_of_gymnasts_men, random_index)
    for (i in 1:length(data$men_apparatus_ls)) {
      ones_indices <- sample(gymnast_index_list, 3)
      matrix[ones_indices, i] <- 1
    }
    for (j in 1:length(data$men_apparatus_ls)) {
      summary_data_for_country[[men_country]]$data[paste(data$men_apparatus_ls[j], "_qual_participation", sep="")] <- matrix[, j]
    }
    summary_data_for_country[[men_country]]$qual_participation <- matrix
    qual_men_12_team <- append(qual_men_12_team, summary_data_for_country)
  }
  
  for (women_country in women_countries) {
    summary_data_for_country <- data$summary_for_each_country_by_gender(data_name="summary_women_gymnasts", country_name=women_country, k_top_for_apparatus=5, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts_women)
    
    matrix <- matrix(0, nrow=max_num_of_gymnasts_women, ncol=length(data$women_apparatus_ls))
    random_index <- sample(1:max_num_of_gymnasts_women, 1)
    matrix[random_index, ] <- 1
    
    gymnast_index_list <- setdiff(1:max_num_of_gymnasts_women, random_index)
    for (i in 1:length(data$women_apparatus_ls)) {
      ones_indices <- sample(gymnast_index_list, 3)
      matrix[ones_indices, i] <- 1
    }
    for (j in 1:length(data$women_apparatus_ls)) {
      summary_data_for_country[[women_country]]$data[paste(data$women_apparatus_ls[j], "_qual_participation", sep="")] <- matrix[, j]
    }
    summary_data_for_country[[women_country]]$qual_participation <- matrix
    qual_women_12_team <- append(qual_women_12_team, summary_data_for_country)
  }
  
  men_countries_12 <- top_24_countries[13:24]
  women_countries_12 <- top_24_countries[13:24]
  qual_men_36_team <- list()
  qual_women_36_team <- list()
  max_num_of_gymnasts_men = 3
  max_num_of_gymnasts_women = 3
  
  for (men_country in men_countries_12) {
    summary_data_for_country <- data$summary_for_each_country_by_gender(data_name="summary_men_gymnasts", country_name=men_country, k_top_for_apparatus=4, k_top_for_score=3, max_num_of_gymnasts=max_num_of_gymnasts_men)
    
    matrix <- matrix(sample(c(0,1), max_num_of_gymnasts_men*length(data$men_apparatus_ls), replace=TRUE), nrow=max_num_of_gymnasts_men)
    random_index <- sample(1:max_num_of_gymnasts_men, 1)
    matrix[random_index, ] <- 1
    for (j in 1:length(data$men_apparatus_ls)) {
      summary_data_for_country[[men_country]]$data[paste(data$men_apparatus_ls[j], "_qual_participation", sep="")] <- matrix[, j]
    }
    summary_data_for_country[[men_country]]$qual_participation <- matrix
    qual_men_36_team <- append(qual_men_36_team, summary_data_for_country)
  }

  for (women_country in women_countries_12) {
    summary_data_for_country <- data$summary_for_each_country_by_gender(data_name="summary_women_gymnasts", country_name=women_country, k_top_for_apparatus=4, k_top_for_score=3, max_num_of_gymnasts=max_num_of_gymnasts_women)
    
    matrix <- matrix(sample(c(0,1), max_num_of_gymnasts_women*length(data$women_apparatus_ls), replace=TRUE), nrow=max_num_of_gymnasts_women)
    random_index <- sample(1:max_num_of_gymnasts_women, 1)
    matrix[random_index, ] <- 1
    for (j in 1:length(data$women_apparatus_ls)) {
      summary_data_for_country[[women_country]]$data[paste(data$women_apparatus_ls[j], "_qual_participation", sep="")] <- matrix[, j]
    }
    summary_data_for_country[[women_country]]$qual_participation <- matrix
    qual_women_36_team <- append(qual_women_36_team, summary_data_for_country)
  }
  
  return(list(data, qual_men_12_team, qual_men_36_team, qual_women_12_team, qual_women_36_team))
}

qual_result_36_country_all_around_helper <- function(qual_participation_matrix, qual_apparatus_score_matrix) {
  rows_with_ones <- apply(qual_participation_matrix, 1, all)
  total_score <- rowSums(qual_apparatus_score_matrix[rows_with_ones,])
  indices <- which(rows_with_ones)
  individual_all_around_qual_score <- setNames(total_score, indices)
  return(individual_all_around_qual_score)
}

qual_result_36_country_all_around <- function(team_36, apparatus_ls) {
  individual_all_around_result <- list()
  for (country_name in names(team_36)) {
    team_36[[country_name]]$individual_all_around_qual_score <- list()
    qual_participation_matrix <- team_36[[country_name]]$qual_participation
    qual_apparatus_score_matrix <- sapply(apparatus_ls, function(apparatus) {
      team_36[[country_name]][[apparatus]]$apparatus_name_score
    })
    qual_apparatus_score_matrix <- replace_na(t(qual_apparatus_score_matrix), 0)
    individual_all_around_qual_score <- qual_result_36_country_all_around_helper(qual_participation_matrix, qual_apparatus_score_matrix)
    individual_all_around_result <- c(individual_all_around_result, setNames(list(individual_all_around_qual_score), country_name))
    team_36[[country_name]]$individual_all_around_qual_score <- individual_all_around_qual_score
  }
  return(individual_all_around_result)
}

qual_result_12_country_all_around <- function(qual_participation_matrix, qual_apparatus_score_matrix) {
  qual_score_matrix <- qual_participation_matrix * qual_apparatus_score_matrix
  top_3_values <- apply(qual_score_matrix, 2, function(column) -sort(-column)[1:3])
  top_3_indices <- t(apply(qual_score_matrix, 2, function(column) order(-column)[1:3]))
  
  team_all_around_binary_matrix <- matrix(0, nrow=nrow(qual_score_matrix), ncol=ncol(qual_score_matrix))
  for (i in 1:ncol(qual_score_matrix)) {
    team_all_around_binary_matrix[top_3_indices[,i], i] <- 1
  }
  team_all_around_qual_score <- sum(top_3_values)
  
  rows_with_ones <- apply(qual_participation_matrix, 1, all)
  total_score <- rowSums(qual_apparatus_score_matrix[rows_with_ones,])
  indices <- which(rows_with_ones)
  individual_all_around_qual_score <- setNames(total_score, indices)
  
  return(list(team_all_around_qual_score = team_all_around_qual_score,
              team_all_around_binary_matrix = team_all_around_binary_matrix,
              individual_all_around_qual_score = individual_all_around_qual_score))
}

all_around_result <- function(teams, apparatus_ls) {
  
  team_12_all_around_result <- list()
  individual_all_around_result <- list()
  
  team_12 <- teams[[1]]
  team_36 <- teams[[2]]
  
  for (country_name in names(team_12)) {
    qual_participation_matrix <- team_12[[country_name]]$qual_participation
    qual_apparatus_score_matrix <- sapply(apparatus_ls, function(apparatus) {
      team_12[[country_name]][[apparatus]]$apparatus_name_score
    })
    qual_apparatus_score_matrix <- replace_na(t(qual_apparatus_score_matrix), 0)
    list_results <- qual_result_12_country_all_around(qual_participation_matrix, qual_apparatus_score_matrix)
    
    team_12[[country_name]]$sum_top_3_values <- list_results[[1]]
    team_12[[country_name]]$team_12_all_around_binary_matrix <- list_results[[2]]
    team_12[[country_name]]$individual_all_around_qual_score <- list_results[[3]]
    team_12[[country_name]]$qual_team_12_all_around_score <- qual_apparatus_score_matrix
    team_12_all_around_result[[country_name]] <- list_results[[1]]
    for (idx in names(list_results[[3]])) {
      individual_all_around_result[paste(country_name, idx, sep = "_")] <- list_results[[3]][[idx]]
    }
  }
  
  team_all_around_sorted_countries <- sort(team_12_all_around_result, decreasing = TRUE)
  top_8_countries <- names(team_all_around_sorted_countries)[1:8]
  
  team_36_individual_all_around <- qual_result_36_country_all_around(team_36, apparatus_ls)
  individual_all_around_result <- c(individual_all_around_result, team_36_individual_all_around)
  sorted_athletes <- sort(individual_all_around_result, decreasing = TRUE)
  
  # Select top 24 with no more than 2 athletes from the same country
  top_24_athletes <- list()
  country_count <- table(rep(0, length(unique(names(sorted_athletes)))))
  for (athlete in names(sorted_athletes)) {
    country <- unlist(strsplit(athlete, "_"))[1]
    if (country_count[country] < 2) {
      top_24_athletes[athlete] <- sorted_athletes[athlete]
      country_count[country] <- country_count[country] + 1
    }
    if (length(top_24_athletes) == 24) break
  }
  
  individual_all_around_top_24_athletes <- sort(top_24_athletes, decreasing = TRUE)
  
  return(list(team_all_around_sorted_countries, top_8_countries, individual_all_around_top_24_athletes, names(individual_all_around_top_24_athletes)))
}

predict <- function(apparatus, dict_of_qual_result) {
  sorted_athletes <- sort(dict_of_qual_result, decreasing = TRUE)
  
  # Select top 8 with no more than 2 athletes from the same country
  top_8_athletes <- list()
  country_count <- table(rep(0, length(unique(names(sorted_athletes)))))
  for (athlete in names(sorted_athletes)) {
    country <- unlist(strsplit(athlete, "_"))[1]
    if (country_count[country] < 2) {
      top_8_athletes[athlete] <- sorted_athletes[athlete]
      country_count[country] <- country_count[country] + 1
    }
    if (length(top_8_athletes) == 8) break
  }
  
  dict_of_final_result <- sapply(top_8_athletes, function(x) x + rnorm(1))
  sorted_athletes_final <- sort(dict_of_final_result, decreasing = TRUE)
  top_3_athletes <- names(sorted_athletes_final)[1:3]
  
  return(list(top_8_athletes, sorted_athletes, top_3_athletes, sorted_athletes_final))
}

each_apparatus_result <- function(teams, apparatus_ls) {
  
  team_12_all_around_result <- list()
  individual_all_around_result <- list()
  apparatus_ls_dict <- vector("list", length(apparatus_ls))
  names(apparatus_ls_dict) <- apparatus_ls
  
  for (team_num in 1:2) {
    team <- teams[[team_num]]
    for (country_name in names(team)) {
      qual_participation_matrix <- team[[country_name]]$qual_participation
      qual_apparatus_score_matrix <- sapply(apparatus_ls, function(apparatus) {
        team[[country_name]][[apparatus]]$apparatus_name_score
      })
      qual_apparatus_score_matrix <- replace_na(t(qual_apparatus_score_matrix), 0)
      each_apparatus_participation_score <- qual_apparatus_score_matrix * qual_participation_matrix
      for (col in 1:length(apparatus_ls)) {
        for (row in 1:nrow(each_apparatus_participation_score)) {
          if (each_apparatus_participation_score[row, col] != 0) {
            apparatus_name <- apparatus_ls[col]
            athlete_name <- paste(country_name, row)
            apparatus_ls_dict[[apparatus_name]][athlete_name] <- each_apparatus_participation_score[row, col]
          }
        }
      }
    }
  }
  
  final_result_all_apparatus_dict <- lapply(apparatus_ls, function(apparatus) {
    predict(apparatus, apparatus_ls_dict[[apparatus]])
  })
  
  return(final_result_all_apparatus_dict)
}

team_all_around_result <- function(team, apparatus_ls, top_8_countries) {
  team_12_all_around_final_result <- list()
  
  team12 <- team
  for (country_name in top_8_countries) {
    top3_binary_matrix <- team12[[country_name]]$team_12_all_around_binary_matrix
    noise <- matrix(rnorm(nrow(top3_binary_matrix) * ncol(top3_binary_matrix)), nrow(top3_binary_matrix))
    team12[[country_name]]$team_12_all_around_final_result <- top3_binary_matrix * (team12[[country_name]]$qual_team_12_all_around_score + noise)
    team12[[country_name]]$team_12_all_around_final_total_score <- sum(team12[[country_name]]$team_12_all_around_final_result)
    team_12_all_around_final_result[[country_name]] <- team12[[country_name]]$team_12_all_around_final_total_score
  }
  
  team_all_around_sorted_countries <- sort(team_12_all_around_final_result, decreasing = TRUE)
  top_3_countries <- names(team_all_around_sorted_countries)[1:3]
  
  return(list(top_3_countries, team_all_around_sorted_countries))
}

indiv_all_around_result <- function(teams, apparatus_ls, individual_all_around_top_24_athletes) {
  team12 <- teams[[1]]
  team36 <- teams[[2]]
  individual_all_around_final_result <- list()
  
  for (athlete_data in individual_all_around_top_24_athletes) {
    country <- athlete_data[[1]][[1]]
    name <- athlete_data[[1]][[2]]
    score <- athlete_data[[2]]
    team <- if (country %in% names(team12)) team12 else team36
    noise <- rnorm(1)
    result <- sum(score) + noise
    individual_all_around_final_result[paste(country, name, sep = "_")] <- result
  }
  
  individual_all_around_final_sorted <- sort(individual_all_around_final_result, decreasing = TRUE)
  top_3_athletes <- names(individual_all_around_final_sorted)[1:3]
  
  return(list(top_3_athletes, individual_all_around_final_sorted))
}

qual_and_final_result_display <- function(teams, indiv_all_around_top3, individual_all_around_final_sorted, final_result_all_apparatus_dict, team_all_around_top3, team_all_around_sorted_countries) {
  
  cat("Team all around final round result:\n")
  for (rank in 1:length(team_all_around_sorted_countries)) {
    country <- team_all_around_sorted_countries[[rank]][[1]]
    score <- team_all_around_sorted_countries[[rank]][[2]]
    cat(rank, country, score, "\n")
  }
  
  team12 <- teams[[1]]
  team36 <- teams[[2]]
  
  cat("\nIndividual all around final round result:\n")
  for (rank in 1:length(individual_all_around_final_sorted)) {
    data <- strsplit(names(individual_all_around_final_sorted)[rank], "_")
    country <- data[[1]][[1]]
    name <- data[[1]][[2]]
    score <- individual_all_around_final_sorted[rank]
    team <- if (country %in% names(team12)) team12 else team36
    app <- names(team[[country]])[1]
    gymnast_real_index <- match(name, team[[country]][[app]]$index)
    cat(rank, country, gymnast_real_index, score, "\n")
  }
  
  cat('\nEach Apparatus final round results:\n')
  for (apparatus in names(final_result_all_apparatus_dict)) {
    results <- final_result_all_apparatus_dict[[apparatus]]
    top_8_athletes <- results[[1]]
    sorted_athletes_final <- results[[4]]
    cat(apparatus, "\n")
    for (rank in 1:length(sorted_athletes_final)) {
      data <- strsplit(names(sorted_athletes_final)[rank], "_")
      country <- data[[1]][[1]]
      name <- data[[1]][[2]]
      score <- sorted_athletes_final[rank]
      team <- if (country %in% names(team12)) team12 else team36
      app <- names(team[[country]])[1]
      gymnast_real_index <- match(name, team[[country]][[app]]$index)
      cat(rank, country, gymnast_real_index, score, "\n")
    }
  }
}

medal_summarize_and_display <- function(teams, indiv_all_around_top3, final_result_all_apparatus_dict, team_all_around_top3, display = FALSE) {
  
  medal_dict <- c("Gold", "Silver", "Bronze")
  medal_result_by_country <- list()
  
  for (rank in 1:3) {
    country <- indiv_all_around_top3[rank]
    if (!country %in% names(medal_result_by_country)) {
      medal_result_by_country[[country]] <- rep(0, 3)
    }
    medal_result_by_country[[country]][rank] <- medal_result_by_country[[country]][rank] + 1
  }
  
  for (rank in 1:3) {
    country <- team_all_around_top3[rank]
    if (!country %in% names(medal_result_by_country)) {
      medal_result_by_country[[country]] <- rep(0, 3)
    }
    medal_result_by_country[[country]][rank] <- medal_result_by_country[[country]][rank] + 1
  }
  
  for (apparatus in names(final_result_all_apparatus_dict)) {
    results <- final_result_all_apparatus_dict[[apparatus]]
    top_3_athletes <- results[[3]]
    for (rank in 1:3) {
      country <- top_3_athletes[rank]
      if (!country %in% names(medal_result_by_country)) {
        medal_result_by_country[[country]] <- rep(0, 3)
      }
      medal_result_by_country[[country]][rank] <- medal_result_by_country[[country]][rank] + 1
    }
  }
  
  if (display) {
    for (country in names(medal_result_by_country)) {
      cat('\n', country, '\n')
      for (i in 1:3) {
        num_medal <- medal_result_by_country[[country]][i]
        cat(medal_dict[i], ": ", num_medal, "\n")
      }
    }
  }
  
  return(medal_result_by_country)
}

run_simulations <- function(times=1000, display=FALSE, gender="women") {
  
  # Call the data_prep function
  list_data <- data_prep()
  data <- list_data$data
  qual_men_12_team <- list_data$qual_men_12_team
  qual_men_36_team <- list_data$qual_men_36_team
  qual_women_12_team <- list_data$qual_women_12_team
  qual_women_36_team <- list_data$qual_women_36_team
  
  medal_total <- list()
  if (gender == 'men') {
    apparatus_ls <- data$men_apparatus_ls
    teams <- list(qual_men_12_team, qual_men_36_team)    
  } else {
    apparatus_ls <- data$women_apparatus_ls
    teams <- list(qual_women_12_team, qual_women_36_team)    
  }
  
  for (i in 1:times) {
    # Call the functions
    list_all_around <- all_around_result(teams, apparatus_ls)
    team_all_around_sorted_countries_score <- list_all_around$team_all_around_sorted_countries_score
    top_8_countries <- list_all_around$top_8_countries
    individual_all_around_top_24_athletes <- list_all_around$individual_all_around_top_24_athletes
    top_24_athletes <- list_all_around$top_24_athletes
    
    final_result_all_apparatus_dict <- each_apparatus_result(teams, apparatus_ls)
    
    list_team_all_around <- team_all_around_result(teams[[1]], apparatus_ls, top_8_countries)
    team_all_around_top3 <- list_team_all_around$team_all_around_top3
    team_all_around_sorted_countries <- list_team_all_around$team_all_around_sorted_countries
    
    list_indiv_all_around <- indiv_all_around_result(teams, apparatus_ls, individual_all_around_top_24_athletes)
    indiv_all_around_top3 <- list_indiv_all_around$indiv_all_around_top3
    individual_all_around_final_sorted <- list_indiv_all_around$individual_all_around_final_sorted
    
    if (display) {
      qual_and_final_result_display(teams, indiv_all_around_top3, individual_all_around_final_sorted, final_result_all_apparatus_dict, team_all_around_top3, team_all_around_sorted_countries)
    }
    
    medal_counts_by_country <- medal_summarize_and_display(teams, indiv_all_around_top3, final_result_all_apparatus_dict, team_all_around_top3, FALSE)
    
    medal_total_in_current_simulation <- c()
    for (country in names(qual_men_12_team)) {
      medal_total_in_current_simulation <- c(medal_total_in_current_simulation, sum(unlist(medal_counts_by_country[[country]])))
    }
    for (country in names(qual_men_36_team)) {
      medal_total_in_current_simulation <- c(medal_total_in_current_simulation, sum(unlist(medal_counts_by_country[[country]])))
    }
    medal_total[[paste("simulation", i, sep="")]] <- medal_total_in_current_simulation
  }
  
  df <- as.data.frame(medal_total)
  write.csv(df, paste0(gender, 'R_total_number_of_medals_results.csv'), row.names=FALSE)
}

# Running the simulations
run_simulations(1000, FALSE, "men")
run_simulations(1000, FALSE, "women")
