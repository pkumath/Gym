from formatted_code import Gymnastic_Data_Analyst
import numpy as np
import pandas as pd
from collections import defaultdict


def data_prep(Load_data=True):
    if Load_data:
        data = Gymnastic_Data_Analyst(load_dir="data/formatted_data/")
    else:
        data = Gymnastic_Data_Analyst(
            data_dir="data/data_2022_2023.csv", data_name="gymnasts")
        data.save_all_data("data/formatted_data/")
    summary_data = data.summary_for_each_country_by_gender(
        data_name="summary_men_gymnasts", country_name="COL", k_top_for_apparatus=5, k_top_for_score=2)
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
            data_name="summary_men_gymnasts", country_name=men_country, k_top_for_apparatus=5, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (max_num_of_gymnasts, len(data.men_apparatus_ls)), where each column has four 1's and the rest are 0's
        matrix = np.zeros((max_num_of_gymnasts, len(data.men_apparatus_ls)))
        
        # choose 1 to attend individual all-around
        random_index = np.random.randint(matrix.shape[0])
        # Set all elements in the randomly selected person row to 1
        matrix[random_index, :] = 1

        # choose another 3 for each apparatus
        gymnast_index_list = list(range(max_num_of_gymnasts))
        gymnast_index_list.remove(random_index)

        for i in range(len(data.men_apparatus_ls)):
            ones_indices = np.random.choice(
                gymnast_index_list, size=3, replace=False)
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
            data_name="summary_women_gymnasts", country_name=women_country, k_top_for_apparatus=5, k_top_for_score=2, max_num_of_gymnasts=max_num_of_gymnasts)
        # Create a random matrix of size (num_gymnasts, len(data.women_apparatus_ls)), where each row has four 1's and the rest are 0's
        matrix = np.zeros((max_num_of_gymnasts, len(data.women_apparatus_ls)))

        # choose 1 to attend individual all-around
        random_index = np.random.randint(matrix.shape[0])
        # Set all elements in the randomly selected person row to 1
        matrix[random_index, :] = 1

        # choose another 3 for each apparatus
        gymnast_index_list = list(range(max_num_of_gymnasts))
        gymnast_index_list.remove(random_index)

        for i in range(len(data.women_apparatus_ls)):
            ones_indices = np.random.choice(
                gymnast_index_list, size=3, replace=False)
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
        # choose 1 to attend individual all-around
        random_index = np.random.randint(matrix.shape[0])
        # Set all elements in the randomly selected person row to 1
        matrix[random_index, :] = 1
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
        # choose 1 to attend individual all-around
        random_index = np.random.randint(matrix.shape[0])
        # Set all elements in the randomly selected person row to 1
        matrix[random_index, :] = 1
        # Add the matrix to the summary_data_for_country['data'] DataFrame and add columns according to the apparatus list
        for j, apparatus in enumerate(data.women_apparatus_ls):
            summary_data_for_country[women_country]['data'][apparatus+ \
                "_qual_participation"] = matrix[:, j]
        summary_data_for_country[women_country]['qual_participation'] = matrix
        # Append the summary data to the summary_data
        qual_women_36_team.update(summary_data_for_country)
        
    return data, qual_men_12_team, qual_men_36_team, qual_women_12_team, qual_women_36_team


def qual_result_36_country_all_around_helper(qual_participation_matrix, qual_apparatus_score_matrix): 
    """
    individual_all_around_qual_score: dict {name:sum of six apparatus score} 
    """  
    # first identify row with all ones (those who attended all apparatus)
    rows_with_ones = np.all(qual_participation_matrix == 1, axis=1)
    total_score = np.sum(qual_apparatus_score_matrix[rows_with_ones], axis = 1)
    # print(qual_apparatus_score_matrix)
    # print(rows_with_ones)
    # print(total_score)
    # Get the indices of rows with all 1's
    indices = np.where(rows_with_ones)[0]
    # an individual_all_around_qual_score dict {gymnast_name: total_score}
    individual_all_around_qual_score = {idx:total_score[i] for i, idx in enumerate(indices)}
    
    return individual_all_around_qual_score
   
# individual all around for team_36 (12 teams)

def qual_result_36_country_all_around(team_36, apparatus_ls):
    """
    return a dictionary of {(country, name): sum of six score} in team_36 (12 countries)
    """
    individual_all_around_result = dict() # (country, name): sum of six score
    for country_name in team_36:
        team_36[country_name]["individual_all_around_qual_score"] = dict()
        qual_participation_matrix = team_36[country_name]['qual_participation']
        qual_apparatus_score_matrix = list()
        for j, apparatus in enumerate(apparatus_ls):
            qual_apparatus_score = team_36[country_name][apparatus]["apparatus_name_score"] # top k score in this apparatus
            qual_apparatus_score_matrix.append(qual_apparatus_score)
        qual_apparatus_score_matrix = np.nan_to_num(np.array(qual_apparatus_score_matrix).T) # replace all nan with 0 score
        #print(qual_apparatus_score_matrix)
          
        individual_all_around_qual_score = qual_result_36_country_all_around_helper(qual_participation_matrix, qual_apparatus_score_matrix)
        for idx, score in individual_all_around_qual_score.items():
            individual_all_around_result[(country_name, idx)] = score
            # add to each country's dict
            team_36[country_name]["individual_all_around_qual_score"][idx] = score 
    return individual_all_around_result
                


def qual_result_12_country_all_around(qual_participation_matrix, qual_apparatus_score_matrix):
    
    """
    individual_all_around_qual_score: dict {name:sum of six apparatus score}
    team_all_around_qual_score: float, sum of [sum of top 3 scores of each apparatus]
    team_all_around_binary_matrix: 0,1 matrix (np.array), team_all_around top 3 gymnasts for each apparatus
    
    """
    # calculate qualifying round score for each apparatus (choose top 3)
    qual_score_matrix = qual_participation_matrix*qual_apparatus_score_matrix
    top_3_values = np.partition(-qual_score_matrix, 3, axis=0)[:3, :]
    # Compute the indices of top 3 values
    top_3_indices = np.argpartition(-qual_score_matrix, 3, axis=0)[:3, :]
    # Create a binary matrix indicating the positions of the top 3 elements
    team_all_around_binary_matrix = np.zeros(qual_score_matrix.shape)
    for i in range(top_3_indices.shape[1]):  # for each column
        team_all_around_binary_matrix[top_3_indices[:, i], i] = 1
    # Convert top 3 values to positive (since we negated them earlier)
    top_3_values = -top_3_values
    # Summing up the top 3 values in each column
    team_all_around_qual_score = np.sum(np.sum(top_3_values, axis=0))
    
    
    # individual all around
    # first identify row with all ones (those who attended all apparatus)
    rows_with_ones = np.all(qual_participation_matrix == 1, axis=1)
    total_score = np.sum(qual_apparatus_score_matrix[rows_with_ones], axis = 1)
  
    # Get the indices of rows with all 1's
    indices = np.where(rows_with_ones)[0]
    # an individual_all_around_qual_score dict {gymnast_name: total_score}
    individual_all_around_qual_score = {idx:total_score[i] for i, idx in enumerate(indices)}
    
    return team_all_around_qual_score, team_all_around_binary_matrix, individual_all_around_qual_score


def all_around_result(teams, apparatus_ls):
    """
    teams: [qual_men_12_team, qual_men_36_team] or [qual_women_12_team, qual_women_36_team]
    apparatus_ls: data.men_apparatus_ls or data.women_apparatus_ls
    """
    
    ######## team all around 
    team_12_all_around_result = dict()
    individual_all_around_result = dict() # (country, name): sum of six score
    team_12 = teams[0]
    team_36 = teams[1]
    for country_name in team_12:
        qual_participation_matrix = team_12[country_name]['qual_participation']
        qual_apparatus_score_matrix = list()
        for j, apparatus in enumerate(apparatus_ls):
            ###scores don't match!!!!!!!!!!!
            qual_apparatus_score = team_12[country_name][apparatus]["apparatus_name_score"] # top k score in this apparatus
            qual_apparatus_score_matrix.append(qual_apparatus_score)
        qual_apparatus_score_matrix = np.nan_to_num(np.array(qual_apparatus_score_matrix).T) # replace all nan with 0 score
        
        
        # individual and team_12 all around qual results
        sum_top_3_values, team_12_all_around_binary_matrix, individual_all_around_qual_score = qual_result_12_country_all_around(qual_participation_matrix, qual_apparatus_score_matrix)
        team_12[country_name]["sum_top_3_values"] = sum_top_3_values
        team_12[country_name]["team_12_all_around_binary_matrix"] = team_12_all_around_binary_matrix
        team_12[country_name]["individual_all_around_qual_score"] = individual_all_around_qual_score
        team_12[country_name]["qual_team_12_all_around_score"] = qual_apparatus_score_matrix
        team_12_all_around_result[country_name] = sum_top_3_values
        # team_12 all around ranking: Get the top 8 countries
        team_all_around_sorted_countries = sorted(team_12_all_around_result.items(), key=lambda x: x[1], reverse=True)
        top_8_countries = [country for country, score in team_all_around_sorted_countries[:8]]


        for idx, score in individual_all_around_qual_score.items():
            individual_all_around_result[(country_name, idx)] = score
        
            
    ######## individual_all_around qual result  
    # add in team_36
    team_36_individual_all_around = qual_result_36_country_all_around(team_36, apparatus_ls)
    individual_all_around_result.update(team_36_individual_all_around)
    sorted_athletes = sorted(individual_all_around_result.items(), key=lambda x: x[1], reverse=True)
    
    # select top 24
    # Dictionary to hold the top 24 athletes, ensuring not more than 2 athletes per country
    top_24_athletes = {}
    
    # record number of atheletes who gets into individual final round, should be <= 2
    country_count = defaultdict(int)
    for athlete, score in sorted_athletes:
        country, idx = athlete
        
        # Ensure not more than 2 athletes per country are selected
        if country_count[country] < 2:
            top_24_athletes[athlete] = score
            country_count[country] += 1
        
        # Stop when 24 athletes have been selected
        if len(top_24_athletes) == 24:
            break
    individual_all_around_top_24_athletes = sorted(top_24_athletes.items(), key=lambda x: x[1], reverse=True)
    top_24_athletes = [i for i, score in individual_all_around_top_24_athletes[:24]]
    
    return  team_all_around_sorted_countries,top_8_countries, individual_all_around_top_24_athletes, top_24_athletes

    

def predict(apparatus, dict_of_qual_result):   
    sorted_athletes = sorted(dict_of_qual_result.items(), key=lambda x: x[1], reverse=True)
    # Dictionary to hold the top 24 athletes, ensuring not more than 2 athletes per country
    top_8_athletes = {}
    # record number of atheletes who gets into individual final round, should be <= 2
    country_count = defaultdict(int)
    for athlete, score in sorted_athletes:
        country, idx = athlete
        
        # Ensure not more than 2 athletes per country are selected
        if country_count[country] < 2:
            top_8_athletes[athlete] = score
            country_count[country] += 1
        
        # Stop when 24 athletes have been selected
        if len(top_8_athletes) == 8:
            break
    individual_all_around_top_24_athletes = sorted(top_8_athletes.items(), key=lambda x: x[1], reverse=True)
    top_8_athletes = [i for i, score in sorted_athletes[:8]]
    # add noise to final round     
    dict_of_final_result = {i: score+np.random.normal(0,1) for i, score in sorted_athletes[:8]}
    sorted_athletes_final = sorted(dict_of_final_result.items(), key=lambda x: x[1], reverse=True)
    top_3_athletes = [i for i, score in sorted_athletes_final[:3]]

    return top_8_athletes, sorted_athletes, top_3_athletes, sorted_athletes_final


def each_apparatus_result(teams, apparatus_ls):
    """
    teams: [qual_men_12_team, qual_men_36_team] or [qual_women_12_team, qual_women_36_team]
    apparatus_ls: data.men_apparatus_ls or data.women_apparatus_ls
    """
    team_12_all_around_result = dict()
    individual_all_around_result = dict() # (country, name): sum of six score
    team_12 = teams[0]
    team_36 = teams[1]
    apparatus_ls_dict = dict()
    for apparatus in apparatus_ls:
        apparatus_ls_dict[apparatus] = dict()
        
    for country_name in team_12:
        qual_participation_matrix = team_12[country_name]['qual_participation']
        qual_apparatus_score_matrix = list()
        for j, apparatus in enumerate(apparatus_ls):
            ###scores don't match!!!!!!!!!!!
            qual_apparatus_score = team_12[country_name][apparatus]["apparatus_name_score"] # top k score in this apparatus
            qual_apparatus_score_matrix.append(qual_apparatus_score)
        qual_apparatus_score_matrix = np.nan_to_num(np.array(qual_apparatus_score_matrix).T) # replace all nan with 0 score
        each_apparatus_participation_score = qual_apparatus_score_matrix*qual_participation_matrix
        for col in range(len(apparatus_ls)):
            for row in range(each_apparatus_participation_score.shape[0]):
                if each_apparatus_participation_score[row,col] != 0:
                    apparatus_ls_dict[apparatus_ls[col]][(country_name, row)] = each_apparatus_participation_score[row,col]
    #add team_36
    for country_name in team_36:
        qual_participation_matrix = team_36[country_name]['qual_participation']
        qual_apparatus_score_matrix = list()
        for j, apparatus in enumerate(apparatus_ls):
            ###scores don't match!!!!!!!!!!!
            qual_apparatus_score = team_36[country_name][apparatus]["apparatus_name_score"] # top k score in this apparatus
            qual_apparatus_score_matrix.append(qual_apparatus_score)
        qual_apparatus_score_matrix = np.nan_to_num(np.array(qual_apparatus_score_matrix).T) # replace all nan with 0 score
        each_apparatus_participation_score = qual_apparatus_score_matrix*qual_participation_matrix
        for col in range(len(apparatus_ls)):
            for row in range(each_apparatus_participation_score.shape[0]):
                if each_apparatus_participation_score[row,col] != 0:
                    apparatus_ls_dict[apparatus_ls[col]][(country_name, row)] = each_apparatus_participation_score[row,col]
    final_result_all_apparatus_dict = dict()                
    for apparatus in apparatus_ls:
        top_8_athletes, sorted_athletes, top_3_athletes, sorted_athletes_final = predict(apparatus, apparatus_ls_dict[apparatus]) #dict_of_qual_result = {(country, name): score} 
        final_result_all_apparatus_dict[apparatus] = [top_8_athletes, sorted_athletes, top_3_athletes, sorted_athletes_final]
    
    return final_result_all_apparatus_dict



def team_all_around_result(team, apparatus_ls, top_8_countries):
    team_12_all_around_final_result = dict()
    ######### predict final round result for team all around
    team12 = team
    for country_name in top_8_countries:
        top3_binary_matrix = team12[country_name]["team_12_all_around_binary_matrix"]
        noise = np.random.normal(0, 1, top3_binary_matrix.shape)
        team12[country_name]["team_12_all_around_final_result"] = top3_binary_matrix*(team12[country_name]["qual_team_12_all_around_score"]+noise)
        team12[country_name]["team_12_all_around_final_total_score"] = np.sum(np.sum(team12[country_name]["team_12_all_around_final_result"], axis=0))
        
        team_12_all_around_final_result[country_name] = team12[country_name]["team_12_all_around_final_total_score"]
    team_all_around_sorted_countries = sorted(team_12_all_around_final_result.items(), key=lambda x: x[1], reverse=True)
    top_3_countries = [country for country, score in team_all_around_sorted_countries[:3]]
    return top_3_countries,team_all_around_sorted_countries

#predict final round result for indiv all around
def indiv_all_around_result(teams, apparatus_ls, individual_all_around_top_24_athletes):
    team12 = teams[0]
    team36 = teams[1]
    individual_all_around_final_result = dict()
    for (country, name), score in individual_all_around_top_24_athletes:
        team = team12 if country in team12 else team36
        indiv_qual_score = score #team[country]["individual_all_around_qual_score"][name]
        noise = np.random.normal(0, 1)
        result = np.sum(indiv_qual_score)+noise
        individual_all_around_final_result[(country, name)] = result
        #print(team12[country_name]["team_12_all_around_final_result"]-team12[country_name]["qual_team_12_all_around_score"])
    individual_all_around_final_sorted = sorted(individual_all_around_final_result.items(), key=lambda x: x[1], reverse=True)
    top_3_athletes = [i for i, score in individual_all_around_final_sorted[:3]]


    return top_3_athletes, individual_all_around_final_sorted


def qual_and_final_result_display(teams, indiv_all_around_top3,individual_all_around_final_sorted,\
    final_result_all_apparatus_dict, team_all_around_top3, team_all_around_sorted_countries):
    #print("Team all around final round result:")
    for rank, (country,score) in enumerate(team_all_around_sorted_countries):
        print(rank+1, country, score)

    team12 = teams[0]
    team36 = teams[1]
    
    print("\nIndividual all around final round result:")
    for rank, ((country, name), score) in enumerate(individual_all_around_final_sorted):
        
        team = team12 if country in team12 else team36
        # pick some apparatus to get list of gymnasts name
        app = list(team12[country].keys())[0]
        gymnast_real_index = list(team12[country][app].index)
        print(rank+1, country, gymnast_real_index[name], score)
        
    print('\nEach Apparatus final round results:')
    for apparatus, result in final_result_all_apparatus_dict.items():
        top_8_athletes, sorted_athletes, top_3_athletes, sorted_athletes_final = result
        print(apparatus)
        for rank, ((country, name), score) in enumerate(sorted_athletes_final):
            team = team12 if country in team12 else team36
            # pick some apparatus to get list of gymnasts name
            app = list(team12[country].keys())[0]
            gymnast_real_index = list(team12[country][app].index)
            print(rank+1, country, gymnast_real_index[name], score)
            
    
        
        
def medal_summarize_and_display(teams, indiv_all_around_top3,final_result_all_apparatus_dict, team_all_around_top3, display=False):
    # 1:gold, 2:silver, 3: bronze
    medal_dict = {1:"Gold", 2:"Silver", 3: "Bronze"}
    medal_result_by_country = defaultdict(lambda: defaultdict(int))
    for rank, (country,name) in enumerate(indiv_all_around_top3):
        medal_result_by_country[country][rank+1]+=1
        
    for rank, country in enumerate(team_all_around_top3):
        medal_result_by_country[country][rank+1]+=1
   
    for apparatus, result in final_result_all_apparatus_dict.items():
        _,_, top_3_athletes, _ = result
        for rank, (country, name) in enumerate(top_3_athletes):
            medal_result_by_country[country][rank+1]+=1
    if display:
        # print the metal results for each country who wins at least one metal
        for country in medal_result_by_country:
            print('\n',country)
            for i,num_medal in medal_result_by_country[country].items():      
                print(medal_dict[i] + ": ", num_medal)
                
    return medal_result_by_country

            

    

def run_simulations(times=1000, display=False, gender="women"):
    """
    apparatus_ls = data.men_apparatus_ls # simulate men 
    apparatus_ls = data.men_apparatus_ls # simulate women 
    """
    all_simiulations = []
   
    data, qual_men_12_team, qual_men_36_team, qual_women_12_team, qual_women_36_team = data_prep()
    medal_total = {'Country Names': list(qual_men_12_team.keys()) + list(qual_men_36_team.keys())}
    if gender == 'men':
        apparatus_ls = data.men_apparatus_ls
        teams = [qual_men_12_team, qual_men_36_team]    
    else:
        apparatus_ls = data.women_apparatus_ls
        teams = [qual_women_12_team, qual_women_36_team]    

    
    for i in range(times):    
        # each apparatus ranking
        team_all_around_sorted_countries_score,top_8_countries, individual_all_around_top_24_athletes, top_24_athletes = all_around_result(teams, apparatus_ls)
        # individual all around ranking: Get the top 24 countries
        final_result_all_apparatus_dict = each_apparatus_result(teams, apparatus_ls)
        team_all_around_top3, team_all_around_sorted_countries = team_all_around_result(teams[0], apparatus_ls, top_8_countries)
        #print(team_all_around_top3, team_all_around_sorted_countries)
        indiv_all_around_top3,individual_all_around_final_sorted = indiv_all_around_result(teams, apparatus_ls, individual_all_around_top_24_athletes)
        if display:    
            qual_and_final_result_display(teams, indiv_all_around_top3,individual_all_around_final_sorted,final_result_all_apparatus_dict, team_all_around_top3, team_all_around_sorted_countries)  
        medal_counts_by_country = medal_summarize_and_display(teams, indiv_all_around_top3, final_result_all_apparatus_dict, team_all_around_top3)
        medal_total_in_current_simulation = []
        for country in medal_total['Country Names']:
            # calculate total medal numbers for each country
            medal_total_in_current_simulation.append(int(np.sum(list(medal_counts_by_country[country].values()))))
        medal_total["simulation"+str(i+1)] = medal_total_in_current_simulation
        # regular_dict = {country: dict(medals) for country, medals in medal_counts_by_country.items()}
        # all_simiulations.append(regular_dict)

    # Create a pandas DataFrame
    df = pd.DataFrame(medal_total)
    # Write the DataFrame to a CSV file
    df.to_csv(gender+'_total_number_of_medals_results.csv', index=False)
        
if __name__ == "__main__":
    run_simulations(1000, gender="men")  
    run_simulations(1000, gender="women")      
        



        

