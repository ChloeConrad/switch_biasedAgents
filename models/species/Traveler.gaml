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
	
	init {
		id <- length(species(self).population);
		fitness <- gauss_rnd(50,5);
		work_dist <- rnd(20.0);
	}
	
}

/* Insert your model definition here */

