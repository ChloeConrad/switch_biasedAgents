/**
* Name: World
* Based on the internal empty template. 
* Author: shloai
* Tags: 
*/

model switch_biasedAgents

import "species/Traveler.gaml"



global {
	int nbrTraveler;
	
	bool rainy;
	bool temperatureOk;
	bool light;
	bool city;
	bool rush_hour;
	list<bool> context;
	
	float gasPrice;
	float subPrice;
	float ratioCycleWay;
	float busFrequency;
	float busCapacity;
	float carSpeed;
	float bikeSpeed;
	float walkSpeed;
	float busSpeed;
	
}


experiment switch type: gui {
	
	// Context initialization 
	parameter "Agents number" category:"Agents" var: nbrTraveler init: 100;
	parameter "Is it rainy ?" category:"Context" var: rainy <- false among:[false, true];
	parameter "Is the Temperature ok ?" category:"Context" var: temperatureOk <- true among:[true, false];
	parameter "Is it during the day ?" category:"Context" var: light <- true among:[true, false];
	parameter "Is it in a big city ?" category:"Context" var: city <- true among:[true, false];
	parameter "Is it during the rush hour ?" category:"Context" var: rush_hour <- false among:[true, false];
	list<bool> context_list <- [rainy,temperatureOk,light,city,rush_hour];
	
	// Environnement variables initialization
	parameter "How much is the gas per liter price ? (Euros)" category:"Environnement" var: gasPrice init: 1.95;
	parameter "How much is the public transport subscription price ? (Euros)" category:"Environnement" var: subPrice init: 65.5;
	parameter "How many roads are equipped with cycle ways ? (%)" category:"Environnement" var: ratioCycleWay init: 50.0;
	parameter "What is the average bas frequency ? (per hours)" category:"Environnement" var: busFrequency init: 10.0;
	parameter "How many people can fit in a bus ?" category:"Environnement" var: busCapacity init: 100.0;
	parameter "What is the car average speed ? (km/h)" category:"Environnement" var: carSpeed init: 42.3;
	parameter "What is the bike average speed ? (km/h)" category:"Environnement" var: bikeSpeed init: 14.0;
	parameter "What is the bus average speed ? (km/h)" category:"Environnement" var: busSpeed init: 10.0;
	parameter "What is the walking average speed ? (km/h)" category:"Environnement" var: bikeSpeed init: 6.4;
	
}
	
	

	





/* Insert your model definition here */

