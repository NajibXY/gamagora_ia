extends Node2D

var game_node : Node2D
var start_node
var goal_nodes
var nodes_graph
var djikstra_result

## TODO:
	# delete after test
var i = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game scene node ready signal
	game_node = get_node("/root/global_scene_node/game_node")
	game_node.connect("ready_signal", Callable(self, "_on_game_script_ready"))
	pass # Replace with function body.

func _on_game_script_ready() -> void:
	# Initialize car variables for djikstra : start_node, goal_nodes, nodes_graph
	start_node = game_node.tile_map.local_to_map(self.transform.origin)
	goal_nodes = game_node.goal_local_positions
	nodes_graph = game_node.links_dict
	print("Car Variables Ready")
	launch_djikstra()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	launch_djikstra()
	pass

########################################### Djikstra Components ###########################################

func launch_djikstra() -> void:
	## TODO:
		# delete after test
	if i == 4:
		i = 0
	start_node = start_node + Vector2i(0,i)

	print("start_node: ", start_node)
	# goal_nodes = game_node.goal_local_positions
	# nodes_graph = game_node.links_dict
	## TODO:
			# use a signal to recall djikstra when things are modified (targets of tank --> nodes_graph, walls moved, etc)
	djikstra_result = dijkstra_multi_goal(nodes_graph, str(start_node), goal_nodes)
	print("Shortest distance from ", start_node, " to any of ", goal_nodes, ": ", djikstra_result.distance)
	print("Path: ", djikstra_result.path)
	pass

class HeapSort:
	static func _sort(a: Array, b: Array) -> int:
		return -1 if a[0]["cost"] < b[0]["cost"] else 1

class Tuple:
	var x
	var y
	func __init__(a, b):
		x = a
		y = b

# Dijkstra's algorithm implementation with multiple goals and path recalling
func dijkstra_multi_goal(graph: Dictionary, start: String, goals: Array) -> Dictionary:
	# Priority queue
	var queue = []
	# Initialize the queue with the start and its 0 cost
	queue.append({"cost": 0, "node": start})

	# Distance dictionary to track the shortest path costs
	var distances = {}
	for key in graph.keys():
		distances[key] = INF
	distances[start] = 0

	# Visited notes 
	var visited = {}
	# Previous node in the path
	var previous = {}

	while queue.size() > 0:
		# Sort the queue based on cost
		queue.sort_custom(HeapSort._sort)
		var current_cost = queue[0]["cost"]
		var current_node = queue[0]["node"]
		queue.remove_at(0)

		# If we reach a goal node, reconstruct the path
		################## Djisktra is a greedy algorithm, so the first time we reach a goal, it is the shortest path for its non heuristic based approach... ##################
		# It can have BAD consequences on the decision making of the AI, but it is a good start
		if current_node in goals:
			return {
				"distance": current_cost,
				"path": reconstruct_path(previous, start, current_node)
			}

		if visited.has(current_node):
			continue

		visited[current_node] = true
		for neighbor in graph[current_node].keys():
			if not visited.has(neighbor):
				var new_cost = current_cost + graph[current_node][neighbor]
				if new_cost < distances[neighbor]:
					distances[neighbor] = new_cost
					# Track the previous node for the path
					previous[neighbor] = current_node 
					queue.append({"cost": new_cost, "node": neighbor})  
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
