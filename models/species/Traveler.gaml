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
	map<string, float> criteria_preference;
	
	float proportion_conf;
	float proportion_forb;
	float proportion_est;
	// représente les choix déjà effectué par l'agent [nbrChoixVélo, nbrChoixVoiture, nbrChoixBus, nbrChoixMarche]
	map<string, int> habits;
	
	init {
		id <- rnd(200);
		fitness <- rnd(100.0);
		work_dist <- rnd(20.0);
	
									
		habits <- create_map(["bike","car","bus","walk"],[rnd(10),rnd(10),rnd(10),rnd(10)]);
		
		int max <- -1;
		string max_choice_transp;
		loop transp over: ["bike", "car", "bus", "walk"] {
			if(self.habits[transp]>max){
				max <- self.habits[transp];
				max_choice_transp <- transp;
			}
		}
		// a décocher quand réponses au questionnaire 
		file marks_file <- json_file("../data/marks_"+max_choice_transp+"_users.json");	
		// Pour remplacer ça :
		////////////////////////////////////////////////////////////////////////////////////////////////
		//file marks_file;
		//if(max_choice_transp = "bus"){
		//	marks_file <- json_file("../data/param_switch_bus.json");	
		//}
		//else {
		//	marks_file <- json_file("../data/param_switch.json");
		//}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		personal_marks <- marks_file.contents;
		write(personal_marks);
		criteria_preference <- create_map(["ecology", "comfort", "cheap", "safety", "praticity", "fast"],[rnd(1.0),rnd(1.0),rnd(1.0),rnd(1.0),rnd(1.0),rnd(1.0)]);
	}
	
	
	
	action apply_conf_bias {
		int max <- -1;
		string max_choice_transp;
		loop transp over: ["bike", "car", "bus", "walk"] {
			if(self.habits[transp]>max){
				max <- self.habits[transp];
				max_choice_transp <- transp;
			}
		}
		
		loop transp over: ["bike", "car", "bus", "walk"] {
			list<float> marks <- self.personal_marks[transp];
			loop i from: 0 to: 5 { 
				write(marks);
				float mark <- marks[i];
				
				if(transp = max_choice_transp){
					put mark+gauss(mark/2,mark/4) in: marks at:i;
			
				}
				else {
					put mark-gauss(mark/2,mark/4) in: marks at:i;
				}
			}
		
		}
	
	}
	
	action apply_est_bias {
		loop transp over: ["car"]{
			list<float> marks <- self.personal_marks[transp];
			loop i from: 0 to: 5 { 
				float mark <- marks[i];
				put mark+gauss(mark/2,mark/4) in: marks at:i;
			}
		}
		loop transp over: ["bus","walk"]{
			list<float> marks <- self.personal_marks[transp];
			loop i from: 0 to: 5 { 
				float mark <- marks[i];
				put mark-gauss(mark/2,mark/4) in: marks at:i;
			}
		}
		
	}
	
	
	action apply_forb_bias {
		
	}
	
	action apply_preference {
		loop transp over: ["car","bike","bus","walk"]{
			list<float> marks <- self.personal_marks[transp];
			int cpt <- 0;
			loop crit over: ["ecology", "comfort", "cheap", "safety", "praticity", "fast"] {
				float mark <- marks[cpt];
				float crit_pref <- criteria_preference[crit];
				put mark*crit_pref in: marks at: cpt;
				cpt <- cpt + 1;
			}
		}
	}
	
	reflex choose{
		
		float det <- rnd(1.0);
		if(det < self.proportion_conf){
			do apply_conf_bias;
		}
		det <- rnd(1.0);
		if(det<self.proportion_est) {
			do apply_est_bias;
		}
		det <- rnd(1.0);
		if(det<self.proportion_forb){
			do apply_forb_bias;
		}
		do apply_preference;
		do ban_with_distance;
		
		float max_somme <- -1.0;
		string transp_max_somme;
		loop transp over: ["bike", "car", "bus", "walk"] {
			float somme <- 0.0;
			list<float> marks <- self.personal_marks[transp];
			loop mark over: marks {
				somme <- somme + mark;
			}
			if(somme > max_somme) {
				max_somme <- somme;
				transp_max_somme <- transp;
			}
		}
		
		put  self.habits[transp_max_somme]+1 in: self.habits at: transp_max_somme;
		
		choice <- transp_max_somme;
		
	}
	
	action ban_with_distance {
		// Si l'agent est très sportif, il peut prendre le vélo pour des trajets de moins de 20km et la marche à pied pour des trajets de moins de 5km
		// Lorsqu'il peut marcher ou faire du vélo, les notes de ces moyens de transports sont doublées
		if(self.fitness > 90.0){
			if(self.work_dist > 5.0) {
				list<float> walk_marks <- self.personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-0;
     			}	
     			put walk_marks in: self.personal_marks at: "walk";	
			} else {
				list<float> walk_marks <- self.personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-walk_marks[i]*2;
     			}	
     			put walk_marks in: self.personal_marks at: "walk";	
			}
			if (work_dist>20){
				list<float> bike_marks <- self.personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-0;
     			}
     			put bike_marks in: self.personal_marks at: "bike";	
			} else {
				list<float> bike_marks <- self.personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-bike_marks[i]*2;
     			}
     			put bike_marks in: self.personal_marks at: "bike";
			}
		} 
		
		// Si l'agent est très peu sportif, il ne prend jamais le vélo ou la marche à pieds
		else if ( self.fitness < 10.0) {
		
			list<float> walk_marks <- self.personal_marks["walk"];
			list<float> bike_marks <- self.personal_marks["bike"];
			loop i from: 0 to: length(walk_marks) - 1 { 
				walk_marks[i]<-0;
				bike_marks[i]<-0;
     		}	
     		put walk_marks in: self.personal_marks at: "walk";	
     		put bike_marks in: self.personal_marks at: "bike";	
		} 
		
		// Si l'agent à un niveau de sport dans la norme, il peut prendre le vélo pour des trajets de moins de 8km et la marche pour des trajets de moins de 2 km
		else {
			if(self.work_dist > 2.0) {
				list<float> walk_marks <- self.personal_marks["walk"];
				loop i from: 0 to: length(walk_marks) - 1 { 
					walk_marks[i]<-0;
     			}	
     			put walk_marks in: self.personal_marks at: "walk";	
			} else if (self.work_dist > 8.0){
				list<float> bike_marks <- self.personal_marks["bike"];
				loop i from: 0 to: length(bike_marks) - 1 { 
					bike_marks[i]<-0;
     			}
     			put bike_marks in: self.personal_marks at: "bike";	
			}
		}
	}
}



