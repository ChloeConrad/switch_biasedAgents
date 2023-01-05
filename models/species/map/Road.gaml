/**
* Name: Road
* Based on the internal empty template. 
* Author: shloai
* Tags: 
*/


model Road

/** 
 * Road virtual species
 */
species Road skills: [scheduling] {

	// If "foot = no" means pedestrians are not allowed
	string foot;

	// If "bicycle = no" means bikes are not allowed
	string bicycle;

	// If "access = no" means car are not allowed
	string access;

	// If "access = no" together with "bus = yes" means only buses are allowed 
	string bus;

	// Describe if there is parking lane
	string parking_lane;

	// Is used to give information about footways
	string sidewalk;

	// Number of motorized vehicule lane in this road
	int lanes;

	// Can be used to describe any cycle lanes constructed within the carriageway or cycle tracks running parallel to the carriageway.
	string cycleway;

	// Used to double the roads (to have two distinct roads if this is not a one-way road)
	point trans;

	// Border color
	rgb border_color <- #grey;

	// Start crossroad node
	Crossroad start_node;

	// End crossroad node
	Crossroad end_node;

	// Maximum space capacity of the road (in meters)
	float max_capacity <- shape.perimeter * lanes min: 10.0;

	// Actual free space capacity of the road (in meters)
	float current_capacity <- max_capacity min: 0.0 max: max_capacity ;
	
	// Jam treshold
	float jam_treshold <- 0.75;
	
	// Shape
	geometry geom_display;
	
	// First and last points
	point start;
	point end;
	
	// The event manager
	agent event_manager <- EventManager[0];
	
	// The list of transport in this road
	queue<Transport> transports;

	// Waiting queue
	queue<Transport> waiting_transports;

	// Request time of each transport
	map<Transport, date> request_times;

	// Outflow duration
	float outflow_duration <- 1 / (600 / 60) #s;

	// Last out date
	date last_out <- nil;

	// Init the road
	init {
		// Set start and end crossroad
		start_node <- Crossroad closest_to first(self.shape.points);
		end_node <- Crossroad closest_to last(self.shape.points);

		// Set border color
		border_color <- #green;
	}

	// Implement join the road
	action join (Transport transport, date request_time, bool waiting) {
		if waiting {
			do push_in_waiting_queue(transport);
		} else {
			ask transport {
				myself.current_capacity <- myself.current_capacity - size;
				do update_positions(first(myself.start).location);
			}

			// Ask the transport to change road when the travel time is reached
			ask transport {
				do update_positions(myself.location);
			}

			// Compute travel time
			float travel_time <- transport.compute_straight_forward_duration_through_road(self, transport.get_current_target());
		
			// Add data
			do add_request_time_transport(transport, (request_time + travel_time));

			// If this is the first transport
			if length(transports) = 1 {
				do check_first_agent(request_time);
			}
		}
		
		// If capacity is over 75% then traffic jam
		if ((max_capacity - current_capacity) / max_capacity) > jam_treshold and (max_capacity > 25.0) {
			ask get_transports() {
				jam_start <- request_time;
			}
		}

	}

	// Implement leave the road
	action leave (Transport transport, date request_time) {
		// If capacity is lower than 50% then not traffic jam
		if current_capacity / max_capacity <= 0.5 {
			ask get_transports() {
				if jam_duration = nil or jam_start = nil {
					jam_duration <- 0.0;
				} else {
					jam_duration <- jam_duration + (request_time - jam_start);	
				}
			}
		}
//		ask get_transports() {
//			jam_duration <- 0.0;
//		}
		
		// Remove transport (pop first)
		do remove_transport(transport);

		// Update capacity
		ask transport {
			myself.current_capacity <- myself.current_capacity + size;
		}

		// Check and add transport
		do check_waiting(request_time);
	}

	// Implement get size
	float get_size {
		return shape.perimeter;
	}

	// Implement get free flow travel time in secondes (time to cross the road when the speed of the transport is equals to the maximum speed)
	float get_free_flow_travel_time (Transport transport, float distance_to_target) {
		if distance_to_target = nil {
			return get_size() / get_max_freeflow_speed(transport);			
		} else {
			return distance_to_target / get_max_freeflow_speed(transport);			
		}
	}

	/**
	 * Handlers collections
	 */

	// Add transport to waiting queue
	action push_in_waiting_queue (Transport transport) {
		push item: transport to: waiting_transports;
	}

	// Add new transport
	action add_transport (Transport transport) {
		push item: transport to: transports;
	}

	// Add request time transport
	action add_request_time_transport (Transport transport, date request_time) {
		do add_transport(transport);
		add request_time at: transport to: request_times;
	}

	// Implementation get transports
	list<Transport> get_transports {
		return list(transports);
	}

	// Remove transport
	action remove_transport (Transport transport) {
		//Transport first <- pop(transport);
		remove key: transport from: request_times;
	}

	// Clear transports
	action clear_transports {
		remove key: transports from: request_times;
		remove from: transports all: true;
	}
	
	// Exit signal
	action exit_signal {
		do exit(refer_to as Transport, event_date);
	}

	// Exit action
	action exit (Transport transport, date request_time) {
		last_out <- request_time;
		ask transport {
			do update_positions(myself.end);
			do change_road(request_time);
		}

	}

	// Implement end
	action end_road (Transport transport, date request_time) {
		if last_out = nil {
			do exit(transport, request_time);
		} else {
			float delta <- (request_time - last_out);
			if delta >= outflow_duration {
				do exit(transport, request_time);
			} else {
				// If the transport has crossed the road
				date signal_date <- request_time + (outflow_duration - delta);

				// If the signal date is equals to the actual step date then execute it directly
				if signal_date = (starting_date + time) {
					do exit(transport, request_time + (outflow_duration - delta));
				} else {
					do later the_action: exit_signal at: request_time + (outflow_duration - delta) refer_to: transport;
				}

			}

		}

	}

	// Implement end
	action end_road_signal {
		do end_road(refer_to as Transport, event_date);
	}

	/**
	 * Waiting agents
	 */

	// Check waiting agents
	action check_waiting (date request_time) {
		do check_first_agent(request_time);
		if length(waiting_transports) > 0 {
			do add_waiting_agents(request_time);
		}

	}

	// Check first transport
	action check_first_agent (date request_time) {
		if not empty(transports) {
			Transport transport <- first(transports);
			date end_road_date;
			if request_time > request_times[transport] {
				end_road_date <- request_time;
			} else {
				end_road_date <- request_times[transport];
			}

			if end_road_date = (starting_date + time) {
				do end_road(transport, end_road_date);
			} else {
				do later the_action: end_road_signal at: end_road_date refer_to: transport;
			}

		}

	}

	// Check if there is waiting agents and add it if it's possible
	action add_waiting_agents (date request_time) {
		// Check if waiting tranport can be join the road
		loop while: not empty(waiting_transports) and has_capacity(first(waiting_transports)) {
			// Get first transport			
			ask pop(waiting_transports) {
				do inner_change_road(myself, request_time);
			}

		}

	}

	/**
	 * Utilities
	 */
	 
	// Compute the travel of incoming transports
	// The formula used is BPR equilibrium formula
	float get_road_travel_time (Transport transport, float distance_to_target) {
		float free_flow_travel_time <- get_free_flow_travel_time(transport, distance_to_target);
		float ratio <- ((max_capacity - current_capacity) / max_capacity);
//		if ratio = 0.0 {
//			ratio <- 0.1;
//		}
		float travel_time <- free_flow_travel_time * (1.0 + 0.15 * ratio ^ 4);
		return travel_time with_precision 3;
	}

	// Just the current capacity
	bool has_capacity (Transport transport) {
		return current_capacity >= transport.size;
	}

	// True if already in the road
	bool check_if_exists (Transport transport) {
		list<Transport> tmp <- (transports + waiting_transports) where (each = transport);
		return length(tmp) > 0;
	}

	// Implement get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return min([transport.max_speed, max_speed]) #km / #h;
	}

		
	// Setup
	action setup {
		shape <- geom_display;
		start <- first(shape.points);
		end <- last(shape.points);
	}

	// Default aspect
	aspect default {
		draw shape + lanes border: border_color color: rgb(255 * ((max_capacity - current_capacity) / max_capacity), 0, 0) width: 3;
	}

}
