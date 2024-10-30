class HeapSort:
	static func _sort(a: Dictionary, b: Dictionary) -> bool:
		return a["cost"] < b["cost"]
			  
# Manhattan distance heuristic
func manhattan_distance(node_pos: String, goal_pos: String) -> int:
	var node_vec = Vector2i(node_pos.split(",")[0].to_int(), node_pos.split(",")[1].to_int())
	var goal_vec = Vector2i(goal_pos.split(",")[0].to_int(), goal_pos.split(",")[1].to_int())
	return abs(node_vec.x - goal_vec.x) + abs(node_vec.y - goal_vec.y)

# A* algorithm with Manhattan distance heuristic
func a_star_multi_goal(graph: Dictionary, start: String, goals: Array) -> Dictionary:
	# Return dictionary
	var return_dict = {}
	# Priority queue
	var queue = []
	# Initialize the queue with the start node, its 0 cost : link cost + heuristic cost
	queue.append({"cost": 0, "node": start})

	# Distance dictionary to track the shortest path costs
	# Initialize all distances to infinity
	var distances = {}
	for key in graph.keys():
		distances[key] = INF
	distances[start] = 0

	# Previous node in the path
	var previous = {}

	while queue.size() > 0:
		# Sort the queue based on total cost (cost + heuristic)
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
				# Calculate heuristic and add cost to the priority queue 
				var heuristic = INF
				for goal in goals:
					heuristic = min(heuristic, manhattan_distance(neighbor, goal))
				queue.append({"cost": new_cost + heuristic, "node": neighbor})

		#################### A* is a heuristic based algorithm, it is the shortest path to a goal with a heuristic based approach... ####################
		# If the current node is one of the goals, update return_dict with the shortest path and cost
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
