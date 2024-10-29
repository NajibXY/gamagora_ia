extends Node2D

var game_node : Node2D
var start_node
var goal_nodes
var nodes_graph
var djikstra_script
var djikstra_result

const Djisktra = preload("res://scenes/scripts/utils/djikstra.gd")

var is_running 
const speed = 0.2

var initial_start_node
#

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game scene node ready signal
	game_node = get_node("/root/global_scene_node/game_node")
	game_node.connect("ready_signal", Callable(self, "_on_game_script_ready"))
	djikstra_script = Djisktra.new()
	pass # Replace with function body.

func _on_game_script_ready() -> void:
	# Initialize car variables for djikstra : start_node, goal_nodes, nodes_graph
	start_node = game_node.tile_map.local_to_map(self.transform.origin)
	initial_start_node = start_node
	goal_nodes = game_node.goal_local_positions
	nodes_graph = game_node.links_dict
	print("Car Variables Ready")
	is_running = false
	# Init first djisktra
	do_djikstra_things(nodes_graph, str(start_node), goal_nodes)
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_running :
		is_running = true
		iterate_movements(delta)
	pass

##################################### Car movement functions #####################################
func iterate_movements(delta: float) -> void:
	while (djikstra_result["path"].size() != 0):
		# Get the target node
		var target_node = djikstra_result["path"][0]
		target_node = Vector2i(target_node.split(",")[0].to_int(), target_node.split(",")[1].to_int())
		
		var continue_while = true
		# Check if the target node is targetted
		if target_node in game_node.locked_targeted_cells:
			# If the target node is targetted, do djikstra again
			calculate_path_async(game_node.links_dict, game_node.tile_map.local_to_map(self.transform.origin), goal_nodes)
			continue_while = false
			break
		# Check if any remaining node from the djikstra is targetted
		for node_path in djikstra_result["path"]:
			var node_left = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
			if node_left in game_node.locked_targeted_cells:
				print("Doing djikstra")
				calculate_path_async(game_node.links_dict, str(game_node.tile_map.local_to_map(self.transform.origin)), goal_nodes)
				#do_djikstra_things(game_node.links_dict, game_node.tile_map.local_to_map(self.transform.origin), goal_nodes)
				print("Ending djikstra")
				continue_while = false
				break
		if not continue_while:
			is_running = false
			break

		# Make it not as precise as the car is not moving on a grid so that it be 0.1 precision
		var target_pos = game_node.tile_map.map_to_local(target_node)
		target_pos = Vector2(round(target_pos.x), round(target_pos.y))
		while (self.transform.origin != target_pos):
			# TODO tune the speed and the freeze time
			self.transform.origin = self.transform.origin.move_toward(target_pos, delta * speed)
		
		# Pop the first element of the path from djikstra and global path
		# TODO might have a problem if two cars are on the same path
		djikstra_result["path"].erase(djikstra_result["path"][0])
		game_node.global_path_cells.erase(target_node)
		if target_node not in game_node.locked_targeted_cells:
			game_node.change_cell_to_its_original(target_node, game_node.ground_node.get_cell_atlas_coords(target_node))
		
		# Freeze the car for a while
		var time_freeze = 2.0
		if game_node.ground_node.get_cell_atlas_coords(target_node) == game_node.grass_tile_atlas:
			# If the car is on grass, it will move slower
			print("Car is on grass")
			time_freeze = 4.0
		await get_tree().create_timer(time_freeze).timeout

	is_running = false
	pass

##################################### Personnal Djikstra functions #####################################
func do_djikstra_things(nodes_gr, start_no, goal_no) -> void:
	# If djikstra path is not empty, reset the cells if not targeted
	if djikstra_result:
		for node_path in djikstra_result["path"]:
			var node_cell = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
			game_node.global_path_cells.erase(node_cell)
			if node_cell not in game_node.locked_targeted_cells:
				game_node.change_cell_to_its_original(node_cell, game_node.ground_node.get_cell_atlas_coords(node_cell))
	# Get new path
	djikstra_result = djikstra_script.dijkstra_multi_goal(nodes_gr, str(start_no), goal_no)
	var path = djikstra_result["path"]
	path.erase(path[0])
	color_path(path)
	# Move the car
	# move_car(djikstra_result.path)
	pass

func color_path(path) -> void:
	for node in path:
		# Format node from string to Vector2
		var vec_pos = Vector2i(node.split(",")[0].to_int(), node.split(",")[1].to_int())
		# Normally I only have ground tiles in the path
		var ground_atlas_position = game_node.ground_node.get_cell_atlas_coords(vec_pos)
		game_node.global_path_cells.append(vec_pos)
		game_node.change_cell_to_its_alternate_color(vec_pos, ground_atlas_position, 3)
	pass

##################################### Async function #####################################

# TODO : Implement async function to calculate the path
func calculate_path_async(nodes_gr, start_no, goal_no):
	# Task.create(self, "do_djikstra_things", nodes_gr, start_no, goal_no)
	do_djikstra_things(nodes_gr, start_no, goal_no)
	emit_signal("path_calculated")

# Signal to notify when path calculation is done
signal path_calculated
