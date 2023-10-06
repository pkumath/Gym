# Construct a data class
import pandas as pd
import numpy as np
import os
from fuzzywuzzy import fuzz
import pickle

class Data:
    # Constructor
    def __init__(self, 
                 data_dir: str = None,
                 data_name: str = "default_data", 
                 data: pd.DataFrame = None,
                 load_dir: str = None,
                 ):
        self.data = {}
        if load_dir is not None:
            self.load_all_data(load_dir)
            return
        if data_dir is not None:
            # Load the data
            data = self._data_loader(data_dir)
        # Construct a new dictionary to store the data, where the key is the data_name, and the value is the data
        self._add_or_replace_data(data, data_name)

    def save_all_data(self, 
                      data_dir: str,
                      ):
        '''
        Save all the data in the class to the directory.

        Input:
            data_dir: str, the directory to save the data.

        Output:
            None
        '''
        # Check if the data directory (without the file name) exists
        if not os.path.exists(os.path.dirname(data_dir)):
            # Create the directory
            os.makedirs(os.path.dirname(data_dir))
        # Save the data
        for key, value in self.data.items():
            value.to_csv(data_dir + key + ".csv", index=False)

    def load_all_data(self,
                        data_dir: str,
                        ):
        '''
        Load all the data from the directory.
        
        Input:
            data_dir: str, the directory to load the data.

        Output:
            None
        ''' 
        # Check if the data directory exists
        if not os.path.exists(data_dir):
            raise ValueError("Directory does not exist")
        # Load the data
        for file in os.listdir(data_dir):
            if file.endswith(".csv"):
                data_name = file.split(".")[0]
                self._add_or_replace_data(data_dir + file, data_name)
        
                

    def _check_data_name(self, data_name: str):
        '''
        Check if the data_name exists in the class.

        Input:
            data_name: str, the name of the data to check.

        Output:
            None
        '''
        if data_name not in self.data.keys():
            raise ValueError("Data name does not exist")
        
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
    
    def _data_saver(self,
                        data_name: str,
                        data_dir: str,
                        ):
        '''
        Save the data to the directory.

        Input:
            data_name: str, the name of the data to save.
            data_dir: str, the directory of the data to save.

        Output:
            None
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Check if the data directory (without the file name) exists
        if not os.path.exists(os.path.dirname(data_dir)):
            raise ValueError("Directory does not exist")
        # Save the data
        self.data[data_name].to_csv(data_dir, index=False)

        
    def _data_copier_fetcher(self,
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
        data = self._data_copier_fetcher(data_or_data_name, deep_copy=True)

        if isinstance(col_name, str):
            col_name = [col_name]
        for col in col_name:
            if col not in data.columns:
                raise ValueError(f"Column name:{col} does not exist")
            
        data.reset_index(inplace=True)
        data_grouped = data.groupby(col_name)

        # Store the data
        if store_into is not None:
            # deep copy the data
            self.data[store_into] = data_grouped
        
        return data_grouped

    def _append_items(self, 
                data_name: str, 
                data_to_append: pd.DataFrame,):
        '''
        Append the data to the existing data.
        
        Input:
            data_name: string, the name of the data to append. Default is None, which means the data is the default data in the class.
            data_to_append: pd.DataFrame, the data to append.

        Output:
            None
        '''
        # Check if the data_name exists
        if data_name not in self.data.keys():
            raise ValueError("Data name does not exist")
        # Append the data
        self.data[data_name] = self.data[data_name].append(data_to_append)

    def _drop_items(self,
              data_name: str,
              items_to_drop: pd.DataFrame or list or np.array,
                ):
        '''
        Drop the data from the existing data.

        Input:
            data_name: string, the name of the data to drop. Default is None, which means the data is the default data in the class.
            items_to_drop: pd.DataFrame or list or np.array, the data to drop. Note that if items_to_drop is a pd.DataFrame, then this dataframe should be a subset of the data in the class.

        Output:
            None
        '''
        # Check if the data_name exists
        if data_name not in self.data.keys():
            raise ValueError("Data name does not exist")
        # Check the type of items_to_drop
        if isinstance(items_to_drop, pd.DataFrame):
            drop_idx = self.data[data_name].isin(items_to_drop.to_dict('list')).all(axis=1)
            self.data[data_name] = self.data[data_name].drop(drop_idx)
        elif isinstance(items_to_drop, list) or isinstance(items_to_drop, np.array):
            self.data[data_name] = self.data[data_name].drop(items_to_drop)
        else:
            raise ValueError("items_to_drop's type is not supported")
        
    def _replace_items(self,
                    data_name: str,
                    items_to_replace: pd.DataFrame or np.array or list,
                    items_to_replace_with: pd.DataFrame,
                    ):
            '''
            Replace the data in the existing data.
    
            Input:
                data_name: string, the name of the data to replace. Default is None, which means the data is the default data in the class.
                items_to_replace: pd.DataFrame, the data to replace.
                items_to_replace_with: pd.DataFrame, the data to replace with.
    
            Output:
                None
            '''
            # Check if the data_name exists
            if data_name not in self.data.keys():
                raise ValueError("Data name does not exist")
            # Check the type of items_to_replace
            if isinstance(items_to_replace, pd.DataFrame):
                replace_idx = self.data[data_name].isin(items_to_replace.to_dict('list')).all(axis=1)
                self.data[data_name].loc[replace_idx] = items_to_replace_with
            elif isinstance(items_to_replace, list) or isinstance(items_to_replace, np.array):
                self.data[data_name].loc[items_to_replace] = items_to_replace_with
            else:
                raise ValueError("items_to_replace's type is not supported")
        
    def _filter(self,
                data_name: str,
                filter_func: callable,
                *args,
                **kwargs,
                ):
        '''
        Filter the data in the existing data. Output the filtered data.
        
        Input:
            data_name: string, the name of the data to filter. Default is None, which means the data is the default data in the class.
            filter_func: callable, the function to filter the data. The input of the function is a pd.DataFrame, and the output of the function is a pd.DataFrame.

        Output:
            filtered_data: pd.DataFrame, the filtered data
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)

        # Filter the data
        return self.data[data_name].loc[filter_func(self.data[data_name], *args, **kwargs)]
    

    # Method: data cleaning
    def _cleaner(self, 
                 data_name: str = "default_data", 
                 merge_VT: bool = True, 
                 clean_NaN_in_Score: bool = True,
                 ):
        '''
        Clean the data.
        '''
        pass

    def split_by_attribute(self, 
                        data_name: str,
                        attribute: str,
                        ):
        '''
        Split the data by the column name. The splitted data is stored as a list, where each element is tuple of (group_name, group_data).

        Input:
            data_name: string, the name of the data to split. Default is None, which means the data is the default data in the class.
            attribute: string, the column name to split the data

        Output:
            splitted_data: list, the splitted data
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Check if the attribute exists
        if attribute not in self.data[data_name].columns:
            raise ValueError("Attribute does not exist")
        # Split the data
        splitted_data = self.data[data_name].groupby(attribute)
        ls = []
        for key, value in splitted_data:
            ls.append((key, value))
        return ls

class Gymnastic_Data_Analyst(Data):
    # Constructor
    def __init__(self, 
                 data_dir: str = None,
                 data_name: str = "default_data", 
                 data: pd.DataFrame = None,
                 load_dir: str = None,
                 ):
        super().__init__(data_dir=data_dir, data_name=data_name, load_dir=load_dir, data=data)

        if load_dir is not None:
            return
        # Clean the data
        self._cleaner(data_name)
        # Summary each athlete's performance on each apparatus
        self._prepare_data(data_name)

    def save_all_data(self, data_dir: str):
        super().save_all_data(data_dir)
        # save the apparatus list
        with open(data_dir + 'men_apparatus_ls.pkl', 'wb') as f:
            pickle.dump(self.men_apparatus_ls, f)
        with open(data_dir + 'women_apparatus_ls.pkl', 'wb') as f:
            pickle.dump(self.women_apparatus_ls, f)
        
    def load_all_data(self, data_dir: str):
        super().load_all_data(data_dir)
        # load the apparatus list
        with open(data_dir + 'men_apparatus_ls.pkl', 'rb') as f:
            self.men_apparatus_ls = pickle.load(f)
        with open(data_dir + 'women_apparatus_ls.pkl', 'rb') as f:
            self.women_apparatus_ls = pickle.load(f)


    def _prepare_data(self,
                        data_name: str = "default_data",
                        ):
        '''
        Prepare the data for the analysis.

        Input:
            data_name: string, the name of the data to prepare. Default is None, which means the data is the default data in the class.

        Output:
            None
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        
        # Split the data into two genders
        ls = self.split_by_attribute(data_name=data_name, attribute="Gender")
        for key, value in ls:
            if key == 'm':
                self._add_or_replace_data(value, "men_"+data_name)
            else:
                self._add_or_replace_data(value, "women_"+data_name)

        # Get the apparatus list
        self.men_apparatus_ls = self._get_apparatus_ls(data_name="men_"+data_name)
        self.women_apparatus_ls = self._get_apparatus_ls(data_name="women_"+data_name)

        # Summary each athlete's performance on each apparatus
        self.summary_for_each_athlete_by_gender("men_"+data_name, store_into="summary_men_"+data_name)
        self.summary_for_each_athlete_by_gender("women_"+data_name, store_into="summary_women_"+data_name)


    def _get_apparatus_ls(self, 
                          data_name: str = "default_data",
                          ):
        '''
        Get all the apparatus in the data.

        Input:
            data_name: string, the name of the data to get the apparatus. Default is None, which means the data is the default data in the class.

        Output:
            apparatus_ls: list, the list of all the apparatus
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Get the data to get the apparatus, this should be a pointer to the data in the class
        data = self.data[data_name]
        # Get all the apparatus
        apparatus_ls = data["Apparatus"].unique()
        return apparatus_ls
    

    # Method: data cleaning
    def _cleaner(self, 
                 data_name: str = "default_data", 
                 merge_VT: bool = True, 
                 clean_NaN_in_Score: bool = True):
        '''
        Clean the data, drop the data with NaN in column "Score", and merge the VT1 and VT2 into VT.
        
        Input:
            data_name: string, the name of the data to clean. Default is None, which means the data is the default data in the class.
            clean_NaN_in_Score: bool, whether to drop the data with NaN in column "Score". Default is True.
            merge_VT: bool, whether to merge VT1 and VT2 into VT. Default is True.

        Output:
            None
        '''
        super()._cleaner(data_name, merge_VT, clean_NaN_in_Score)
        
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Get the data to clean, this should be a pointer to the data in the class
        data = self.data[data_name]
        
        # Replace some wrong items in the column "Apparatus"
        if "Apparatus" in data.columns:
            data["Apparatus"].replace({"VT_1": "VT1", "VT_2": "VT2", "hb":"HB"}, inplace=True)
            if merge_VT:
                data["Apparatus"].replace({"VT1": "VT", "VT2": "VT"}, inplace=True)
        
        # Drop the data with NaN in column "Score"
        if clean_NaN_in_Score and "Score" in data.columns:
            data = data.dropna(subset=["Score"])
        
        # Replace NaN in column "FirstName" and "LastName" with empty string ""
        data["FirstName"].fillna("", inplace=True)
        data["LastName"].fillna("", inplace=True)
        # If the LastName or First Name contains ' ', then only keep the first part
        data["FirstName"] = data["FirstName"].apply(lambda x: x.split(' ')[0])
        data["LastName"] = data["LastName"].apply(lambda x: x.split(' ')[0])
        # Make all the characters in the FirstName and LastName lower case
        data["FirstName"] = data["FirstName"].apply(lambda x: x.lower())
        data["LastName"] = data["LastName"].apply(lambda x: x.lower())

        # Update the data in the class
        self.data[data_name] = data

    # def split_by_args(self, 
    #                     data_name: str,):
    #     '''
    #     Split the data by gymnasts' gender and store the splitted data in the class with a prefix name data_name and "women" + data_name.

    #     Input:
    #         data_name: string, the name of the data to split. Default is None, which means the data is the default data in the class.

    #     Output:
    #         None
    #     '''
    #     grouped_data = self._group(col_name="Gender", data_or_data_name=data_name, store_into=None)
    #     # create a dictionary of DataFrames, with each DataFrame corresponding to a group
    #     keys = grouped_data.groups.keys()
    #     for key in keys:
    #         self._add_or_replace_data(grouped_data.get_group(key), key + "_" + data_name)

    # summary each athlete's performance on each apparatus
    def summary_for_each_athlete_by_gender(self, data_name: str = "default_data", store_into: str = None):
        '''
        Summary each athlete's performance on each apparatus. And the Score column is the average score of all the available apparatus.

        Input:
            data_name: string, the name of the data to summary. Default is None, which means the data is the default data in the class.

        Output:
            summary_data: pd.DataFrame, the summary data
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Get the data to summary, this should be a pointer to the data in the class
        data = self.data[data_name].copy(deep=True)

        # first group the data by gymnast's FirstName and LastName
        grouped_data = self._group(col_name=["FirstName", "LastName"], data_or_data_name=data_name, store_into=None)
        # Get all the apparatus
        apparatus_ls = self.data[data_name]["Apparatus"].unique()
        # Create an empty DataFrame with the same columns as the original data, and the same number of rows as the number of groups in the grouped_data(pd.DataFrameGroupBy)
        summary_data = pd.DataFrame(columns=self.data[data_name].columns, index=range(len(grouped_data)))
        # Delete the "Apparatus" column
        del summary_data["Apparatus"]
        # Add columns to the individual_summary_data given by the apparatus_ls
        for apparatus in apparatus_ls:
            summary_data[apparatus+"_score"] = np.nan
            summary_data[apparatus+"_num_of_samples"] = 0
        # Iterate over each group, and calculate the average score for each apparatus
        idx = 0
        for key, group in grouped_data:
            individual_grouped_data = self._group(col_name="Apparatus", data_or_data_name=group, store_into=None)
            # Create a new DataFrame to store the summary data for this individual
            individual_summary_data = pd.DataFrame(columns=group.columns)
            # Copy the first row of the group to the individual_summary_data
            individual_summary_data.loc[idx] = group.iloc[0]
            # Delete the "Apparatus" column
            del individual_summary_data["Apparatus"], individual_summary_data["index"]
            # Add columns to the individual_summary_data given by the apparatus_ls
            for apparatus in apparatus_ls:
                individual_summary_data[apparatus+"_score"] = np.nan
                individual_summary_data[apparatus+"_num_of_samples"] = 0
            # Iterate over each apparatus within this individual group, and calculate the average score for each apparatus
            for apparatus, sub_group in individual_grouped_data:
                # Calculate the average score
                average_score = sub_group["Score"].mean()
                num_of_samples = sub_group["Score"].count()
                # Add the average score to corresponding apparatus in the individual_summary_data
                individual_summary_data.loc[idx, apparatus+"_score"] = average_score
                individual_summary_data.loc[idx, apparatus+"_num_of_samples"] = num_of_samples
            # update the "Score" column in the individual_summary_data
            individual_summary_data["Score"] = group["Score"].mean()
            # Append the individual_summary_data to the summary_data at the idx-th row
            summary_data.iloc[idx] = individual_summary_data.iloc[0]
            # summary_data = summary_data.append(individual_summary_data)
            idx += 1
        
        for apparatus in apparatus_ls:
            summary_data[apparatus+"_score"] = pd.to_numeric(summary_data[apparatus+"_score"])
            summary_data[apparatus+"_num_of_samples"] = pd.to_numeric(summary_data[apparatus+"_num_of_samples"])
        summary_data["Score"]
        # Store the summary_data
        if store_into is not None:
            self._add_or_replace_data(summary_data, store_into)
        else:
            return summary_data

    def cluster_by_name(self, 
                            data_name: str = "default_data", 
                            store_into: str = None,):
        '''
        Cluster the data by gymnasts' FirstName and LastName.
        
        Input:
            data_name: string, the name of the data to cluster. Default is None, which means the data is the default data in the class.
            store_into: string, the name of the data to store the clustered data. Default is None, which means the data is not stored in the class.

        Output:
            None
        '''

        # Check if the data_name exists
        self._check_data_name(data_name)
        # Get the data to cluster, this should be a pointer to the data in the class
        df = self.data[data_name].copy(deep=True)

        # # fetch the FirstName and LastName columns from the data
        # FirstName = df["FirstName"]
        # LastName = df["LastName"]
        # # concatenate the FirstName and LastName pointwise
        # Name = FirstName + LastName

        # Calculate the ratio between each pair of names
        potential_matches = {}


        # loop over each row and compare it to all other rows
        for i, row1 in df.iterrows():
            for j, row2 in df.iterrows():
                if i != j:  # skip self-comparisons
                    ratio = fuzz.ratio(row1['FirstName'] + row1['LastName'], row2['FirstName'] + row2['LastName'])
                    if ratio > 80 and row1['Country'] == row2['Country'] and row1['Gender'] == row2['Gender']:  # set a threshold for potential matches
                        if i not in potential_matches:
                            potential_matches[i] = []
                        potential_matches[i].append(j)

        # create a dictionary to store the clusters
        clusters = {}

        # loop over each row and assign it to a cluster
        for i, row in df.iterrows():
            if i not in clusters:
                clusters[i] = []
            clusters[i].append(i)
            if i in potential_matches:
                for j in potential_matches[i]:
                    if j not in clusters[i]:
                        clusters[i].append(j)
                        clusters[j] = clusters[i]

        # For each cluster, find the most common name and country, and replace the other names and countries with the most common name and country
        for cluster in set(map(tuple, clusters.values())):
            # Create a new DataFrame to store the cluster data
            cluster_data = pd.DataFrame(columns=df.columns)
            # Store the cluster data
            for i in cluster:
                cluster_data = cluster_data.append(df.iloc[i])
            # Find the most common name and country
            most_common_firstname = cluster_data["FirstName"].mode()[0]
            most_common_lastname = cluster_data["LastName"].mode()[0]
            # for the most common country, first filter out nan, then find the most common country
            cluster_data_without_nan = cluster_data.dropna(subset=["Country"])
            most_common_country = cluster_data_without_nan["Country"].mode()[0]
            # Replace the other names and countries with the most common name and country in the original data
            for i in cluster:
                df.loc[i, "FirstName"] = most_common_firstname
                df.loc[i, "LastName"] = most_common_lastname
                df.loc[i, "Country"] = most_common_country

        # Store the clustered data
        if store_into is not None:
            self._add_or_replace_data(df, store_into)
        else:
            return df

    def summary_for_each_country_by_gender(self, 
                              data_name: str,
                              country_name: str, 
                              k_top_for_apparatus: int = 3,
                              k_top_for_score: int = 1,
                              max_num_of_gymnasts: int = None,
                              ):
        '''
        Summary each country's performance on each apparatus.

        Input:
            data_name: string, the name of the data to summary. Default is None, which means the data is the default data in the class.
            country_name: string, the name of the country to summary. Default is None, which means the data is the default data in the class.

        Output:
            summary_data: dict, the summary of each country's performance on each apparatus
        '''
        # Check if the data_name exists
        self._check_data_name(data_name)
        # Get the data to summary, this should be a pointer to the data in the class
        data = self.data[data_name]
        # Check if the data still has Apparatus column
        if "Apparatus" in data.columns:
            raise ValueError("It seems that the data still has 'Apparatus' column. Please call the method summary_for_each_athlete() first.")
        
        # Check if the country_name exists
        if country_name not in data["Country"].unique():
            raise ValueError(f"Country name {country_name} does not exist")
        # Filter the data by country_name
        data = self._filter(data_name, lambda x: x["Country"] == country_name)
        if max_num_of_gymnasts is not None:
            data = data.nlargest(max_num_of_gymnasts, "Score")
        

        # check the gender
        gender = data["Gender"].unique()[0]
        # Get all the apparatus for this gender
        if gender == "w":
            apparatus = self.women_apparatus_ls
        else:
            apparatus = self.men_apparatus_ls
        
        # Create a dictionary to store the summary data
        summary_for_country = {country_name: {"data": data}}
        # Find the gymnasts in this country with the highest score on each apparatus
        for apparatus_name in apparatus:
            # Find the gymnast with the top k-highest score on this apparatus
            data["apparatus_name"+"_score"] = pd.to_numeric(data[apparatus_name+"_score"])
            summary_for_country[country_name][apparatus_name] = data.nlargest(k_top_for_apparatus, "apparatus_name"+"_score")
        # Find the gymnast with the top k-highest score
        data["Score"] = pd.to_numeric(data["Score"])
        summary_for_country[country_name]["Score"] = data.nlargest(k_top_for_score, "Score")
        return summary_for_country



        





if __name__ == "__main__":
    Load_data = True
    if Load_data:
        data = Gymnastic_Data_Analyst(load_dir="data/formatted_data/")
    else:
        data = Gymnastic_Data_Analyst(
            data_dir="data/data_2022_2023.csv", data_name="gymnasts")
        data.save_all_data("data/formatted_data/")
    summary_data = data.summary_for_each_country_by_gender(
        data_name="summary_men_gymnasts", country_name="COL", k_top_for_apparatus=4, k_top_for_score=2)
    # Store the summary_data into a text file
    with open("data/summary_data.txt", "w") as f:
        f.write(str(summary_data))

    # Get a list of countries with the most number of gymnasts
    num_of_gymnasts = {}
    for country in data.data["gymnasts"]["Country"].unique():
        num_of_gymnasts[country] = data.data["gymnasts"].loc[data.data["gymnasts"]
            ["Country"] == country].shape[0]
    sorted_num_of_gymnasts = sorted(
        num_of_gymnasts.items(), key=lambda x: x[1], reverse=True)
    # Select the top 12 countries
    top_24_countries = [country for country,
        num in sorted_num_of_gymnasts[:24]]
    # Let's select 12 countries from "summary_men_gymnasts"
    men_countries = top_24_countries[:12]
    # Let's select 12 countries from "summary_women_gymnasts",
    women_countries = top_24_countries[:12]

    # Use data.summary_for_each_country_by_gender method to get the summary data for each country, and append the summary data to the summary_data
    qual_men_12_team = {}
    max_num_of_gymnasts = 5
    for men_country in men_countries:
        # Get the summary data for each country by data.summary_for_each_country_by_gender method
        summary_data_for_country = data.summary_for_each_country_by_gender(
            data_name="summary_men_gymnasts", country_name=men_country, k_top_for_apparatus=4, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (max_num_of_gymnasts, len(data.men_apparatus_ls)), where each column has four 1's and the rest are 0's
        matrix = np.zeros((max_num_of_gymnasts, len(data.men_apparatus_ls)))
        for i in range(len(data.men_apparatus_ls)):
            ones_indices = np.random.choice(
                max_num_of_gymnasts, size=4, replace=False)
            matrix[ones_indices, i] = 1
        # Add the matrix to the summary_data_for_country['data'] DataFrame and add columns according to the apparatus list
        for j, apparatus in enumerate(data.men_apparatus_ls):
            summary_data_for_country[men_country]['data'][apparatus+ \
                "_qual_participation"] = matrix[:, j]
        # append the matrix as an item in the dictionary
        summary_data_for_country[men_country]['qual_participation'] = matrix
        # Append the summary data to the summary_data
        qual_men_12_team.update(summary_data_for_country)



    # For women gymnasts, do the same
    qual_women_12_team = {}
    max_num_of_gymnasts = 5
    for women_country in women_countries:
        # Get the summary data for each country by data.summary_for_each_country_by_gender method
        summary_data_for_country = data.summary_for_each_country_by_gender(
            data_name="summary_women_gymnasts", country_name=women_country, k_top_for_apparatus=4, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (num_gymnasts, len(data.women_apparatus_ls)), where each row has four 1's and the rest are 0's
        matrix = np.zeros((max_num_of_gymnasts, len(data.women_apparatus_ls)))
        for i in range(len(data.women_apparatus_ls)):
            ones_indices = np.random.choice(
                len(data.women_apparatus_ls), size=4, replace=False)
            matrix[ones_indices, i] = 1
        # Add the matrix to the summary_data_for_country['data'] DataFrame and add columns according to the apparatus list
        for j, apparatus in enumerate(data.women_apparatus_ls):
            summary_data_for_country[women_country]['data'][apparatus+ \
                "_qual_participation"] = matrix[:, j]
        # append the matrix as an item in the dictionary
        summary_data_for_country[women_country]['qual_participation'] = matrix
        # Append the summary data to the summary_data
        qual_women_12_team.update(summary_data_for_country)



    # Let's select 12 countries that are different from the previous 12 countries
    men_countries_12 = top_24_countries[-12:]
    women_countries_12 = top_24_countries[-12:]
    qual_men_36_team = {}
    max_num_of_gymnasts = 3
    for men_country in men_countries:
        # Get the summary data for each country by data.summary_for_each_country_by_gender method
        summary_data_for_country = data.summary_for_each_country_by_gender(
            data_name="summary_men_gymnasts", country_name=men_country, k_top_for_apparatus=4, k_top_for_score=3, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (max_num_of_gymnasts, len(data.men_apparatus_ls))
        matrix = np.random.randint(0, 2, (max_num_of_gymnasts, len(data.men_apparatus_ls)))
        # Add the matrix to the summary_data_for_country['data'] DataFrame and add columns according to the apparatus list
        for j, apparatus in enumerate(data.men_apparatus_ls):
            summary_data_for_country[men_country]['data'][apparatus+ \
                "_qual_participation"] = matrix[:, j]
        summary_data_for_country[men_country]['qual_participation'] = matrix
        # Append the summary data to the summary_data
        qual_men_36_team.update(summary_data_for_country)



    # For women gymnasts, do the same
    qual_women_36_team = {}
    max_num_of_gymnasts = 3
    for women_country in women_countries:
        # Get the summary data for each country by data.summary_for_each_country_by_gender method
        summary_data_for_country = data.summary_for_each_country_by_gender(
            data_name="summary_women_gymnasts", country_name=women_country, k_top_for_apparatus=4, k_top_for_score=3, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (max_num_of_gymnasts, len(data.men_apparatus_ls))
        matrix = np.random.randint(0, 2, (max_num_of_gymnasts, len(data.women_apparatus_ls)))
        # Add the matrix to the summary_data_for_country['data'] DataFrame and add columns according to the apparatus list
        for j, apparatus in enumerate(data.women_apparatus_ls):
            summary_data_for_country[women_country]['data'][apparatus+ \
                "_qual_participation"] = matrix[:, j]
        summary_data_for_country[women_country]['qual_participation'] = matrix
        # Append the summary data to the summary_data
        qual_women_36_team.update(summary_data_for_country)


    
