library(readr)

data_folder_path <- "data/"

# Read the first CSV file into a data frame
data_2017_2021 <- read_csv(paste0(data_folder_path, "data_2017_2021.csv"))
# Examine the first few rows to understand the structure
head(data_2017_2021)

data_2022_2023 <- read_csv(paste0(data_folder_path, "data_2022_2023.csv"))
# Examine the first few rows to understand the structure
head(data_2022_2023)

