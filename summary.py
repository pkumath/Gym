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

apparatus_list = ['BB', 'FX', 'UE', 'VT']
women_qualifying_scores = []
selected_athletes = []

for country in women_country_athlete_dict_12:
    country_scores = []
    country_athlete_data = women_country_athlete_dict_12[country]
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
    women_qualifying_scores.append(country_scores)

women_qualifying_df = pd.DataFrame(women_qualifying_scores, columns=apparatus_list, index=women_country_athlete_dict_12.keys())
selected_athletes_df = pd.DataFrame({"Country": women_country_athlete_dict_12.keys(), "FirstName": selected_athletes})

# compute the selected athletes' average score for each apparatuses
selected_athletes_scores = []
for athlete in selected_athletes_df["FirstName"]:
    athlete_data = women_athletes_data[women_athletes_data["FirstName"] == athlete]
    athlete_scores = []
    for apparatus in apparatus_list:
        apparatus_data = athlete_data[athlete_data["Apparatus"] == apparatus]
        if len(apparatus_data) == 0:
            athlete_scores.append(10)
        else:
            athlete_scores.append(apparatus_data["Score"].mean())
    selected_athletes_scores.append(athlete_scores)

selected_athletes_scores_df = pd.DataFrame(selected_athletes_scores, columns=apparatus_list)
selected_athletes_scores_df.index = selected_athletes_df["FirstName"]
women_selected_athletes_df = selected_athletes_scores_df.copy()



# select the top 8 countries with the highest total score on all apparatuses for men and women, separately
men_total_scores = men_qualifying_df.sum(axis=1)
women_total_scores = women_qualifying_df.sum(axis=1)

top_8_men_countries = men_total_scores.sort_values(ascending=False).head(8).index.tolist()
top_8_women_countries = women_total_scores.sort_values(ascending=False).head(8).index.tolist()


# Now for the team final, we just sort the top 8 countries by their total score on all apparatuses, for men and women separately, and arrange them in dataframes with columns "Country", "Score", "Rank"
# Create dataframes for the top 8 men's and women's countries with columns "Country", "Score", "Rank"
men_team_final_df = pd.DataFrame({"Score": men_total_scores[top_8_men_countries], "Rank": range(1, 9)})
women_team_final_df = pd.DataFrame({"Score": women_total_scores[top_8_women_countries], "Rank": range(1, 9)})

print("men's team final outcome:", men_team_final_df)
print("women's team final outcome:", women_team_final_df)

# Combine women_selected_athletes_df and men_selected_athletes_df into a single dataframe and give and rank based on AverageScore
# selected_athletes_df = pd.concat([women_selected_athletes_df, men_selected_athletes_df])
# selected_athletes_df["Rank"] = selected_athletes_df["AverageScore"].rank(method="dense", ascending=False).astype(int)
# print("individual final", selected_athletes_df)
women_selected_athletes_df
men_selected_athletes_df
# append a total score column
women_selected_athletes_df["TotalScore"] = women_selected_athletes_df[['BB', 'FX', 'UE', 'VT']].sum(axis=1)
men_selected_athletes_df["TotalScore"] = men_selected_athletes_df[['BB', 'FX', 'UE', 'VT', 'VT1', 'VT2']].sum(axis=1)

# determine the men's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list = ['BB', 'FX', 'UE', 'VT', 'VT1', 'VT2']
for apparatus in apparatus_list:
    # append a "Rank" column for each apparatus
    men_selected_athletes_df[apparatus + "Rank"] = men_selected_athletes_df[apparatus].rank(method="dense", ascending=False).astype(int)
# append a "TotalRank" column
men_selected_athletes_df["TotalRank"] = men_selected_athletes_df["TotalScore"].rank(method="dense", ascending=False).astype(int)
print("men's individual final:", men_selected_athletes_df)

# determine the women's ranking for each apparatus and append a "Rank" column for each apparatus
apparatus_list = ['BB', 'FX', 'UE', 'VT']
for apparatus in apparatus_list:
    women_selected_athletes_df[apparatus + "Rank"] = women_selected_athletes_df[apparatus].rank(method="dense", ascending=False).astype(int)

# append a "TotalRank" column
women_selected_athletes_df["TotalRank"] = women_selected_athletes_df["TotalScore"].rank(method="dense", ascending=False).astype(int)

print("women's individual final:", women_selected_athletes_df)