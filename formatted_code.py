# Construct a data class
import pandas as pd
import numpy as np
import os

class Data:
    # Constructor
    def __init__(self, 
                 data_dir: str = None,
                 data_name: str = None, 
                 ):
        self.data_name = data_name
        # Check if the data directory exists
        if os.path.exists(data_dir):
            self.data_dir = data_dir
        else:
            raise ValueError("Directory does not exist")
        self.data = pd.read_csv(self.data_dir)
        self.data_with_NaN = None
        self.data

    # Method: data cleaning
    def _cleaner(self, merge_VT: bool = True):
        '''
        Clean the data, drop the data with NaN in column "Score", and merge the VT1 and VT2 into VT.
        
        Input:
        merge_VT: bool, whether to merge VT1 and VT2 into VT. Default is True.

        Output:
        None
        '''
        self.data["Apparatus"].replace({"VT_1": "VT1", "VT_2": "VT2", "hb":"HB"})
        if merge_VT:
            self.data["Apparatus"].replace({"VT1": "VT", "VT2": "VT"})
        # Find data with NaN in column "Score"
        self.data_with_NaN = self.data[self.data["Score"].isna()]
        # Drop data with NaN in column "Score"
        self.data = self.data.dropna(subset=["Score"])

    # Method: data splitting, split the data into a hierarchical list of dataframes such that it is iterable.
    def _splitter(self, 
                  column: list, # 
                  ):
        

    # Method: data formatting, 
    # 1. First group the data by gender, and then by country (scale down the data). We 
    # then withing each country, group the data by athlete (FistName and LastName, note that the capitalization does not matther, and we should )
    def _formatter(self):
        pass

if __name__ == "__main__":
    data = Data(data_dir="data/data_2022_2023.csv")
    data._cleaner()
    print(data.data_with_NaN)
    print(data.data)