library(dplyr)

# 加载数据
data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")

# 预先确定的国家名单
preselected_countries_men <- c("CHN", "JPN", "GBR")
preselected_countries_women <- c("USA", "GBR", "CAN")

# 统计每个性别每个国家的唯一运动员数量
athlete_count_2017_2021 <- data_2017_2021 %>%
  group_by(Gender, Country) %>%
  summarise(Unique_Athletes = n_distinct(paste(FirstName, LastName))) %>%
  filter((Gender == "m" & !(Country %in% preselected_countries_men)) | 
           (Gender == "w" & !(Country %in% preselected_countries_women)))

athlete_count_2022_2023 <- data_2022_2023 %>%
  group_by(Gender, Country) %>%
  summarise(Unique_Athletes = n_distinct(paste(FirstName, LastName))) %>%
  filter((Gender == "m" & !(Country %in% preselected_countries_men)) | 
           (Gender == "w" & !(Country %in% preselected_countries_women)))

# 筛选至少有五个唯一运动员的国家
eligible_countries_2017_2021 <- athlete_count_2017_2021 %>%
  filter(Unique_Athletes >= 5)

eligible_countries_2022_2023 <- athlete_count_2022_2023 %>%
  filter(Unique_Athletes >= 5)

# 合并预先确定的国家和筛选出的国家
final_countries_2017_2021 <- bind_rows(eligible_countries_2017_2021, 
                                       data.frame(Gender = c("m", "m", "m", "w", "w", "w"),
                                                  Country = c(preselected_countries_men, preselected_countries_women),
                                                  Unique_Athletes = c(rep(NA, 6))))

final_countries_2022_2023 <- bind_rows(eligible_countries_2022_2023, 
                                       data.frame(Gender = c("m", "m", "m", "w", "w", "w"),
                                                  Country = c(preselected_countries_men, preselected_countries_women),
                                                  Unique_Athletes = c(rep(NA, 6))))

# 输出数据摘要
summary_2017_2021 <- final_countries_2017_2021 %>%
  group_by(Gender) %>%
  summarise(Total_Countries = n(), 
            Countries_with_5_or_more_athletes = sum(!is.na(Unique_Athletes)))

summary_2022_2023 <- final_countries_2022_2023 %>%
  group_by(Gender) %>%
  summarise(Total_Countries = n(), 
            Countries_with_5_or_more_athletes = sum(!is.na(Unique_Athletes)))

# 输出2017-2021年数据摘要
cat("Summary for 2017-2021:\n")
cat("--------------------------------------------------\n")
print(summary_2017_2021)

# 输出2017-2021年合格国家列表
cat("\nEligible countries for 2017-2021:\n")
cat("--------------------------------------------------\n")
print(final_countries_2017_2021)

# 输出2022-2023年数据摘要
cat("\nSummary for 2022-2023:\n")
cat("--------------------------------------------------\n")
print(summary_2022_2023)

# 输出2022-2023年合格国家列表
cat("\nEligible countries for 2022-2023:\n")
cat("--------------------------------------------------\n")
print(final_countries_2022_2023)