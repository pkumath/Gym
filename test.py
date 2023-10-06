import pandas as pd
import numpy as np
# create a sample DataFrame
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
    'score': np.array([90, np.nan, 95, 85, 92])
})

# select the top 3 rows based on the 'score' column
top_k = df.nlargest(2, 'score')

print(top_k)