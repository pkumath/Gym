# Read data from "data/data_2017_2021.csv" and "data/data_2022_2023.csv"

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Read data
data_2017_2021 = pd.read_csv("data/data_2017_2021.csv")
data_2022_2023 = pd.read_csv("data/data_2022_2023.csv")

# Split data_2022_2023 by Gender
men_athletes_data = data_2022_2023[data_2022_2023["Gender"] == "m"]
women_athletes_data = data_2022_2023[data_2022_2023["Gender"] == "w"]

# Split men_athletes_data and women_athletes_data by "Country" into 2 lists
men_countries = men_athletes_data["Country"].unique()
men_country_athlete_dict = {country: men_athletes_data[men_athletes_data["Country"] == country] for country in men_countries}

women_countries = women_athletes_data["Country"].unique()
women_country_athlete_dict = {country: women_athletes_data[women_athletes_data["Country"] == country] for country in women_countries}


