# Required libraries
library(dplyr)

# Function to generate summary and list countries with 5 or more athletes
generate_summary <- function(data) {
  # List of unique countries
  countries <- unique(data$Country)
  
  # Generating summary for each country
  country_summary <- list()
  countries_with_5_or_more <- c()
  
  for (country in countries) {
    male_athletes_data <- data %>%
      filter(Country == country, Gender == "m") %>%
      distinct(FirstName, LastName) %>%
      arrange(FirstName, LastName)
    
    female_athletes_data <- data %>%
      filter(Country == country, Gender == "w") %>%
      distinct(FirstName, LastName) %>%
      arrange(FirstName, LastName)
    
    male_athlete_count <- nrow(male_athletes_data)
    female_athlete_count <- nrow(female_athletes_data)
    
    # Check if country has 5 or more athletes
    if (male_athlete_count >= 5) {
      countries_with_5_or_more <- append(countries_with_5_or_more, paste(country, "(Male)"))
    }
    if (female_athlete_count >= 5) {
      countries_with_5_or_more <- append(countries_with_5_or_more, paste(country, "(Female)"))
    }
    
    # Store athlete data in the summary list
    country_summary[[country]] <- list(
      MaleAthleteCount = male_athlete_count,
      MaleAthletes = male_athletes_data,
      FemaleAthleteCount = female_athlete_count,
      FemaleAthletes = female_athletes_data
    )
  }
  
  list(Summary = country_summary, CountriesWith5OrMore = countries_with_5_or_more)
}

# Load the datasets
data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")

# Generate summaries
summary_2017_2021 <- generate_summary(data_2017_2021)
summary_2022_2023 <- generate_summary(data_2022_2023)

# Print countries with 5 or more athletes for each dataset
cat("Countries in data_2017_2021 with 5 or more athletes:\n")
print(summary_2017_2021$CountriesWith5OrMore)

cat("\nCountries in data_2022_2023 with 5 or more athletes:\n")
print(summary_2022_2023$CountriesWith5OrMore)

# Pre-determined countries
known_men_countries <- c("CHN", "JPN", "GBR")
known_women_countries <- c("USA", "GBR", "CAN")

# Extract available countries with 5 or more athletes for 2022-2023
available_men_countries <- summary_2022_2023$CountriesWith5OrMore[grep("(Male)", summary_2022_2023$CountriesWith5OrMore)]
available_women_countries <- summary_2022_2023$CountriesWith5OrMore[grep("(Female)", summary_2022_2023$CountriesWith5OrMore)]

# Exclude known countries
available_men_countries <- setdiff(available_men_countries, paste(known_men_countries, "(Male)"))
available_women_countries <- setdiff(available_women_countries, paste(known_women_countries, "(Female)"))

# Randomly select 9 more countries for men and women
set.seed(123)  # for reproducibility
additional_men_countries <- sample(available_men_countries, 9)
additional_women_countries <- sample(available_women_countries, 9)

# Combine the known and randomly selected countries
all_men_countries <- c(paste(known_men_countries, "(Male)"), additional_men_countries)
all_women_countries <- c(paste(known_women_countries, "(Female)"), additional_women_countries)

# Print the selected countries
cat("Men's Countries for Olympics based on 2022-2023 data:\n")
print(all_men_countries)
cat("\n\nWomen's Countries for Olympics based on 2022-2023 data:\n")
print(all_women_countries)


# Correctly extract country names from the provided lists
men_countries <- gsub(" \\(Male\\)", "", all_men_countries)
women_countries <- gsub(" \\(Female\\)", "", all_women_countries)

# Step 1: Filter out athletes from selected countries
men_athletes_data <- data_2022_2023 %>%
  filter(Country %in% men_countries, Gender == "m")

women_athletes_data <- data_2022_2023 %>%
  filter(Country %in% women_countries, Gender == "w")

# Step 2: Randomly select five athletes from each country
set.seed(123)  # for reproducibility

men_country_athlete_dict <- list()
for (country in men_countries) {
  selected_athletes <- men_athletes_data %>%
    filter(Country == country) %>%
    distinct(FirstName, LastName) %>%
    sample_n(min(5, n())) %>%
    mutate(FullName = paste(FirstName, LastName)) %>%
    .$FullName  # Extract full names
  
  men_country_athlete_dict[[country]] <- selected_athletes
}

women_country_athlete_dict <- list()
for (country in women_countries) {
  selected_athletes <- women_athletes_data %>%
    filter(Country == country) %>%
    distinct(FirstName, LastName) %>%
    sample_n(min(5, n())) %>%
    mutate(FullName = paste(FirstName, LastName)) %>%
    .$FullName  # Extract full names
  
  women_country_athlete_dict[[country]] <- selected_athletes
}

# The two dictionaries: men_country_athlete_dict and women_country_athlete_dict, 
# should now contain the names of five athletes from each selected country.

# Filter out athletes from countries that already have team qualifications
additional_men_athletes <- data_2022_2023 %>%
  filter(!(Country %in% c(men_countries, "RUS", "BLR")), Gender == "m") %>%
  filter(!is.na(FirstName) & !is.na(LastName) & FirstName != "" & LastName != "")

additional_women_athletes <- data_2022_2023 %>%
  filter(!(Country %in% c(women_countries, "RUS", "BLR")), Gender == "w") %>%
  filter(!is.na(FirstName) & !is.na(LastName) & FirstName != "" & LastName != "")

# Randomly select 36 athletes for each gender
set.seed(123)  # for reproducibility

selected_additional_men <- additional_men_athletes %>%
  group_by(Country) %>%
  sample_n(min(3, n())) %>%
  ungroup() %>%
  slice_sample(n = 36) %>%
  mutate(FullName = paste(FirstName, LastName)) %>%
  .$FullName

selected_additional_women <- additional_women_athletes %>%
  group_by(Country) %>%
  sample_n(min(3, n())) %>%
  ungroup() %>%
  slice_sample(n = 36) %>%
  mutate(FullName = paste(FirstName, LastName)) %>%
  .$FullName

# The two arrays: selected_additional_men and selected_additional_women, 
# should now contain the names of the 36 additional athletes for each gender.
# Add the selected additional athletes to the existing dictionaries
men_country_athlete_dict[["additional"]] <- selected_additional_men
women_country_athlete_dict[["additional"]] <- selected_additional_women

