extends Node2D

var unique_id: int
const IDManager = preload("res://scenes/scripts/utils/IDManager.gd")

const Djisktra = preload("res://scenes/scripts/utils/djikstra.gd")
const AStar = preload("res://scenes/scripts/utils/a_star.gd")

# TODO fine tune, maybe change from division to optimize calculation
const HEURISTIC_RATIO = 2 # Heuristic cost for A* algorithm will be divided by this value

# Goal values
var GOAL_ALTERNATIVE_ID
const GOAL_ALTERNATIVE_ID_YELLOW = 3
const GOAL_ALTERNATIVE_ID_GREEN = 4

# TODO fine tune, use speed ?
const SPEED = 0.2
const TIME_FREEZE_START = 1.0
const TIME_FREEZE = 1.0
const TIME_FREEZE_SLOWED = 2.0
# const TIME_FREEZE_START = 4.0
# const TIME_FREEZE = 2.0
# const TIME_FREEZE_SLOWED = 4.0

var game_node : Node2D

var initial_start_node
var start_node
var goal_nodes
var nodes_graph

var path_result
var djikstra_script
var astar_script

# Thread variables
var is_running 
var goal_reached
var _thread: Thread = Thread.new()
var is_calculating_path = false  # Track if path calculation is in progress


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game scene node ready signal
	game_node = get_node("/root/global_scene_node/game_node")
	# TODO Switch between both
	djikstra_script = Djisktra.new()
	astar_script = AStar.new()
	GOAL_ALTERNATIVE_ID = GOAL_ALTERNATIVE_ID_YELLOW

	game_node.connect("ready_signal", Callable(self, "_on_game_script_ready"))
	pass # Replace with function body.

func _on_game_script_ready() -> void:
	unique_id = IDManager.get_new_id()
	print(unique_id)
	game_node.car_increment += 1
	game_node.car_path_cells[str(unique_id)] = []
	# Initialize car variables for djikstra : start_node, goal_nodes, nodes_graph
	start_node = game_node.tile_map.local_to_map(self.transform.origin)
	initial_start_node = start_node
	goal_nodes = game_node.goal_local_positions
	nodes_graph = game_node.links_dict
	print("Car Variables Ready")
	is_running = false
	goal_reached = false
	# Init first djisktra
	# init_djikstra_things(nodes_graph, str(start_node), goal_nodes)
	path_result = {"distance": INF, "path": []}
	game_node.disconnect("ready_signal", Callable(self, "_on_game_script_ready"))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_running and not goal_reached:
		is_running = true
		iterate_movements(delta)
	pass

##################################### Car movement functions #####################################
func iterate_movements(delta: float) -> void:
	# Check if the goal is reached
	var current_map_coords = game_node.tile_map.local_to_map(self.transform.origin)
	if str(current_map_coords) in goal_nodes:
		goal_reached = true
		if str(current_map_coords) in game_node.goal_yellow_positions and GOAL_ALTERNATIVE_ID == GOAL_ALTERNATIVE_ID_GREEN:
			game_node.LIFES -= 1
			print("Life lost")
		elif str(current_map_coords) in game_node.goal_green_positions and GOAL_ALTERNATIVE_ID == GOAL_ALTERNATIVE_ID_YELLOW:
			game_node.LIFES -= 1
			print("Life lost")
		else:
			game_node.SCORE += 1
			print("Scored")
		# TODO things !!! ERASE ALL THINGS from dicts etc too
		game_node.car_path_cells.erase(str(unique_id))
		game_node.car_increment -= 1
		queue_free()
	# If not, construct path or walk through path
	else:
		if (path_result["path"].size() == 0 and not goal_reached):
			calculate_path_async(game_node.links_dict, str(current_map_coords), goal_nodes)
		else:
			while (path_result["path"].size() != 0):
				if start_node == game_node.tile_map.local_to_map(self.transform.origin) :
					await get_tree().create_timer(TIME_FREEZE_START).timeout

				# Get the target node
				var target_node = path_result["path"][0]
				target_node = Vector2i(target_node.split(",")[0].to_int(), target_node.split(",")[1].to_int())

				var continue_while = true
				# Check if the target node is targetted
				if target_node in game_node.locked_targeted_cells:
					# If the target node is targetted, do djikstra again
					calculate_path_async(game_node.links_dict, str(game_node.tile_map.local_to_map(self.transform.origin)), goal_nodes)
					continue_while = false
					break
				# Check if any remaining node from the djikstra is targetted
				for node_path in path_result["path"]:
					var node_left = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
					if node_left in game_node.locked_targeted_cells:
						# print("Doing djikstra")
						calculate_path_async(game_node.links_dict, str(game_node.tile_map.local_to_map(self.transform.origin)), goal_nodes)
						# print("Ending djikstra")
						continue_while = false
						break
				if not continue_while:
					is_running = false
					break

				# Make it not as precise as the car is not moving on a grid so that it be 0.1 precision
				var target_pos = game_node.tile_map.map_to_local(target_node)
				target_pos = Vector2(round(target_pos.x), round(target_pos.y))
				while (self.transform.origin != target_pos):
					self.transform.origin = self.transform.origin.move_toward(target_pos, delta * SPEED)
				
				# Pop the first element of the path from djikstra and global path
				path_result["path"].erase(path_result["path"][0])
				## Checking if in another car's path before erasing
				game_node.erase_if_not_in_others_path(target_node, unique_id)
				
				# Freeze the car for a while
				if game_node.ground_node.get_cell_atlas_coords(target_node) == game_node.GRASS_TILE_ATLAS:
					# If the car is on grass, it will move slower
					print("Car is on grass")
					await get_tree().create_timer(TIME_FREEZE_SLOWED).timeout
				else:
					await get_tree().create_timer(TIME_FREEZE).timeout

	is_running = false
	pass

##################################### Personal Djikstra functions #####################################
func init_djikstra_things(nodes_gr, start_no, goal_no) -> void:
	# If djikstra path is not empty, reset the cells if not targeted
	if path_result:
		for node_path in path_result["path"]:
			var node_cell = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
			## Checking if in another car's path before erasing
			game_node.erase_if_not_in_others_path(node_cell, unique_id)
	# Get new path
	# path_result = djikstra_script.dijkstra_multi_goal(nodes_gr, str(start_no), goal_no)
	path_result = astar_script.a_star_multi_goal(nodes_gr, str(start_no), goal_no, HEURISTIC_RATIO)
	var path = path_result["path"]
	if path.size() > 0:	
		path.erase(path[0])
	color_path(path)
	# Move the car
	# move_car(path_result.path)
	pass

func color_path(path) -> void:
	for node in path:
		# Format node from string to Vector2
		var vec_pos = Vector2i(node.split(",")[0].to_int(), node.split(",")[1].to_int())
		# Normally I only have ground tiles in the path
		var ground_atlas_position = game_node.ground_node.get_cell_atlas_coords(vec_pos)
		# Adding to global path cells
		if (vec_pos not in game_node.global_path_cells):
			game_node.global_path_cells.append(vec_pos)
			if node not in game_node.goal_yellow_positions and node not in game_node.goal_green_positions:
				game_node.change_cell_to_its_alternate_color(vec_pos, ground_atlas_position, 3)
			else:
				print("goal")

		# Adding to car path cells
		game_node.car_path_cells[str(unique_id)].append(vec_pos)
	pass

##################################### Thread functions #####################################
func calculate_path_async(graph: Dictionary, start: String, goals: Array) -> void:
	if is_calculating_path:
		return
	is_calculating_path = true
	_thread = Thread.new()
	_thread.start(Callable(self, "threaded_calculate_path").bind(graph, start, goals))
	pass

func threaded_calculate_path(graph: Dictionary, start: String, goals: Array) -> void:
	var result = astar_script.a_star_multi_goal(graph, start, goals, HEURISTIC_RATIO)
	# var result = djikstra_script.dijkstra_multi_goal(graph, start, goals)
	call_deferred("on_path_calculated", result)
	pass

func on_path_calculated(result) -> void:
	# Thread results
	if path_result:
		for node_path in path_result["path"]:
			var node_cell = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
			## Checking if in another car's path before erasing
			game_node.erase_if_not_in_others_path(node_cell, unique_id)
	path_result = result
	var path = path_result["path"]
	if path.size() > 0:	
		path.erase(path[0])
	color_path(path)

	# Thread kill
	is_calculating_path = false
	_thread.wait_to_finish()
	_thread = null
	pass
