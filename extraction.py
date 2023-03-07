import pandas as pd
import numpy as np
import json


data = pd.read_csv('data/data_new_form.csv', sep=',', header=None)
rep = np.array(data.iloc[1:,1:].values)

dico = {"car":"La voiture", "bike":"Le vélo", "walk":"La marche", "bus":"Les transports en commun"}
transport_types = ["bike","car","bus","walk"]

# Supprimme les commentaires écrits par les participants des réponses récoltées
def delete_comments(rep):
    return rep[:,:-5]

# Calcul la moyenne des valeurs contenues dans rep
def mean(list_elem) :
        
        moy = []
        nb_participant = len(list_elem)//6
        if(nb_participant==0) :
            return [0,0,0,0,0,0]

        for i in range(6) :
            somme = 0
            for j in range(nb_participant):
                somme += list_elem[i+6*j]
            moy.append((somme/nb_participant)/6)
        return moy

# Crée un Json contenant les notes qu'on attribuer l'ensemble des participants aux différents moyens de transports
def extract_general_marks(values) : 
    values = delete_comments(values)
    values = values[:,:-1].astype(int)

    bike_reponses = []
    car_reponses = []
    bus_reponses = []
    walk_reponses = []

    for value in values :
        for i in range(0,6) :
            bike_reponses.append(value[i])
            car_reponses.append(value[6+i])
            bus_reponses.append(value[12+i])
            walk_reponses.append(value[18+i])

    with open('data/param_switch.json', 'w') as file:
        json.dump({"bike":mean(bike_reponses),"car":mean(car_reponses),"bus":mean(bus_reponses),"walk":mean(walk_reponses)}, file)

def extract_special_marks(values, transp_type) :
    values = delete_comments(values)
    transp = dico[transp_type]
    values_transp = []
    for part in values :
        if(part[len(part)-1]==transp) :
            values_transp.append(part)
    
    bike_reponses = []
    car_reponses = []
    bus_reponses = []
    walk_reponses = []
    for part in values_transp :
        for i in range(0,6) :
            bike_reponses.append(int(part[i]))
            car_reponses.append(int(part[6+i]))
            bus_reponses.append(int(part[12+i]))
            walk_reponses.append(int(part[18+i]))

    with open("data/param_switch_"+transp_type+".json", 'w') as file:
        json.dump({"bike":mean(bike_reponses),"car":mean(car_reponses),"bus":mean(bus_reponses),"walk":mean(walk_reponses)}, file)

extract_general_marks(rep)

for transp in transport_types :
    extract_special_marks(rep,transp)
