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
        if os.path.isdir(data_dir):
            self.data_dir = data_dir
        else:
            raise ValueError("Directory does not exist")
        self.data = pd.read_csv(self.data_dir)
        self.data_with_NaN = None
        self.data

    # Method: data cleaning
    def _cleaner(self, merge_VT: bool = True):
        self.data["Apparatus"].replace({"VT_1": "VT1", "VT_2": "VT2", "hb":"HB"})
        if merge_VT:
            self.data["Apparatus"].replace({"VT1": "VT", "VT2": "VT"})
        # Find data with NaN in column "Score"
        self.data_with_NaN = self.data[self.data["Score"].isna()]
        # Drop data with NaN in column "Score"
        self.data = self.data.dropna(subset=["Score"])

