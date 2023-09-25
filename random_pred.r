# 加载必要的库
library(tidyverse)

# 读取数据文件
data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")

# 清洗数据，去除所有的NA和空值
unique_men_countries <- na.omit(unique(data_2022_2023$Country[data_2022_2023$Gender == "m"]))
unique_women_countries <- na.omit(unique(data_2017_2021$Country[data_2022_2023$Gender == "w"]))

# 随机选择12个国家
set.seed(123) # 设置随机数种子以确保结果的可重复性
# 查看男子和女子的独特参赛国家数量
num_men_countries <- length(unique_men_countries)
num_women_countries <- length(unique_women_countries)

# 基于可用的国家数量随机选择国家
random_countries_men <- sample(unique_men_countries, min(12, num_men_countries))
random_countries_women <- sample(unique_women_countries, min(12, num_women_countries))

# 打印选定的国家
print("Randomly Selected Men's Teams:")
print(random_countries_men)

print("Randomly Selected Women's Teams:")
print(random_countries_women)



# # 为每个国家选择前5名体操运动员
# select_top_5_gymnasts <- function(data, country, gender){
#   data %>%
#     filter(Country == country, Gender == tolower(gender)) %>%
#     arrange(desc(Score)) %>%
#     %
#   head(5)
# }
# Select the top 5 gymnasts for each country
select_top_5_gymnasts <- function(data, country, gender){
  data %>%
    filter(Country == country, Gender == tolower(gender)) %>%
    group_by(FirstName) %>%
    sample_n(min(5, n()), replace = FALSE) %>%
    ungroup()
}

teams_men <- lapply(random_countries_men, select_top_5_gymnasts, data = data_2022_2023, gender = "M")
teams_women <- lapply(random_countries_women, select_top_5_gymnasts, data = data_2022_2023, gender = "F")

# 从不具备团队资格的国家中选择前3名体操运动员
remaining_countries_men <- setdiff(unique(data_2022_2023$Country[data_2022_2023$Gender == "m"]), random_countries_men)
remaining_countries_women <- setdiff(unique(data_2022_2023$Country[data_2022_2023$Gender == "f"]), random_countries_women)

# Select the top 3 gymnasts from the remaining countries that did not qualify for the team event
select_top_3_gymnasts <- function(data, country, gender){
  data %>%
    filter(Country == country, Gender == tolower(gender)) %>%
    group_by(FirstName) %>%
    sample_n(min(3, n()), replace = FALSE) %>%
    ungroup()
}

individuals_men <- lapply(remaining_countries_men, select_top_3_gymnasts, data = data_2022_2023, gender = "M")
individuals_women <- lapply(remaining_countries_women, select_top_3_gymnasts, data = data_2022_2023, gender = "F")

# 打印结果
print("Randomly Selected Men's Teams:")
print(random_countries_men)
lapply(teams_men, print)

print("Randomly Selected Women's Teams:")
print(random_countries_women)
lapply(teams_women, print)

print("Individual Men's Gymnasts Selection:")
lapply(individuals_men, print)

print("Individual Women's Gymnasts Selection:")
lapply(individuals_women, print)