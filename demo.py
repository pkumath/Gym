import pandas as pd
import argparse

parser = argparse.ArgumentParser(description='Generate CSV data.')
parser.add_argument('-p', '--people', type=int, default=4, help='Number of people in the CSV.')
parser.add_argument('-a', '--age-multiplier', type=float, default=1.0, help='Multiplier for age.')

args = parser.parse_args()

names = ['John', 'Jane', 'Doe', 'Emily'][:args.people]
ages = [28, 22, 35, 40][:args.people]
ages = [age * args.age_multiplier for age in ages]

data = {
    'Name': names,
    'Age': ages,
    'Occupation': ['Engineer', 'Doctor', 'Lawyer', 'Artist'][:args.people]
}

df = pd.DataFrame(data)
df.to_csv('output_data.csv', index=False)
