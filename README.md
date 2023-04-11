Simulation mini switch 
=======

Présentation du projet
-----------
Mini switch est un système multi agents dans lequel les agents doivent choisir un moyen de transports quotidien selon des critères. Ces critères peuvent être quantitatifs (prix de l'escence, prix de l'abonnement aux transports en commun, vitesse moyenne de moyens de transports) et qualitatifs (présence de pluie, la température est normale). Le choix des agents est réalisé en fonction de leur perceptions de l'écologie, le confort, l'accessibilité financière, la pratiité, la sécurité et le confort de chaque moyens de transport. Ces paramètre ont alors été estimé grâce à ce questionnaire : https://framaforms.org/modes-de-transports-et-perceptions-1679935991. 

Le projet se structure alors en deux grandes partie. Le developpement de la simulation en Gaml et le traitement des données obtenus graĉe au questionnaire en python.


Simulation 
----------


Traitement des données du questionnaire
----------
Le traitement des données obtnus via le questionnaire ce fait grâce au fichier extraction.py présent à la racine du projet. Dans la version présente sur ce dépot, le script utilise les données présentent dans le fichier demo.csv du dossier data. Ce fichier contient des données fictives. Les véritables réponses des participants ne peuvent pas être mis à disposition sur ce dépot pour des raison de respects des lois lié à l'utilisation de données personelles.

Les résultats obtenus du traitement des réponses des participants sont présenté sous forme de diagrammes dans le sous-dossier results du dossier data.


