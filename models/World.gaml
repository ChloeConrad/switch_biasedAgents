/**
* Name: World
* Based on the internal empty template. 
* Author: Conrad Chloé 
* Tags: 
*/

model switch_biasedAgents

import "species/Traveler.gaml"
import "species/Context.gaml"


global {
	int nbrTraveler;
	
	// false si changement environnement non pris en compte, true sinon 
	// Sert à éviter que le reflexe de modifier les notes soit appelé en boucle
	bool modif;
	
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
	
	float proportion_conf;
	float proportion_forb;
	float proportion_est;
	
	map<string, int> res;
	
	// map qui associe chaque moyen de transport une liste de notes correspondant à 
	// [ecologie, confort, économie,sécurité, praticité, rapidité]
	map<string, list<float>> marks;
	init {									
		create traveler number: nbrTraveler;
		create context number: 1;
	}
	
	
	reflex modify_marks_env when: modif=true{
		list<traveler> travelers <- traveler.population; 
		loop  trav over: travelers{ 
		list<float> bike_marks <- trav.personal_marks["bike"];
		list<float> walk_marks <- trav.personal_marks["walk"];
		list<float> car_marks <- trav.personal_marks["car"];
		list<float> bus_marks <- trav.personal_marks["bus"];
		
		// Modification des notes des moyens de transport en cas de pluie
		if(rainy = true and rainy != context.population[0].was_rainy) {
			
			// Le vélo devient moins confortable et plus dangereux
			put bike_marks[1]/2 in: bike_marks at: 1;
			put bike_marks[3]/2 in: bike_marks at: 3;
			
			// La marche devient moins confortable 
			put walk_marks[1]/2 in: walk_marks at: 1;
		
			// La voiture devient plus dangereuse 
			put car_marks[3]/2 in: car_marks at: 3 ;
			context.population[0].was_rainy <- true;
		}
		
			// Modification des notes des moyens de transport en cas de pluie
		if(rainy = false and rainy != context.population[0].was_rainy) {
			
			// Le vélo devient moins confortable et plus dangereux
			put bike_marks[1]*2 in: bike_marks at: 1;
			put bike_marks[3]*2 in: bike_marks at: 3;
			
			// La marche devient moins confortable 
			put walk_marks[1]*2 in: walk_marks at: 1;
		
			// La voiture devient plus dangereuse 
			put car_marks[3]*2 in: car_marks at: 3 ;
			context.population[0].was_rainy <- false;
		}
		
		// Modification des notes des moyens de transport en cas de mauvaise température
		if(temperatureOk=false and context.population[0].was_temperatureOk != temperatureOk) {
			// Le vélo devient moins confortable 
			put bike_marks[1]/2 in: bike_marks at: 1;
			
			// La marche devient moins conforatble 
			put walk_marks[1]/2 in: walk_marks at: 1;
			
			context.population[0].was_temperatureOk <- false;
		}
		if(temperatureOk=true and context.population[0].was_temperatureOk != temperatureOk) {
			// Le vélo devient moins confortable 
			put bike_marks[1]*2 in: bike_marks at: 1;
			
			// La marche devient moins conforatble 
			put walk_marks[1]*2 in: walk_marks at: 1;
			
			context.population[0].was_temperatureOk <- true;
		}
		
		// Modification des notes des moyens de transport quand il fait nuit
		if(light=false and context.population[0].was_light != light) {
			// Le vélo devient plus dangereux
			put bike_marks[3]/2 in: bike_marks at: 3;
			
			// La marche devient plus dangereuse  
			put walk_marks[3]/2 in: walk_marks at: 3;
		
			// La voiture devient plus dangereuse 
			put car_marks[3]/2 in: car_marks at: 3 ;
			context.population[0].was_light <- false;
		}
		if(light=true and context.population[0].was_light != light) {
			// Le vélo devient plus dangereux
			put bike_marks[3]*2 in: bike_marks at: 3;
			
			// La marche devient plus dangereuse  
			put walk_marks[3]*2 in: walk_marks at: 3;
		
			// La voiture devient plus dangereuse 
			put car_marks[3]*2 in: car_marks at: 3 ;
			context.population[0].was_light <- true;
		}
	
		// Modification des notes des moyens de transport quand nous sommes en ville
		if (city=true and context.population[0].was_city != city) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]/2 in: car_marks at: 4 ;
			put car_marks[5]/2 in: car_marks at: 5 ;
			context.population[0].was_city <- true;
		}
		if (city=false and context.population[0].was_city != city) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]*2 in: car_marks at: 4 ;
			put car_marks[5]*2 in: car_marks at: 5 ;
			context.population[0].was_city <- false;
		}
	
		// Modification des notes des moyens de transport quand nous sommes en ville
		if (rush_hour=true and context.population[0].was_rush_hour != rush_hour) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]/2 in: car_marks at: 4 ;
			context.population[0].was_rush_hour <- true;
			
		}
		if (rush_hour=false and context.population[0].was_rush_hour != rush_hour) {
			// La voiture devient moins rapide et moins pratique  
			put car_marks[4]*2 in: car_marks at: 4 ;
			context.population[0].was_rush_hour <- false;
			
		}
		
		
		// La voiture devient plus cher quand le prix de l'escence augmente et inversement
		put car_marks[2]*(context.population[0].gasPriceRef/gasPrice) in: car_marks at: 2;
		
		// Le bus devient plus cher quand le prix de l'abonnement augmente et inversement
		put bus_marks[2]*(context.population[0].subPriceRef/subPrice) in: bus_marks at: 2;
		
		// Le vélo devient plus sûr et plus rapide quand la proportion d'axe équipés de pistes cyclable augmente
		put bike_marks[3]*(ratioCycleWay/context.population[0].ratioCycleWayRef) in: bike_marks at:3;
		put bike_marks[5]*(ratioCycleWay/context.population[0].ratioCycleWayRef) in: bike_marks at:5;
		
		// Le bus devient plus rapide quand la fréquence de passage augmente 
		put bus_marks[5]*(busFrequency/context.population[0].busFrequencyRef) in: bus_marks at: 5;
		
		// Le bus devient plus confortable quand la capacité augmente 
		put bus_marks[1]*(busCapacity/context.population[0].busCapacityRef) in: bus_marks at: 5;
		
		// Augmentation de la rapidité des moyens de transport avec leur vitesse 
		put walk_marks[5]*(walkSpeed/context.population[0].walkSpeedRef) in: walk_marks at: 5;
		put bus_marks[5]*(busSpeed/context.population[0].busSpeedRef) in: bus_marks at: 5;
		put car_marks[5]*(carSpeed/context.population[0].carSpeedRef) in: car_marks at: 5;
		put bike_marks[5]*(bikeSpeed/context.population[0].bikeSpeedRef) in: bike_marks at: 5;
		
		context.population[0].gasPriceRef <- gasPrice;
		context.population[0].subPriceRef <- subPrice ;
		context.population[0].ratioCycleWayRef <- ratioCycleWay;
		context.population[0].busFrequencyRef<-busFrequency;
		context.population[0].busCapacityRef<- busCapacity;
		context.population[0].carSpeedRef <- carSpeed;
		context.population[0].bikeSpeedRef <- bikeSpeed;
		context.population[0].walkSpeedRef <- walkSpeed;
		context.population[0].busSpeedRef <- busSpeed;
		
		put car_marks in: trav.personal_marks at: "car";
		put bike_marks in: trav.personal_marks at: "bike";
		put walk_marks in: trav.personal_marks at: "walk";
		put bus_marks in: trav.personal_marks at: "bus";
		
		modif <- false;
		
		}
	}
	
	reflex modif_agents_attributs {
		
		list<traveler> travelers <- traveler.population; 
		loop  trav over: travelers{ 
			
			trav.proportion_conf <- proportion_conf;
			trav.proportion_forb <- proportion_forb;
			trav.proportion_est <- proportion_est;
			
     	}		
	}
	
	reflex get_results {
		res <- create_map(["bike","car","bus","walk"],[0,0,0,0]);
		loop trav over: traveler.population {
			put res[trav.choice]+1 in: res at: trav.choice;
		}
	}
	
	
}



experiment switch type: gui {
	
	// Context initialization 
	parameter "Agents number" category:"Agents" var: nbrTraveler init: 625;
	
	parameter "Is it rainy ?" category:"Context" var: rainy <- false among:[false, true];
	parameter "Is the Temperature ok ?" category:"Context" var: temperatureOk <- true among:[true, false];
	parameter "Is it during the day ?" category:"Context" var: light <- true among:[true, false];
	parameter "Is it in a big city ?" category:"Context" var: city <- false among:[true, false];
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
	
	parameter "What is the proportion affected by the confirmation bias ?" category:"Bias proportions" var: proportion_conf init: 0.5;
	parameter "What is the proportion affected by the under/over estimation bias ?" category:"Bias proportions" var: proportion_est init: 0.5;	
	
	parameter "Would you like to confirm your modification ?" category: confirmation var: modif <- false among:[false,true];
	output {
		display "results" {
        chart "results" type: histogram {
            data "bike" value: res["bike"] color: #red;
            data "car" value: res["car"] color: #blue;
            data "bus" value: res["bus"] color: #green;
            data "walk" value: res["walk"] color: #purple;
        }
    }
	}
	 
}

/* Insert your model definition here */

