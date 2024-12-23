########################################### Djikstra Components ###########################################

class HeapSort:
	static func _sort(a: Dictionary, b: Dictionary) -> bool:
		return a["cost"] < b["cost"]

# Dijkstra's algorithm implementation with multiple goals and path recalling
func path_multi_goal(graph: Dictionary, start: String, goals: Array, HEURISTIC_RATIO:int) -> Dictionary:
	# Return dictionary
	var return_dict = {}
	# Priority queue
	var queue = []
	# Initialize the queue with the start and its 0 cost
	queue.append({"cost": 0, "node": start})

	# Distance dictionary to track the shortest path costs
	# Initialize all distances to infinity
	var distances = {}
	for key in graph.keys():
		distances[key] = INF
	distances[start] = 0

	# Visited notes 
	# var visited = {}

	# Previous node in the path
	var previous = {}

	while queue.size() > 0:
		# Sort the queue based on cost
		queue.sort_custom(HeapSort._sort)
		var current_cost = queue[0]["cost"]
		var current_node = queue[0]["node"]
		queue.remove_at(0)

		# Explore neighbors
		for neighbor in graph[current_node].keys():
			var new_cost = current_cost + graph[current_node][neighbor]
			if new_cost < distances[neighbor]:
				distances[neighbor] = new_cost
				# Track the previous node for the path
				previous[neighbor] = current_node 
				queue.append({"cost": new_cost, "node": neighbor})  
				
		################## Djisktra is a greedy algorithm, it is the shortest path to a goal with a non heuristic based approach... ##################
		
		# It can have BAD consequences on the decision making and the complexity calcualtion of the path
		if current_node in goals:
			if return_dict.has("distance"):
				if current_cost < return_dict["distance"]:
					return_dict = {
						"distance": current_cost,
						"path": reconstruct_path(previous, start, current_node)
					}
			else:
				return_dict = {
					"distance": current_cost,
					"path": reconstruct_path(previous, start, current_node)
				}

	# Return the shortest path cost and the path
	if return_dict.has("distance"):
		return return_dict

	# Return INF for infinity if no goals are reachable
	return {"distance": INF, "path": []} 

# Function to recall the path from start to goal
func reconstruct_path(previous: Dictionary, start: String, goal: String) -> Array:
	var path = []
	var current = goal
	while current != start and previous.has(current):
		path.append(current)
		current = previous[current]
	path.append(start)
	path.reverse()
	return path
