/**
* Name: context
* Based on the internal empty template. 
* Author: shloai
* Tags: 
*/


model switch_biasedAgents

species context {
	bool was_rainy <- false;
	bool was_temperatureOk <- true;
	bool was_light <- true;
	bool was_city <- false;
	bool was_rush_hour <- false;
	
	float gasPriceRef <- 1.95;
	float subPriceRef <- 65.5 ;
	float ratioCycleWayRef <- 50.0;
	float busFrequencyRef<-10.0;
	float busCapacityRef<- 100.0;
	float carSpeedRef <- 42.3;
	float bikeSpeedRef <- 14.0;
	float walkSpeedRef <- 6.4;
	float busSpeedRef <- 10.0;
}

