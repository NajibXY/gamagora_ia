extends Node2D


var random_seed
var unique_id: int

################################################ Consts ###########################################################################################

## Difficulty Consts

# Easy
const SPEED_EASY = 0.03
const SPEED_SLOWED_EASY = SPEED_EASY / 5
const TIME_FREEZE_START_EASY = 3.0

# Normal
const SPEED_NORMAL = 0.06
const SPEED_SLOWED_NORMAL = SPEED_NORMAL / 3
const TIME_FREEZE_START_NORMAL = 2.0

# Impossible
const SPEED_HARD = 0.18
const SPEED_SLOWED_HARD = SPEED_HARD / 3
const TIME_FREEZE_START_HARD = 0.0

# const TIME_FREEZE = 4.0
# const TIME_FREEZE_SLOWED = 2.0
# const TIME_FREEZE_START = 4.0
# const TIME_FREEZE = 2.0
# const TIME_FREEZE_SLOWED = 4.0

## Scoring consts
const POSITIVE_SCORING = 1
const NEGATIVE_SCORING = -3

## Path finding Consts
const HEURISTIC_RATIO = 2 # Heuristic cost for A* algorithm will be divided by this value

## Utils
const IDManager = preload("res://scenes/scripts/utils/IDManager.gd")
const Djisktra = preload("res://scenes/scripts/utils/djikstra.gd")
const AStar = preload("res://scenes/scripts/utils/a_star.gd")

## Car components paths
const car1_scene_path = preload("res://scenes/scene/car/car.tscn")
const car2_scene_path = preload("res://scenes/scene/car/car2.tscn")

# Goal consts for the car
var GOAL_ALTERNATIVE_ID
const GOAL_ALTERNATIVE_ID_YELLOW = 3
const GOAL_ALTERNATIVE_ID_GREEN = 4

################################################ Variables ###########################################################################################

## Difficulty
var speed = SPEED_NORMAL
var speed_slowed = SPEED_SLOWED_NORMAL
var time_freeze_start = TIME_FREEZE_START_NORMAL

## Components
var game_node : Node2D
var car_model

## Path finding variables
var start_node
var goal_nodes
var nodes_graph
var path_script
var path_result
var position_going_to
var moving_to
var been_freezed = false

## Threading variables
var is_running 
var goal_reached
var _thread: Thread = Thread.new()
var is_calculating_path = false  # Track if path calculation is in progress


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Random between Yellow (A*) and Green (Djikstra)
	random_seed = randi() % 2
	if random_seed == 0:
		GOAL_ALTERNATIVE_ID = GOAL_ALTERNATIVE_ID_YELLOW
		path_script = AStar.new()
	else:
		GOAL_ALTERNATIVE_ID = GOAL_ALTERNATIVE_ID_GREEN
		path_script = Djisktra.new()
		var child_car = get_child(0)
		remove_child(child_car)
		child_car.queue_free()
		var car_scene2 = car2_scene_path.instantiate()
		add_child(car_scene2)

	car_model = get_child(0)

	# Game scene node ready signal reception
	game_node = get_node("/root/global_scene_node/game_node")
	game_node.connect("ready_signal", Callable(self, "_on_game_script_ready"))
	pass 

func _on_game_script_ready() -> void:
	set_difficulty()
	unique_id = IDManager.get_new_id()
	# print(unique_id)
	game_node.car_increment += 1
	game_node.car_path_cells[str(unique_id)] = []
	# Initialize variables for path finding : start_node, goal_nodes, nodes_graph
	start_node = game_node.tile_map.local_to_map(self.transform.origin)
	goal_nodes = game_node.goal_local_positions
	nodes_graph = game_node.links_dict
	path_result = {"distance": INF, "path": []}
	# print("Car Variables Ready")
	# Initialize threading variables
	is_running = false
	goal_reached = false
	# Once it is received, we disconnect the signal so that the next car can receive it, and each one gets it once
	game_node.disconnect("ready_signal", Callable(self, "_on_game_script_ready"))
	pass

func set_difficulty() -> void:
	if game_node.game_difficulty == 0:
		speed = SPEED_EASY
		speed_slowed = SPEED_SLOWED_EASY
		time_freeze_start = TIME_FREEZE_START_EASY
	elif game_node.game_difficulty == 2:
		speed = SPEED_HARD
		speed_slowed = SPEED_SLOWED_HARD
		time_freeze_start = TIME_FREEZE_START_HARD
	else:
		game_node.game_difficulty = 1
		speed = SPEED_NORMAL
		speed_slowed = SPEED_SLOWED_NORMAL
		time_freeze_start = TIME_FREEZE_START_NORMAL
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If the path finding is not launched and goal not reached we enter our main path finding function loop
	if moving_to:
		move_car()
	elif not is_running and not goal_reached:
		moving_to = false
		is_running = true
		iterate_movements()
	pass

##################################### Car movement functions ###########################################################################################
func move_car() -> void:
	# Change model orientation
	var target_pos = game_node.tile_map.map_to_local(position_going_to)
	var direction = target_pos - self.transform.origin
	# Use the angle between the direction and the x axis to determine the frame of the model
	var angle = direction.angle()
	if angle < -1.8:
		car_model.frame = 2
	elif angle < -0.39:
		car_model.frame = 4
	elif angle < 0.9:
		car_model.frame = 6
	elif angle < 2.8:
		car_model.frame = 0

	# Move the car
	if game_node.ground_node.get_cell_atlas_coords(position_going_to) == game_node.GRASS_TILE_ATLAS:
		self.transform.origin = self.transform.origin.lerp(target_pos, speed_slowed)
	else:
		self.transform.origin = self.transform.origin.lerp(target_pos, speed)
	
	# If the car is close enough to the target position, stop moving
	if self.transform.origin.distance_to(target_pos) < 1:
		self.transform.origin = target_pos
		moving_to = false

func iterate_movements() -> void:
	# Check if the goal is reached
	var current_map_coords = game_node.tile_map.local_to_map(self.transform.origin)
	# TODO display score and lifes
	if str(current_map_coords) in goal_nodes:
		goal_reached = true
		if str(current_map_coords) in game_node.goal_yellow_positions and GOAL_ALTERNATIVE_ID == GOAL_ALTERNATIVE_ID_GREEN:
			game_node.update_score(NEGATIVE_SCORING)
		elif str(current_map_coords) in game_node.goal_green_positions and GOAL_ALTERNATIVE_ID == GOAL_ALTERNATIVE_ID_YELLOW:
			game_node.update_score(NEGATIVE_SCORING)
		else:
			game_node.update_score(POSITIVE_SCORING)
		# Erasing car data from game_node variables
		game_node.car_path_cells.erase(str(unique_id))
		game_node.car_increment -= 1
		# Destroying node
		queue_free()
	# If not, construct path or walk through path
	else:
		if (path_result["path"].size() == 0 and not goal_reached):
			calculate_path_async(game_node.links_dict, str(current_map_coords), goal_nodes)
		else:
			while (path_result["path"].size() != 0):
				# Freeze at spawn
				if not been_freezed :
					been_freezed = true
					await get_tree().create_timer(time_freeze_start).timeout

				# Get the target node
				var target_node = path_result["path"][0]
				target_node = Vector2i(target_node.split(",")[0].to_int(), target_node.split(",")[1].to_int())

				var continue_while = true

				# Check if the target node is locked by the player
				if target_node in game_node.locked_targeted_cells:
					# If the target node is targetted, apply path finding algorithm again and break from the loop for this frame
					calculate_path_async(game_node.links_dict, str(game_node.tile_map.local_to_map(self.transform.origin)), goal_nodes)
					continue_while = false
					break
				# Check if any remaining node from the path is locked by the player
				for node_path in path_result["path"]:
					var node_left = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
					if node_left in game_node.locked_targeted_cells:
						# Calculate another path and break from the loop for this frame
						calculate_path_async(game_node.links_dict, str(game_node.tile_map.local_to_map(self.transform.origin)), goal_nodes)
						continue_while = false
						break
				if not continue_while:
					# Not sure if this affectation is necessary
					is_running = false
					break

				# Move to next position
				position_going_to = target_node
				moving_to = true

				# Pop the first element of the path from path result and game path cells data
				path_result["path"].erase(path_result["path"][0])
				## Checking if in another car's path before erasing
				game_node.erase_if_not_in_others_path(target_node, unique_id)
				break
				
				# # Freeze the car for a while
				# if game_node.ground_node.get_cell_atlas_coords(target_node) == game_node.GRASS_TILE_ATLAS:
				# 	# If the car is on grass, it moves slower, so it will freeze for a longer time
				# 	await get_tree().create_timer(TIME_FREEZE_SLOWED).timeout
				# else:
				# 	await get_tree().create_timer(TIME_FREEZE).timeout
	is_running = false
	pass

##################################### Init Path finding and coloring path functions ######################################################################

## Deprecated
# func init_djikstra_things(nodes_gr, start_no, goal_no) -> void:
# 	# If djikstra path is not empty, reset the cells if not targeted
# 	if path_result:
# 		for node_path in path_result["path"]:
# 			var node_cell = Vector2i(node_path.split(",")[0].to_int(), node_path.split(",")[1].to_int())
# 			## Checking if in another car's path before erasing
# 			game_node.erase_if_not_in_others_path(node_cell, unique_id)
# 	# Get new path
# 	path_result = path_script.path_multi_goal(nodes_gr, str(start_no), goal_no, HEURISTIC_RATIO)
# 	var path = path_result["path"]
# 	if path.size() > 0:	
# 		path.erase(path[0])
# 	color_path(path)
# 	# Move the car
# 	# move_car(path_result.path)
# 	pass

# Coloring path minus start and end
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
				game_node.change_cell_to_its_alternate_color(vec_pos, ground_atlas_position, game_node.PATH_ATLAS_ALT)

		# Adding to car path cells
		game_node.car_path_cells[str(unique_id)].append(vec_pos)
	pass

##################################### Thread functions #############################################################################################

# Asynchronous path calculation function
func calculate_path_async(graph: Dictionary, start: String, goals: Array) -> void:
	if is_calculating_path:
		return
	is_calculating_path = true
	_thread = Thread.new()
	_thread.start(Callable(self, "threaded_calculate_path").bind(graph, start, goals))
	pass

# Threaded path calculation function
func threaded_calculate_path(graph: Dictionary, start: String, goals: Array) -> void:
	# Calling either A* or Djikstra path finding algorithm, depending on car random seed
	var result = path_script.path_multi_goal(graph, start, goals, HEURISTIC_RATIO)
	call_deferred("on_path_calculated", result)
	pass

# Path calculation callback function
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
