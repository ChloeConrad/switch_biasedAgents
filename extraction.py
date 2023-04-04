import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json

def nbr_transport_users(rep,transp) :
    cpt = 0
    for participant in rep :
        if (participant[1] == transp) :
            cpt += 1
    return cpt

def extract_modes_users_responses(rep, transport_mode): 
    transport_mode_response = rep.copy()
    cpt = 0
    for participant_response in rep:
        if (participant_response[1] == transport_mode):
            transport_mode_response[cpt] = participant_response
            cpt += 1
    return transport_mode_response[0:cpt,:]


def extract_marks(responses):
    marks = np.zeros((responses.shape[0],24))
    cpt = 0
    for participant_responses in responses:
        marks_part = participant_responses[16:]
        marks_part_without_nan = []
        for mark in marks_part:
            if (mark in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]):
                marks_part_without_nan.append(mark)
        marks[cpt] = marks_part_without_nan
        cpt += 1
    return marks


def extract_preference(responses):
    preferences = np.empty((responses.shape[0], 6))
    cpt = 0
    for participant_response in responses:
        preferences[cpt] = participant_response[10:16]
        cpt += 1
    return preferences


def mean_list_values(list):
    res = [0, 0, 0, 0, 0, 0]
    if (len(list) == 0):
        return res

    nbr_participant = len(list)//6
    for idx in range(6):
        for participant in range(nbr_participant):
            res[idx] += list[idx+6*participant]

    for idx in range(len(res)):
        res[idx] = (res[idx]/nbr_participant)/10

    return res


def compute_moy_marks(responses, transp_mode):
    bike_reponses = []
    car_reponses = []
    bus_reponses = []
    walk_reponses = []

    for participant_marks in responses:
        for i in range(6):
            bike_reponses.append(int(participant_marks[i]))
            car_reponses.append(int(participant_marks[6+i]))
            bus_reponses.append(int(participant_marks[12+i]))
            walk_reponses.append(int(participant_marks[18+i]))
    
    dico_results = {"bike": mean_list_values(bike_reponses), "car": mean_list_values(car_reponses),
                   "bus": mean_list_values(bus_reponses), "walk": mean_list_values(walk_reponses)}

    with open("data/marks_"+transp_mode+"_users.json", 'w') as file:
        json.dump(dico_results, file)
    return dico_results


def compute_moy_preference(responses, transp_mode):
    ecology_reponses = 0
    confort_reponses = 0
    cheap_reponses = 0
    practicity_reponses = 0
    safety_reponses = 0
    fast_responses = 0

    cpt_participants = 0

    for participant_preferences in responses:
        cpt_participants += 1
        ecology_reponses += participant_preferences[0]
        confort_reponses += participant_preferences[1]
        cheap_reponses += participant_preferences[2]
        practicity_reponses += participant_preferences[3]
        safety_reponses += participant_preferences[4]
        fast_responses += participant_preferences[5]

    preferences = [(ecology_reponses/cpt_participants)/10, (confort_reponses/cpt_participants)/10, (cheap_reponses/cpt_participants)/10,
                   (practicity_reponses/cpt_participants)/10, (safety_reponses/cpt_participants)/10, (fast_responses/cpt_participants)/10]

    with open("data/preferences_"+transp_mode+"_users.json.json", 'w') as file:
        json.dump({"preferences": preferences}, file)
    
    return preferences

def plot_results_marks(results, transp_users) :
    for transport_type in results.keys() : 
        keys = ["Ecology","Confort", "Cheapness", "Practicity", "Security", "Fastness"]
        values = results[transport_type]
        plt.bar(keys, values)
        plt.title(transp_users+ " users perceptions on "+transport_type)
        plt.ylim(0,1)
        plt.show()

def plot_results_preferences(results, transp_users) :
    keys = ["Ecology","Confort", "Cheapness", "Practicity", "Security", "Fastness"]
    values = results
    plt.bar(keys, values)
    plt.title(transp_users+ " criterion preferences")
    plt.ylim(0,1)
    plt.show()

def extract_impossible_transp(results) :
    impossible_transp = []
    if(float(results[2])>10) : 
        impossible_transp.append('bike')
    elif(float(results[2])>3) :
        impossible_transp.append('walk')
    return impossible_transp

def ordered_transp_by_grades(transp_grades) :
    grades = list(transp_grades.values())
    transports = transport_types.copy()
    ordered_choices = []
    while len(grades) != 0 :
        max_grade = 0
        idx_grade = 0
        transp_max_grade = ''
        for transp in transports :
            if grades[idx_grade] > max_grade :
                max_grade = grades[idx_grade]
                transp_max_grade = transp
            idx_grade += 1
        ordered_choices.append(transp_max_grade)
        transports.remove(transp_max_grade)
        grades.remove(max_grade)
    return ordered_choices

def compare_res_user(results, marks, preferences) :
    idx_transp = 0
    impossible_transp = extract_impossible_transp(results)
    transp_grades = {'car':0.0, 'bike':0.0, 'bus':0.0, 'walk':0.0}
    for transp in transport_types :
        grade = 0
        for i in range(6) :
            grade += marks[idx_transp*6+i] * preferences[i]
        idx_transp += 1
        transp_grades[transp] = grade
    
    ordered_choices = ordered_transp_by_grades(transp_grades)
    return ordered_choices[0]
    # for choice in ordered_choices :
        # if (choice not in impossible_transp) :
            # return choice
    

def plot_compare(results, marks, preferences, transport_type) :
    transp_grades = {'car':0, 'bike':0, 'bus':0, 'walk':0}
    for i in range(results.shape[0]) :
        choice_is_rationnal = compare_res_user(results[i], marks[i], preferences[i])
        transp_grades[choice_is_rationnal] += 1
    keys = transp_grades.keys()
    values = transp_grades.values()
    plt.bar(keys, values)
    plt.title("Rationnal choices for "+transport_type+" users")
    plt.show()

########################################################################################################
########### MAIN #######################################################################################
########################################################################################################
data = pd.read_csv(
    'data/modes_de_transports_et_perceptions.csv', sep=',', header=None)
responses = np.array(data.iloc[0:, 10:].values)

dico = {"car": "La voiture", "bike": "Le vélo",
        "walk": "La marche", "bus": "Les transports en commun"}
transport_types = ["bike", "car", "bus", "walk"]

for transp in transport_types : 
    transp_users_responses = extract_modes_users_responses(responses, dico[transp])
    transport_users_marks = extract_marks(transp_users_responses)
    transport_users_preference = extract_preference(transp_users_responses)
    plot_compare(transp_users_responses,transport_users_marks, transport_users_preference, transp)
    marks_results = compute_moy_marks(transport_users_marks, transp)
    preferences_results = compute_moy_preference(transport_users_preference, transp)

    # Affichage des résultats obtenus sous forme de diagramme
    plot_results_marks(marks_results,transp)
    plot_results_preferences(preferences_results,transp)