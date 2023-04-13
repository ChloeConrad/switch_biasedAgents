# Simulation Mini Switch 

## Présentation du projet

Mini Switch est un système multi agents dans lequel les agents doivent choisir un moyen de transports quotidien selon des critères. Ces critères peuvent être quantitatifs (prix de l’essence, prix de l'abonnement aux transports en commun, vitesse moyenne de moyens de transports) et qualitatifs (présence de pluie, la température est normale). Le choix des agents est réalisé en fonction de leurs perceptions de l'écologie, le confort, l'accessibilité financière, la praticité, la sécurité et le confort de chaque moyen de transport. Ces paramètres ont alors été estimés grâce à ce questionnaire : https://framaforms.org/modes-de-transports-et-perceptions-1679935991. 

Le projet se structure alors en deux grandes partie. Le développement de la simulation en Gaml et le traitement des données obtenues grâce au questionnaire en python.

## Simulation


## Traitement des données du questionnaire

Le traitement des données obtenues via le questionnaire se fait grâce au fichier extraction.py présent à la racine du projet. Dans la version présente sur ce dépôt, le script utilise les données présentent dans le fichier demo.csv du dossier data. Ce fichier contient des données fictives. Les véritables réponses des participants ne peuvent pas être mis à disposition sur ce dépôt pour des raisons de respects des lois portant sur l'utilisation de données personnelles.

### Calibrage de la simulation Mini Switch

Le but principal du traitement des données était d’extraire des réponses du questionnaire les moyennes des notes attribuées aux critères pour chaque moyen de transport. Pour cela, nous avons pris en compte plusieurs populations. En effet, nous avons extrait la moyenne des notes attribuées par l’ensemble de la population de participant au questionnaire. Nous avons également extrait ces notes par population d’utilisateurs des différents moyens de transport. Les résultats extraient de ce traitement servent à calibrer la simulation Mini Switch.

### Évaluation de la rationalité des participants

D’un autre côté, les données disponibles permettaient aussi d’évaluer le nombre de participant au questionnaire faisant un choix rationnel par rapport à leur réponse. Pour cela, deux méthodes ont été utilisées. La première consistait à calculer pour chaque moyen de transport la somme de la note attribuée par le participant à chaque critère multiplié par la valeur d’importance donné à ce critère. La seconde méthode était similaire à la première mais en prenant en compte la somme de la note moyenne attribuée par l’ensemble des participants multiplié par l’importance du critère attribué par le participant. Ainsi, le moyen de transport donnant le résultat le plus haut sera considéré comme le choix rationnel pour le participant. Si celui-ci diffère du moyen de transport quotidien déclaré par le participant, ce dernier sera considéré comme non rationnel. Dans ce calcul, les moyens de transports déclarés comme indisponible par le participant ne sont pas pris en compte. De plus, certain moyen de transports comme la marche ou le vélo sont éliminés en fonction de la distance séparant le lieu d’habitation et le lieu d’activité principale.

### résultats 

Les résultats obtenus du traitement des réponses des participants sont présentés sous forme de diagrammes dans le sous-dossier résultats du dossier data.
