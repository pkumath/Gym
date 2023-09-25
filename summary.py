# Read data from "data/data_2017_2021.csv" and "data/data_2022_2023.csv"

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Read data
data_2017_2021 = pd.read_csv("data/data_2017_2021.csv")
data_2022_2023 = pd.read_csv("data/data_2022_2023.csv")

# For the "Apparatus" column, replace "VT_1", "VT_2" by "VT1", "VT2"
data_2022_2023["Apparatus"] = data_2022_2023["Apparatus"].replace({"VT_1": "VT1", "VT_2": "VT2"})
# Filter out NaN in the "Score" column
data_2022_2023 = data_2022_2023[data_2022_2023["Score"].notna()]

# Split data_2022_2023 by Gender
men_athletes_data = data_2022_2023[data_2022_2023["Gender"] == "m"]
women_athletes_data = data_2022_2023[data_2022_2023["Gender"] == "w"]

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_countries = men_athletes_data["Country"].unique()
men_country_athlete_dict = {country: men_athletes_data[men_athletes_data["Country"] == country] for country in men_countries}

women_countries = women_athletes_data["Country"].unique()
women_country_athlete_dict = {country: women_athletes_data[women_athletes_data["Country"] == country] for country in women_countries}

# For men_country_athlete_dict and women_country_athlete_dict, select the top 9 countries with most entries
# Select the top 9 countries with the most entries for both men and women
k = 12
men_top_12_countries = men_athletes_data["Country"].value_counts().head(k).index.tolist()
women_top_12_countries = women_athletes_data["Country"].value_counts().head(k).index.tolist()
# Filter the men_country_athlete_dict and women_country_athlete_dict by the top 9 countries
men_country_athlete_dict_12 = {country: data for country, data in men_country_athlete_dict.items() if country in men_top_12_countries}
women_country_athlete_dict_12 = {country: data for country, data in women_country_athlete_dict.items() if country in women_top_12_countries}


# Determine a 5-person team for each country based on the top 5 athletes who appear most frequently, and split the data for each country based on the selected athletes
for country in men_country_athlete_dict_12:
    top_5_athletes = men_country_athlete_dict_12[country].groupby("FirstName").size().sort_values(ascending=False).head(5)
    men_country_athlete_dict_12[country] = men_country_athlete_dict_12[country][men_country_athlete_dict_12[country]["FirstName"].isin(top_5_athletes.index)]
for country in women_country_athlete_dict_12:
    top_5_athletes = women_country_athlete_dict_12[country].groupby("FirstName").size().sort_values(ascending=False).head(5)
    women_country_athlete_dict_12[country] = women_country_athlete_dict_12[country][women_country_athlete_dict_12[country]["FirstName"].isin(top_5_athletes.index)]

# For each country, each athlete, group the data by "Apparatus" and calculate the average score of each apparatus, then replace the original data with the new data (average score)
for country in men_country_athlete_dict_12:
    for athlete in men_country_athlete_dict_12[country]["FirstName"].unique():
        athlete_data = men_country_athlete_dict_12[country][men_country_athlete_dict_12[country]["FirstName"] == athlete]
        apparatus_scores = athlete_data.groupby("Apparatus")["Score"].mean()
        for apparatus in apparatus_scores.index:
            men_country_athlete_dict_12[country].loc[(men_country_athlete_dict_12[country]["FirstName"] == athlete) & (men_country_athlete_dict_12[country]["Apparatus"] == apparatus), "Score"] = apparatus_scores[apparatus]
        men_country_athlete_dict_12[country] = men_country_athlete_dict_12[country].drop_duplicates(subset=["FirstName", "Apparatus"], keep="first")
for country in women_country_athlete_dict_12:
    for athlete in women_country_athlete_dict_12[country]["FirstName"].unique():
        athlete_data = women_country_athlete_dict_12[country][women_country_athlete_dict_12[country]["FirstName"] == athlete]
        apparatus_scores = athlete_data.groupby("Apparatus")["Score"].mean()
        for apparatus in apparatus_scores.index:
            women_country_athlete_dict_12[country].loc[(women_country_athlete_dict_12[country]["FirstName"] == athlete) & (women_country_athlete_dict_12[country]["Apparatus"] == apparatus), "Score"] = apparatus_scores[apparatus]
        women_country_athlete_dict_12[country] = women_country_athlete_dict_12[country].drop_duplicates(subset=["FirstName", "Apparatus"], keep="first")

# identify all apparatuses
apparatuses = data_2017_2021["Apparatus"].unique().tolist()
apparatuses


# The men's qualifying stage, for each country, first select an athlete to compete on all apparatus. Then, for each apparatus, select the top 2 athletes with the highest score and calculate the average score of the these 3 athletes. If the apparatus's total entry is less than 3, then the total score is the average of this apparatus's entries. If the apparatus's total entry is 0, then the total score is 10.
# The apparatus list is ["FX", "PH", "SR", "VT", "PB", "HB"]
# Also return the selected athletes that compete on all apparatuses

# The men's qualifying stage, for each country, first select an athlete to compete on all apparatus. Then, for each apparatus, select the top 2 athletes with the highest score and calculate the average score of the these 3 athletes. If the apparatus's total entry is less than 3, then the total score is the average of this apparatus's entries. If the apparatus's total entry is 0, then the total score is 10.
# The apparatus list is ["FX", "PH", "SR", "VT", "PB", "HB"]
# Also return the selected athletes that compete on all apparatuses

apparatus_list = apparatuses.copy()
men_qualifying_scores = []
selected_athletes = []

for country in men_country_athlete_dict_12:
    country_scores = []
    country_athlete_data = men_country_athlete_dict_12[country]
    selected_athlete = country_athlete_data.groupby("FirstName")["Score"].sum().sort_values(ascending=False).head(1).index[0]
    selected_athletes.append(selected_athlete)
    for apparatus in apparatus_list:
        apparatus_data = country_athlete_data[country_athlete_data["Apparatus"] == apparatus]
        if len(apparatus_data) == 0:
            country_scores.append(10)
        else:
            top_2_athletes = apparatus_data.groupby("FirstName")["Score"].mean().sort_values(ascending=False).head(2)
            top_3_athletes = pd.concat([top_2_athletes, country_athlete_data[country_athlete_data["FirstName"] == selected_athlete][country_athlete_data["Apparatus"] == apparatus]["Score"]])
            if len(top_3_athletes) < 3:
                country_scores.append(top_3_athletes.mean())
            else:
                country_scores.append(top_3_athletes.mean())
    men_qualifying_scores.append(country_scores)

men_qualifying_df = pd.DataFrame(men_qualifying_scores, columns=apparatus_list, index=men_country_athlete_dict_12.keys())
selected_athletes_df = pd.DataFrame({"Country": men_country_athlete_dict_12.keys(), "FirstName": selected_athletes})

# compute the selected athletes' average score for each apparatus
selected_athletes_scores = []
for athlete in selected_athletes_df["FirstName"]:
    athlete_data = men_athletes_data[men_athletes_data["FirstName"] == athlete]
    athlete_scores = []
    for apparatus in apparatuses:
        apparatus_data = athlete_data[athlete_data["Apparatus"] == apparatus]
        if len(apparatus_data) == 0:
            athlete_scores.append(10)
        else:
            athlete_scores.append(apparatus_data["Score"].mean())
    selected_athletes_scores.append(athlete_scores)

selected_athletes_scores_df = pd.DataFrame(selected_athletes_scores, columns=apparatuses)
selected_athletes_scores_df.index = selected_athletes_df["FirstName"]
men_selected_athletes_df = selected_athletes_scores_df.copy()