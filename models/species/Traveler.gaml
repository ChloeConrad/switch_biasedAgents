/**
* Name: traveler
* Based on the internal empty template. 
* Author: shloai
* Tags: 
*/


model switch_biasedAgents

species traveler {
	int id;
	float fitness;
	float work_dist;
	string choice;
	map<string, list<float>> personal_marks;
	
	float proportion_conf;
	float proportion_forb;
	float proportion_est;
	// représente les choix déjà effectué par l'agent [nbrChoixVélo, nbrChoixVoiture, nbrChoixBus, nbrChoixMarche]
	list<int> habits;
	
	init {
		id <- length(species(self).population);
		fitness <- rnd(100.0);
		work_dist <- rnd(30.0);
		habits <- [0,0,0,0];
	}
	
	action apply_conf_bias {
		
	}
	
	action apply_est_bias {
		
	}
	
	action apply_forb_bias {
		
	}
	
	reflex choose{
		float det <- rnd(1.0);
		if(det<proportion_conf){
			do apply_conf_bias;
		}
		det <- rnd(1.0);
		if(det<proportion_est) {
			do apply_est_bias;
		}
		det <- rnd(1.0);
		if(det<proportion_forb){
			do apply_forb_bias;
		}
		do ban_with_distance;
		
		
		
	}
	
	action ban_with_distance {
		// Si l'agent est très sportif, il peut prendre le vélo pour des trajets de moins de 20km et la marche à pied pour des trajets de moins de 5km
		// Lorsqu'il peut marcher ou faire du vélo, les notes de ces moyens de transports sont doublées
		if(fitness > 95){
			if(work_dist > 5) {
				list<float> walk_marks <- personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-0;
     			}	
     			put walk_marks in: personal_marks at: "walk";	
			} else {
				list<float> walk_marks <- personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-walk_marks[i]*2;
     			}	
     			put walk_marks in: personal_marks at: "walk";	
			}
			if (work_dist>20){
				list<float> bike_marks <- personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-0;
     			}
     			put bike_marks in: personal_marks at: "bike";	
			} else {
				list<float> bike_marks <- personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-bike_marks[i]*2;
     			}
     			put bike_marks in: personal_marks at: "bike";
			}
		} 
		
		// Si l'agent est très peu sportif, il ne prend jamais le vélo ou la marche à pieds
		else if ( fitness < 5) {
			list<float> walk_marks <- personal_marks["walk"];
			list<float> bike_marks <- personal_marks["bike"];
			loop i from: 0 to: length(walk_marks) - 1 { 
				walk_marks[i]<-0;
				bike_marks[i]<-0;
     		}	
     		put walk_marks in: personal_marks at: "walk";	
     		put bike_marks in: personal_marks at: "bike";	
		} 
		
		// Si l'agent à un niveau de sport dans la norme, il peut prendre le vélo pour des trajets de moins de 8km et la marche pour des trajets de moins de 2 km
		else {
			if(work_dist > 2) {
				list<float> walk_marks <- personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-0;
     			}	
     			put walk_marks in: personal_marks at: "walk";	
			} else if (work_dist>8){
				list<float> bike_marks <- personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-0;
     			}
     			put bike_marks in: personal_marks at: "bike";	
			}
		}
	}
}


/* Insert your model definition here */

