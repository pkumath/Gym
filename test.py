import pandas as pd
from fuzzywuzzy import fuzz

# create a sample DataFrame
df = pd.DataFrame({
    'name': ['John', 'Jane', 'Bob', 'Sara', 'Mike', 'John'],
    'age': [25, 30, 35, 28, 32, 25],
    'gender': ['M', 'F', 'M', 'F', 'M', 'M']
})

# get the mode of each column
mode_df = df["name"].mode()[0]

# print the mode DataFrame
print(mode_df)