library(tidyverse)
library(lubridate)

data_2017_2021 <- read.csv("data/data_2017_2021.csv")
data_2022_2023 <- read.csv("data/data_2022_2023.csv")
data_all <- bind_rows(data_2017_2021, data_2022_2023)

# 数据清洗：统一器械名称
data_all$Apparatus <- ifelse(str_detect(data_all$Apparatus, "VT"), "VT", data_all$Apparatus)
data_all$Apparatus <- ifelse(str_detect(data_all$Apparatus, "^[Hh][Bb]$"), "HB", data_all$Apparatus)
data_all$Apparatus <- ifelse(data_all$Gender == "w" & data_all$Apparatus == "UE", "UB", data_all$Apparatus)

# 分性别处理数据
genders <- unique(data_all$Gender)

for (gender in genders) {
  data_gender <- data_all %>% filter(Gender == gender)
  
  # Apparatus Distribution
  p2 <- data_gender %>%
    ggplot(aes(x = Apparatus)) +
    geom_bar() +
    labs(title = paste0("Apparatus Distribution - ", gender), x = "Apparatus", y = "Count") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
          axis.text.y = element_text(size = 14),
          plot.title = element_text(size = 16))
  ggsave(paste0("figures/Apparatus_Distribution_", gender, ".png"), p2)
  
  # Score Distribution
  p3 <- data_gender %>%
    ggplot(aes(x = Score)) +
    geom_histogram(binwidth = 0.5) +
    labs(title = paste0("Score Distribution - ", gender), x = "Score", y = "Count") +
    theme(axis.text = element_text(size = 14),
          plot.title = element_text(size = 16))
  ggsave(paste0("figures/Score_Distribution_", gender, ".png"), p3)
  
  # Score Distribution by Apparatus
  p5 <- data_gender %>%
    ggplot(aes(x = Score, fill = Apparatus)) +
    geom_histogram(binwidth = 0.5, position = "identity", alpha = 0.5) +
    labs(title = paste0("Score Distribution by Apparatus - ", gender), x = "Score", y = "Count") +
    facet_wrap(~Apparatus) +
    theme(axis.text = element_text(size = 14),
          plot.title = element_text(size = 16))
  ggsave(paste0("figures/Score_Distribution_by_Apparatus_", gender, ".png"), p5)
}
