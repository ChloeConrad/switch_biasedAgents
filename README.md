# Mini Switch
## Présentation du projet
Mini Switch est un système multi-agents dans lequel les agents doivent choisir un moyen de transport quotidien selon des critères. Ces critères peuvent être quantitatifs (prix de l'essence, prix de l'abonnement aux transports en commun, vitesse moyenne des moyens de transport) et qualitatifs (présence de pluie, température normale). Le choix des agents est réalisé en fonction de leur perception de l'écologie, du confort, de l'accessibilité financière, de la praticité, de la sécurité et du confort de chaque moyen de transport. Des valeurs d’importances attribuées à chaque critère sont aussi utilisées. Ces paramètres ont été estimés grâce à ce questionnaire : https://framaforms.org/modes-de-transports-et-perceptions-1679935991.
Le projet se structure en deux grandes parties. Le développement de la simulation en Gaml et le traitement des données obtenues grâce au questionnaire en Python.
## Simulation
Pour lancer la simulation, il est nécessaire d'installer la plateforme Gama : https://gama-platform.org/download. Ensuite, les modalités pour importer le projet dans la plateforme sont détaillées ici : https://gama-platform.org/wiki/ImportingModels#import-gama-project.
### Lancement de la simulation
Une fois le projet importé dans la plateforme, le lancement de la simulation se fait à partir du fichier world.gaml situé à la location User models/switch_biasedAgents/models. Une fois ce fichier ouvert, un bouton vert "switch" devrait être présent en haut à gauche. L'utilisation de ce bouton permet l'ouverture de la page de lancement de la simulation.
Sur cette page, il est possible de modifier les paramètres via les onglets de gauche. Pour que les modifications soient prises en compte, il est nécessaire de les valider dans l'onglet confirmation. Si aucune modification n'est faite, les valeurs par défaut des paramètres seront utilisées.
Ensuite, le lancement de la simulation se fait via le bouton "run" présent en haut de la page.
### Fichiers Gaml
* World.gaml : description de l'environnement de la simulation, de ses paramètres (nombre d'agents, paramètres quantitatifs et qualitatifs) et définition de l'interface graphique de la simulation.
*Context.gaml : Définition des valeurs par défaut des paramètres de l'environnement.
*Traveler.gaml : Description globale des agents, de leurs paramètres (préférences, notes) et de leurs comportements (choix d'un moyen de transport, biais).
###Dossier data
Le dossier data contient les fichiers JSON dans lesquels sont stockées les valeurs des paramètres (préférences et notes) utilisées par les agents dans la simulation.
##Traitement des données du questionnaire
Le traitement des données obtenues via le questionnaire se fait grâce au fichier extraction.py présent à la racine du projet. Dans la version présente sur ce dépôt, le script utilise les données présentes dans le fichier demo.csv du dossier data. Ce fichier contient des données fictives. Les véritables réponses des participants ne peuvent pas être mises à disposition sur ce dépôt pour des raisons de respect des lois portant sur l'utilisation de données personnelles.
# Calibrage de la simulation Mini Switch
Le but principal du traitement des données était d'extraire les moyennes des notes attribuées à chaque critère pour chaque moyen de transport à partir des réponses au questionnaire. Pour cela, nous avons pris en compte plusieurs populations :
* L’entièreté de la population des répondants au questionnaire.
* Les répondants ayant pour moyen de transport quotidien la voiture.
* Les répondants ayant pour moyen de transport quotidien les transports en commun.
* Les répondants ayant pour moyen de transport quotidien le vélo.
* Les répondants ayant pour moyen de transport quotidien la marche.
 Les résultats obtenus grâce à ce traitement ont été utilisés pour calibrer la simulation Mini Switch.
### Évaluation de la rationalité des participants

De plus, les données disponibles nous ont permis d'évaluer le nombre de participants au questionnaire ayant fait un choix rationnel par rapport à leur réponse. Deux méthodes ont été utilisées à cet effet. La première consistait à calculer, pour chaque moyen de transport, la somme de la note attribuée par le participant à chaque critère multipliée par la valeur d'importance donnée à ce critère. La seconde méthode était similaire, mais en prenant en compte la somme de la note moyenne attribuée par l'ensemble des participants multipliée par l'importance du critère attribué par le participant. Ainsi, le moyen de transport donnant le résultat le plus élevé était considéré comme le choix rationnel pour le participant. Si ce choix diffère du moyen de transport quotidien déclaré par le participant, ce dernier était considéré comme non rationnel. Dans ce calcul, les moyens de transport déclarés comme indisponibles par le participant ne sont pas pris en compte. De plus, certains moyens de transport comme la marche ou le vélo sont éliminés en fonction de la distance séparant le lieu d'habitation et le lieu d'activité principale.
### résultats

Les résultats obtenus du traitement des réponses des participants sont présentés sous forme de diagrammes dans le sous-dossier "résultats" du dossier "data".

