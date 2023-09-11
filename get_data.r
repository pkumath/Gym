# Load necessary library
library(readr)

# Set relative path to the 'data' subfolder
data_folder_path <- "data/"

# Read the first CSV file into a data frame
data_2017_2021 <- read_csv(paste0(data_folder_path, "data_2017_2021.csv"))
# Examine the first few rows to understand the structure
head(data_2017_2021)

# Read the second CSV file into a separate data frame
data_2022_2023 <- read_csv(paste0(data_folder_path, "data_2022_2023.csv"))
# Examine the first few rows to understand the structure
head(data_2022_2023)

# From here, you can perform any additional cleaning or transformation on the data frames as needed.
