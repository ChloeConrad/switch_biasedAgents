import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json


def remove_no_responses(data):
    responses = np.array(data.iloc[:, :].values)
    new_responses = responses.copy()
    cpt = 0
    for res in responses:
        if res[9] == "Je souhaite continuer.":
            new_responses[cpt] = res
            cpt += 1
    return new_responses[0:cpt, 10:]


def nbr_transport_users(rep, transp):
    cpt = 0
    for participant in rep:
        if (participant[1] == transp):
            cpt += 1
    return cpt


def extract_modes_users_responses(rep, transport_mode):
    transport_mode_response = rep.copy()
    cpt = 0
    for participant_response in rep:
        if (participant_response[1] == transport_mode):
            transport_mode_response[cpt] = participant_response
            cpt += 1
    return transport_mode_response[0:cpt, :]


def extract_modes_nonusers_responses(responses, transport):
    transport_mode_response = responses.copy()
    cpt = 0
    for participant_response in responses:
        if (participant_response[1] != transport):
            transport_mode_response[cpt] = participant_response
            cpt += 1
    return transport_mode_response[0:cpt, :]


def extract_marks(responses):
    marks = np.zeros((responses.shape[0], 24))
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


def nonusers_marks(transp_nonusers_responses, transport):
    marks = np.zeros((transp_nonusers_responses.shape[0], 6))
    cpt = 0
    for participant_responses in transp_nonusers_responses:
        if (transport == "bike"):
            marks_part = participant_responses[16:22]
            marks_part_without_nan = []
            for mark in marks_part:
                if (mark in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]):
                    marks_part_without_nan.append(mark)
            marks[cpt] = marks_part_without_nan
            cpt += 1
        elif (transport == "car"):
            marks_part = participant_responses[23:29]
            marks_part_without_nan = []
            for mark in marks_part:
                if (mark in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]):
                    marks_part_without_nan.append(mark)
            marks[cpt] = marks_part_without_nan
            cpt += 1
        elif (transport == "bus"):
            marks_part = participant_responses[30:36]
            marks_part_without_nan = []
            for mark in marks_part:
                if (mark in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]):
                    marks_part_without_nan.append(mark)
            marks[cpt] = marks_part_without_nan
            cpt += 1
        elif (transport == "walk"):
            marks_part = participant_responses[37:43]
            marks_part_without_nan = []
            for mark in marks_part:
                if (mark in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]):
                    marks_part_without_nan.append(mark)
            marks[cpt] = marks_part_without_nan
            cpt += 1
    return marks

# Retourne un tableau à deux dimensions dans lequel chaque ligne représente les réponse d'un participant
# Pour chaque participant, la liste contient l'ensemble de ses réponses sur l'importance des critères dans son choix


def extract_preference(responses):
    preferences = np.empty((responses.shape[0], 6))
    cpt = 0
    for participant_response in responses:
        preferences_user = participant_response[10:16]
        # Correction inversement de l'ordre des réponses dans le questionnaire
        fastness = preferences_user[5]
        safety = preferences_user[4]
        preferences_user[4] = fastness
        preferences_user[5] = safety
        preferences[cpt] = preferences_user

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
    # Lignes ci-dessus à décommenter pour utilisation du script avec les vraies données du questionnaire
    #if transp_mode != "":
        # with open("data/marks_"+transp_mode+"_users.json", 'w') as file:
            # json.dump(dico_results, file)

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
        fast_responses += participant_preferences[4]
        safety_reponses += participant_preferences[5]

    preferences = [(ecology_reponses/cpt_participants)/10, (confort_reponses/cpt_participants)/10, (cheap_reponses/cpt_participants)/10,
                   (practicity_reponses/cpt_participants)/10, (fast_responses/cpt_participants)/10, (safety_reponses/cpt_participants)/10]

    # Ligne ci-dessus à décommenter pour utilisation du script avec les vraies données du questionnaire
    #with open("data/preferences_"+transp_mode+"_users.json.json", 'w') as file:
    #    json.dump({"preferences": preferences}, file)

    return preferences


def plot_results_marks(results, transp_users):
    for transport_type in results.keys():
        keys = ["Ecology", "Confort", "Cheapness",
                "Practicity", "Fastness", "Safety"]
        values = results[transport_type]
        color_list = ['r', 'g', 'b', 'c', 'y', 'm']
        cont = plt.bar(keys, values, color=color_list)
        for i in range(6):
            values[i] = round(values[i], 3)
        plt.bar_label(container=cont, labels=values)
        plt.title(transp_users + " users perceptions on "+transport_type)
        plt.xlabel("Criterion")
        plt.ylabel("marks mean")
        plt.ylim(0, 1)
        plt.show()


def plot_results_preferences(results, transp_users):
    keys = ["Ecology", "Confort", "Cheapness",
            "Practicity", "Fastness", "Safety"]
    values = results
    color_list = ['r', 'g', 'b', 'c', 'y', 'm']
    cont = plt.bar(keys, values, color=color_list)
    for i in range(6):
        values[i] = round(values[i], 3)
    plt.bar_label(container=cont, labels=values)
    plt.title(transp_users + " criterion preferences")
    plt.xlabel("Criterion")
    plt.ylabel("importance values for the transport mode choice mean")
    plt.ylim(0, 1)
    plt.show()


def question_impossible_transp_is_normal(results):
    if (results[4] == "X" and results[5] == "X" and results[6] == "X" and results[7] == "X"):
        return False
    else:
        if ((results[1] == "Le vélo" and results[4] == "X")
           or (results[1] == "Le voiture" and results[5] == "X")
           or (results[1] == "Le vélo" and results[6] == "X")
           or (results[1] == "La marche à pied" and results[7] == "X")):
            return False
    return True


def extract_impossible_transp(results):
    b = question_impossible_transp_is_normal(results)
    impossible_transp = []
    if (not (b)):
        if (float(results[2]) > 15):
            impossible_transp.append('bike')
        if (float(results[2]) > 5):
            impossible_transp.append('walk')
    if (b):
        if (results[4] == 'X'):
            impossible_transp.append('bike')
        if (results[5] == 'X'):
            impossible_transp.append('car')
        if (results[6] == 'X' and float(results[2]) < 1):
            impossible_transp.append('bus')
        if (float(results[2]) > 5 or results[7] == 'X'):
            impossible_transp.append('walk')
    return impossible_transp





def compare_res_user(results, marks, preferences):
    idx_transp = 0
    impossible_transp = extract_impossible_transp(results)
    transp_grades = {'car': 0.0, 'bike': 0.0, 'bus': 0.0, 'walk': 0.0}
    for transp in transport_types:
        grade = 0
        for i in range(6):
            grade += marks[idx_transp*6+i] * preferences[i]
        idx_transp += 1
        transp_grades[transp] = grade

    ordered_choices = dict(sorted(transp_grades.items(),key=lambda x: x[1], reverse=True))
    # return ordered_choices[0]
    for choice in ordered_choices:
        if (choice not in impossible_transp):
            return choice


def compare_res_user_genral(results, marks, preferences):
    idx_transp = 0
    impossible_transp = extract_impossible_transp(results)
    transp_grades = {'car': 0.0, 'bike': 0.0, 'bus': 0.0, 'walk': 0.0}
    for transp in transport_types:
        grade = 0
        for i in range(6):
            grade += marks[transp][i] * preferences[i]
        idx_transp += 1
        transp_grades[transp] = grade

    ordered_choices = dict(sorted(transp_grades.items(),key=lambda x: x[1], reverse=True))
    # return ordered_choices[0]
    for choice in ordered_choices:
        if (choice not in impossible_transp):
            return choice


def plot_compare(results, marks, preferences, transport_type):
    transp_grades = {'car': 0, 'bike': 0, 'bus': 0, 'walk': 0}
    for i in range(results.shape[0]):
        choice_is_rationnal = compare_res_user(
            results[i], marks[i], preferences[i])
        transp_grades[choice_is_rationnal] += 1
    keys = transp_grades.keys()
    values = transp_grades.values()
    color_list = ['r', 'c', 'y', 'm']
    cont = plt.bar(keys, values, color=color_list)
    plt.title("Rationnal choices for "+transport_type+" users")
    plt.xlabel("transport modes")
    plt.ylabel("Number of people that should choose the transport mode")
    plt.bar_label(container=cont, labels=values)
    plt.show()


def plot_compare_to_general(results, marks, preferences, transport_type):
    transp_grades = {'car': 0, 'bike': 0, 'bus': 0, 'walk': 0}
    for i in range(results.shape[0]):
        choice_is_rationnal = compare_res_user_genral(
            results[i], marks, preferences[i])
        transp_grades[choice_is_rationnal] += 1
    keys = transp_grades.keys()
    values = transp_grades.values()
    color_list = ['r', 'c', 'y', 'm']
    cont = plt.bar(keys, values, color=color_list)
    plt.title("Rationnal choices for "+transport_type+" users (method 2)")
    plt.xlabel("transport modes")
    plt.ylabel("Number of people that should choose the transport mode")
    plt.bar_label(container=cont, labels=values)
    plt.show()


def plot_moy_non_users_marks(non_users_marks_on_transp, transp):
    moy_marks = [0, 0, 0, 0, 0, 0]

    for participant_marks in non_users_marks_on_transp:
        for i in range(6):
            moy_marks[i] += participant_marks[i]

    for i in range(6):
        moy_marks[i] = (moy_marks[i]/non_users_marks_on_transp.shape[0])/10

    keys = ["Ecology", "Confort", "Cheapness",
            "Practicity", "Fastness", "Safety"]
    values = moy_marks
    color_list = ['r', 'g', 'b', 'c', 'y', 'm']
    cont = plt.bar(keys, values, color=color_list)
    for i in range(6):
        values[i] = round(values[i], 3)
    plt.bar_label(container=cont, labels=values)
    plt.title("non users perceptions on "+transp)
    plt.xlabel("Criterion")
    plt.ylabel("marks mean")
    plt.ylim(0, 1)
    plt.show()


########################################################################################################
########### MAIN #######################################################################################
########################################################################################################

# Ligne ci-dessus à décommenter pour utilisation du script avec les vraies données du questionnaire
# data = pd.read_csv('data/modes_de_transports_et_perceptions.csv', sep=',', header=None)

# Données de démonstration pour le rendu du projet dans le cadre de l'UE ouverture à la recherche 
# Il s'agit de données fictives, les véritables données du questionnaire ne peuvent pas être publié sur 
# dépot public pour des raisons de confidentialité. 
# La ligne est à commenter pour utilisation du script avec les vraies données du questionnaire
data = pd.read_csv('data/modes_de_transports_et_perceptions.csv', sep='\t', header=None)
test = np.array(data.iloc[:, :].values)
responses = remove_no_responses(data)


dico = {"car": "La voiture", "bike": "Le vélo",
        "walk": "La marche", "bus": "Les transports en commun"}
transport_types = ["bike", "car", "bus", "walk"]

general_marks = extract_marks(responses)
general_marks_means = compute_moy_marks(general_marks, "")
plot_results_marks(general_marks_means, "all")

for transp in transport_types:
    transp_users_responses = extract_modes_users_responses(responses, dico[transp])
    transport_users_marks = extract_marks(transp_users_responses)
    transport_users_preference = extract_preference(transp_users_responses)
    plot_compare(transp_users_responses, transport_users_marks,
             transport_users_preference, transp)
    plot_compare_to_general(
    transp_users_responses, general_marks_means, transport_users_preference, transp)

    marks_results = compute_moy_marks(transport_users_marks, transp)
    preferences_results = compute_moy_preference(
    transport_users_preference, transp)

    transp_nonusers_responses = extract_modes_nonusers_responses(
    responses, transp)
    non_users_marks_on_transp = nonusers_marks(
    transp_nonusers_responses, transp)
    plot_moy_non_users_marks(non_users_marks_on_transp, transp)

# Affichage des résultats obtenus sous forme de diagramme
    plot_results_marks(marks_results, transp)
    plot_results_preferences(preferences_results, transp)
