# Construct a data class
import pandas as pd
import numpy as np
import os

class Data:
    # Constructor
    def __init__(self, 
                 data_dir: str = None,
                 data_name: str = "default_data", 
                 ):
        # Check if the data directory exists
        if os.path.exists(data_dir):
            self.data_dir = data_dir
        else:
            raise ValueError("Directory does not exist")
        
        # Read the data
        data = pd.read_csv(self.data_dir)
        # Construct a new dictionary to store the data, where the key is the data_name, and the value is the data
        self.data = {data_name: data}

    def _data_loader(self,
                        data_dir: str,
                        ):
        '''
        Load the data from the directory.

        Input:
            data_dir: str, the directory of the data to load.

        Output:
            data: pd.DataFrame, the loaded data
        '''
        # Check if the data directory exists
        if os.path.exists(data_dir):
            data = pd.read_csv(data_dir)
        else:
            raise ValueError("Directory does not exist")
        
        return data
    
    def _data_fetcher(self,
                        data_or_data_name: pd.DataFrame or str,
                        deep_copy: bool = False,
                        ):
        '''
        Fetch the data from the class or just return a (deep) copy of the data.

        Input:
            data_or_data_name: pd.DataFrame or str, the data to fetch. If it is a string, then it is the name of the data to fetch. If it is a pd.DataFrame, then it is the data to fetch.
            deep_copy: bool, whether to deep copy the data. Default is False.

        Output:
            data: pd.DataFrame, the fetched data
        '''
        # Fetch the data
        if isinstance(data_or_data_name, str):
            if data_or_data_name not in self.data.keys():
                raise ValueError("Data name does not exist")
            else:
                data = self.data[data_or_data_name]
        else:
            data = data_or_data_name

        # Deep copy the data
        if deep_copy:
            data_copy = data.copy(deep=True)
            return data_copy
        else:
            return data

    def _add_or_replace_data(self,
                    data_or_data_dir: pd.DataFrame or str,
                    data_name: str,
                    ):
        '''
        Add a new data to the class or replace the existing data.

        Input:
            data_or_data_dir: pd.DataFrame or str, the data to add. If it is a string, then it is the directory of the data.
            data_name: str, the name of the data to add.

        Output:
            None
        '''
        # Fetch the data
        if isinstance(data_or_data_dir, str):
            data = self._data_loader(data_or_data_dir)
        else:
            data = data_or_data_dir

        # Add the data to the class
        self.data[data_name] = data


    # Method: data grouping
    def _group(self, 
                  col_name: list or str,
                  data_or_data_name: pd.DataFrame or str = "default_data",
                  store_into: str = None,
                  ):
        '''
        Group the data into a hierarchical DataFrameGroupBy object such that it is iterable.
        
        Input:
            data_name: pd.DataFrame or string, the data to split. Default is None, which means the data is the data in the class. If data is a string, then it is the name to the data.
            col_name: string, the column name to split the data
            stored_into: str, whether to store the splitted data in the class. Default is None.

        Output:
            data_grouped: pd.DataFrameGroupBy, the grouped data
        '''
        # Fetch the data
        if isinstance(data_or_data_name, str):
            if data_or_data_name not in self.data.keys():
                raise ValueError("Data name does not exist")
            else:
                data = self.data[data_or_data_name]
        else:
            data = data_or_data_name

        for col in col_name:
            if col not in data.columns:
                raise ValueError(f"Column name:{col} does not exist")
        data_grouped = data.groupby(col_name)

        # Store the data
        if store_into is not None:
            # deep copy the data
            self.data[store_into] = data_grouped.copy(deep=True)
        
        return data_grouped


    # Method: data cleaning
    def _cleaner(self, 
                 data_name: str = "default_data", 
                 merge_VT: bool = True, 
                 clean_NaN_in_Score: bool = True,
                 ):
        '''
        Clean the data, drop the data with NaN in column "Score", and merge the VT1 and VT2 into VT.
        
        Input:
            data_name: string, the name of the data to clean. Default is None, which means the data is the default data in the class.
            clean_NaN_in_Score: bool, whether to drop the data with NaN in column "Score". Default is True.
            merge_VT: bool, whether to merge VT1 and VT2 into VT. Default is True.

        Output:
            None
        '''
        # Check if the data_name exists
        if data_name not in self.data.keys():
            raise ValueError("Data name does not exist")
        # Get the data to clean, this should be a pointer to the data in the class
        data = self.data[data_name]
        
        # Replace some wrong items in the column "Apparatus"
        if "Apparatus" in data.columns:
            data["Apparatus"].replace({"VT_1": "VT1", "VT_2": "VT2", "hb":"HB"})
            if merge_VT:
                data["Apparatus"].replace({"VT1": "VT", "VT2": "VT"})
        
        # Drop the data with NaN in column "Score"
        if clean_NaN_in_Score and "Score" in data.columns:
            data = data.dropna(subset=["Score"])

        # Update the data in the class
        self.data[data_name] = data

if __name__ == "__main__":
    data = Data(data_dir="data/data_2022_2023.csv")
    data._cleaner()
    print(data.data_with_NaN)
    print(data.data)