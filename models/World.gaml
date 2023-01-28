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
	
	// false si changement environnement non pris en compte, true sinon 
	// Sert à éviter que le reflexe de modifier les notes soit appelé en boucle
	bool modif <- false;
	
	// Déclaration des variables qualitatives d'environnement 
	bool rainy;
	bool temperatureOk;
	bool light;
	bool city;
	bool rush_hour;
	
	// Déclaration des numériques d'environnement 
	float gasPrice;
	float subPrice;
	float ratioCycleWay;
	float busFrequency;
	float busCapacity;
	float carSpeed;
	float bikeSpeed;
	float walkSpeed;
	float busSpeed;

	
	// map qui associe chaque moyen de transport une liste de notes correspondant à 
	// [ecologie, confort, économie,sécurité, praticité, rapidité]
	map<string, list<float>> marks <- create_map(["bike", "car", "bus", "walk"],
												[[1.0,0.25,1.0,0.25,0.75,0.75],
												[0.25,1.0,0.25,0.5,1.0,1.0],
												[0.5,0.75,0.5,1.0,0.75,0.5],
												[1.0,0.5,1.0,0.75,0.5,0.25]]);
												
	init {
		create traveler number: nbrTraveler;
	}
	
	
	reflex modify_marks_env when: modif=false{
		list<float> bike_marks <- marks["bike"];
		list<float> walk_marks <- marks["walk"];
		list<float> car_marks <- marks["car"];
		list<float> bus_marks <- marks["bus"];
		
		// Modification des notes des moyens de transport en cas de pluie
		if(rainy = true) {
			write("rainy");
			// Le vélo devient moins confortable et plus dangereux
			put bike_marks[1]/2 in: bike_marks at: 1;
			put bike_marks[3]/2 in: bike_marks at: 3;
			put bike_marks in: marks at: "bike";
			
			// La marche devient moins confortable 
			put walk_marks[1]/2 in: walk_marks at: 1;
			put walk_marks in: marks at: "walk";
		
			// La voiture devient plus dangereuse 
			put car_marks[3]/2 in: car_marks at: 3 ;
			put car_marks in: marks at: "car";
		}
		
		// Modification des notes des moyens de transport en cas de mauvaise température
		if(temperatureOk=false) {
			// Le vélo devient moins confortable 
			put bike_marks[1]/2 in: bike_marks at: 1;
			put bike_marks in: marks at: "bike";
			
			// La marche devient moins conforatble 
			put walk_marks[1]/2 in: walk_marks at: 1;
			put walk_marks in: marks at: "walk";
		}
	
		// Modification des notes des moyens de transport quand il fait nuit
		if(temperatureOk=false) {
			// Le vélo devient plus dangereux
			put bike_marks[3]/2 in: bike_marks at: 3;
			put bike_marks in: marks at: "bike";
			
			// La marche devient plus dangereuse  
			put walk_marks[3]/2 in: walk_marks at: 3;
			put walk_marks in: marks at: "walk";
		
			// La voiture devient plus dangereuse 
			put car_marks[3]/2 in: car_marks at: 3 ;
			put car_marks in: marks at: "car";
		}
	
		// Modification des notes des moyens de transport quand nous sommes en ville
		if (city=true) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]/2 in: car_marks at: 4 ;
			put car_marks[5]/2 in: car_marks at: 5 ;
			put car_marks in: marks at: "car";
		}
	
		// Modification des notes des moyens de transport quand nous sommes en ville
		if (rush_hour=true) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]/2 in: car_marks at: 4 ;
			put car_marks in: marks at: "car";
		}
		
		// La voiture devaint plus cher quand le prix de l'escence augmente et inversement
		put car_marks[2]*(1.95/gasPrice) in: car_marks at: 2;
		
		// Le bus devient plus cher quand le prix de l'abonnement augmente et inversement
		put bus_marks[2]*(65.5/subPrice) in: bus_marks at: 2;
		
		// Le vélo devient plus sûr et plus rapide quand la proportion d'axe équipés de pistes cyclable augmente
		put bike_marks[3]*(ratioCycleWay/50.0) in: bike_marks at:3;
		put bike_marks[5]*(ratioCycleWay/50.0) in: bike_marks at:5;
		
		// Le bus devient plus rapide quand la fréquence de passage augmente 
		put bus_marks[5]*(busFrequency/10.0) in: bus_marks at: 5;
		
		// Le bus devient plus confortable quand la capacité augmente 
		put bus_marks[1]*(busCapacity/100.0) in: bus_marks at: 5;
		
		// Augmentation de la rapidité des moyens de transport avec leur vitesse 
		put walk_marks[5]*(walkSpeed/6.4) in: walk_marks at: 5;
		put bus_marks[5]*(busSpeed/10.0) in: bus_marks at: 5;
		put car_marks[5]*(carSpeed/42.3) in: car_marks at: 5;
		put bike_marks[5]*(bikeSpeed/14.0) in: bike_marks at: 5;
		
		
		modif <- true;
	}
	

}



experiment switch type: gui {
	
	// Context initialization 
	parameter "Agents number" category:"Agents" var: nbrTraveler init: 100;
	
	parameter "Is it rainy ?" category:"Context" var: rainy <- false among:[false, true];
	parameter "Is the Temperature ok ?" category:"Context" var: temperatureOk <- true among:[true, false];
	parameter "Is it during the day ?" category:"Context" var: light <- true among:[true, false];
	parameter "Is it in a big city ?" category:"Context" var: city <- true among:[true, false];
	parameter "Is it during the rush hour ?" category:"Context" var: rush_hour <- false among:[true, false];

	parameter "How much is the gas per liter price ? (Euros)" category:"Environnement" var: gasPrice init: 1.95;
	parameter "How much is the public transport subscription price ? (Euros)" category:"Environnement" var: subPrice init: 65.5;
	parameter "How many roads are equipped with cycle ways ? (%)" category:"Environnement" var: ratioCycleWay init: 50.0;
	parameter "What is the average bas frequency ? (per hours)" category:"Environnement" var: busFrequency init: 10.0;
	parameter "How many people can fit in a bus ?" category:"Environnement" var: busCapacity init: 100.0;
	parameter "What is the car average speed ? (km/h)" category:"Environnement" var: carSpeed init: 42.3;
	parameter "What is the bike average speed ? (km/h)" category:"Environnement" var: bikeSpeed init: 14.0;
	parameter "What is the bus average speed ? (km/h)" category:"Environnement" var: busSpeed init: 10.0;
	parameter "What is the walking average speed ? (km/h)" category:"Environnement" var: walkSpeed init: 6.4;
	
	output {
		
	}
	 
}
	
	

	





/* Insert your model definition here */

