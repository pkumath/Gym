import pandas as pd
# create a sample DataFrame
df = pd.DataFrame({
    'gender': ['M', 'F', 'M', 'F', 'M', 'F'],
    'country': ['USA', 'USA', 'Canada', 'Canada', 'Mexico', 'Mexico'],
    'sport': ['swimming', 'swimming', 'gymnastics', 'gymnastics', 'tennis', 'tennis'],
    'athlete': ['John Doe', 'Jane Smith', 'Bob Johnson', 'Sara Lee', 'Juan Perez', 'Maria Garcia'],
    'score': [8.5, 9.0, 7.5, 8.0, 9.5, 9.0]
})

# group the data by gender and country
grouped_data = df.groupby(['gender', 'country'])

for key in grouped_data.groups.keys():
    print(key)