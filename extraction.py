import pandas as pd
import json


data = pd.read_csv('data/data_marks.csv', sep=',', header=None)
values = data.iloc[1:,1:].values.astype(int)

bike_reponses = []
car_reponses = []
bus_reponses = []
walk_reponses = []
for rep in values :
    for i in range(0,6) :
        bike_reponses.append(rep[i])
        car_reponses.append(rep[6+i])
        bus_reponses.append(rep[12+i])
        walk_reponses.append(rep[18+i])



def moy_rep(rep) :
    moy = []
    nb_participant = len(rep)//6
    for i in range(6) :
        somme = 0
        for j in range(nb_participant):
            somme += rep[i+6*j]
        moy.append((somme/nb_participant)/6)
    return moy

with open('data/param_switch.json', 'w') as file:
    json.dump({"bike":moy_rep(bike_reponses),"car":moy_rep(car_reponses),"bus":moy_rep(bus_reponses),"walk":moy_rep(walk_reponses)}, file)

