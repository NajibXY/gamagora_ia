extends Node2D

signal ready_signal

## Consts
#TODO : fine tune SPEED
const SPEED = 24
const SPEED_SLOWED = SPEED / 3
#TODO : fine tune depending on map size
const AIM_STEPS = 30

const WATER_TILE_ATLAS = Vector2i(0,7)
const WALL_TILE_ATLAS = Vector2i(0,3)
const GRASS_TILE_ATLAS = Vector2i(1,7)
const GOAL_TILE_ATLAS_YELLOW = Vector2i(1,0)
const GOAL_TILE_ATLAS_YELLOW_ALT = 3
const GOAL_TILE_ATLAS_GREEN = Vector2i(1,0)
const GOAL_TILE_ATLAS_GREEN_ALT = 4

const SPAWN_TILE_ATLAS = Vector2i(1,6)
# TODO : fine tune ?
const GRASS_VALUE = 3
#TODO : fine tune
const INTERVAL: float = 4.0 # x seconds
const MAX_CARS = 5

var LIFES = 3
var SCORE = 0

## Utils
var maths_script
const Maths = preload("res://scenes/scripts/utils/maths.gd")

## Car variables
var car_increment = 0
var car_path_cells = {}

## Highlight variables
var targeted_cells = []
var locked_targeted_cells = []
var global_path_cells = []

## Components variables
var player_model
var tile_map
var player_scene_node
var ground_node : TileMapLayer
var movement_vector = Vector2(0,0)
var slowed = false

var links_dict = {}
var spawn_local_positions = []
var goal_yellow_positions = []
var goal_green_positions = []
var goal_local_positions = []

## Flag for instanciation
var time_passed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_components_variables()
	#emit ready signal
	print("Game Scene Ready, emiting ready signal")
	emit_signal("ready_signal")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input()
	# Instantiate car_scene every 5 seconds in one of the spawn points
	time_passed += delta
	if car_increment < MAX_CARS and time_passed >= INTERVAL:
		time_passed = 0.0
		var random_spawn = spawn_local_positions[randi() % spawn_local_positions.size()]
		var car_scene = load("res://scenes/scene/car/car_scene.tscn").instantiate()
		add_child(car_scene)
		car_scene.transform.origin = tile_map.map_to_local(Vector2i(random_spawn.split(",")[0].to_int(), random_spawn.split(",")[1].to_int()))
		emit_signal("ready_signal")	
	pass

########################################### COMPONENTS FUNCTIONS ###########################################

func init_components_variables() -> void:
	tile_map = $TileMap
	ground_node = tile_map.get_node("ground")
	player_scene_node = get_node("player_node")
	player_model = player_scene_node.get_node("player")
	maths_script = Maths.new()
	init_positions_dictionnaries()
	pass


########################################### INPUT FUNCTIONS ###########################################

func handle_input() -> void:
	handle_mouse_input()
	handle_movement_input()
	pass

func handle_mouse_input() -> void:
	### Handle Aim
	# Get mouse position in main scene
	var local_mouse_pos = to_local(get_viewport().get_mouse_position())
	# Calculate direction vector
	var direction = local_mouse_pos - player_scene_node.transform.origin
	# Determine which frame of the 8 to use
	var angle = direction.angle()
	#print(angle)
	#8 directions
	if angle < -2.6 :
		player_model.frame = 5
		movement_vector = Vector2(-1.0,0)
	elif angle < -1.8:
		player_model.frame = 6
		movement_vector = Vector2(-1.0,-0.517)
	elif angle < -1.18:
		player_model.frame = 7
		movement_vector = Vector2(0,-0.517)
	elif angle < -0.39:
		player_model.frame = 0
		movement_vector = Vector2(1.0,-0.517)
	elif angle < 0.39:
		player_model.frame = 1
		movement_vector = Vector2(1.0,0)
	elif angle < 0.9:
		player_model.frame = 2
		movement_vector = Vector2(1.0,0.517)
	elif angle < 1.8:
		player_model.frame = 3
		movement_vector = Vector2(0,0.517)
	elif angle < 2.8:
		player_model.frame = 4
		movement_vector = Vector2(-1.0,0.517)
	# Highlight tiles
	refresh_targeted_cells(player_scene_node.transform.origin, local_mouse_pos)

	# Lock targetted cells
	if Input.is_action_just_pressed("left_click") :
		refresh_locked_targeted_cells(player_scene_node.transform.origin, local_mouse_pos)
	pass

func handle_movement_input() -> void:
	# Handle movement
	# Back or up ?
	var factor
	if (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		if Input.is_action_pressed("up"):
			factor = 1
		else:
			factor = -1
		var new_position
		if slowed:
			new_position = player_scene_node.transform.origin + movement_vector * SPEED_SLOWED * get_process_delta_time() * factor
		else:
			new_position = player_scene_node.transform.origin + movement_vector * SPEED * get_process_delta_time() * factor
		# TODO : use offset ?
		# var new_position_coords_map = tile_map.local_to_map(offset_by_frame_size(new_position))
		var new_position_coords_map = tile_map.local_to_map(new_position)
		if ground_node.get_cell_atlas_coords(new_position_coords_map) == GRASS_TILE_ATLAS:
			slowed = true
			player_scene_node.transform.origin = new_position
		elif (ground_node.get_cell_atlas_coords(new_position_coords_map) != Vector2i(-1,-1) and 
			ground_node.get_cell_atlas_coords(new_position_coords_map) != WATER_TILE_ATLAS and  
			ground_node.get_cell_atlas_coords(new_position_coords_map) != WALL_TILE_ATLAS):
			player_scene_node.transform.origin = new_position
			slowed = false
	pass


########################################### TILE MAP INITIALISATIPON DATA FUNCTIONS ###########################################
# TODO
# func offset_by_frame_size(position: Vector2) -> Vector2:
# 	var sprite_frames  = player_model.get_node("AnimatedSprite2D").frames
# 	return position

func init_positions_dictionnaries() -> void:
	print("init_dicts")
	var links_value
	# Get the size of the TileMap (in cells)
	var used_rect = ground_node.get_used_rect()
	#print(used_rect)
	for y in range(int(used_rect.size.y)):
		for x in range(int(used_rect.size.x)):
			# Get the tile ID at this position (if any)
			var vector2i_position = Vector2i(used_rect.position.x + x, used_rect.position.y + y)
			# Get cell atlas
			var ground_atlas = ground_node.get_cell_atlas_coords(vector2i_position)
			var ground_alternate = ground_node.get_cell_alternative_tile(vector2i_position)
			
			# Init spawns, goals
			if ground_atlas == SPAWN_TILE_ATLAS :
				spawn_local_positions.append(str(vector2i_position))
			elif ground_atlas == GOAL_TILE_ATLAS_YELLOW and ground_alternate == GOAL_TILE_ATLAS_YELLOW_ALT:
				goal_yellow_positions.append(str(vector2i_position))
				goal_local_positions.append(str(vector2i_position))
			elif ground_atlas == GOAL_TILE_ATLAS_GREEN and ground_alternate == GOAL_TILE_ATLAS_GREEN_ALT:
				goal_green_positions.append(str(vector2i_position))
				goal_local_positions.append(str(vector2i_position))

			# Initial Links calculations
			links_value = {}
			# Check the 4 neightbours values
			for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var neighbour_position = vector2i_position + offset
				var neighbour_ground_atlas = ground_node.get_cell_atlas_coords(neighbour_position)
				if neighbour_ground_atlas != Vector2i(-1,-1):
					var link_initial_value = INF
					# TODO modify if tiles modified
					if neighbour_ground_atlas != WATER_TILE_ATLAS and neighbour_ground_atlas != WALL_TILE_ATLAS:
						link_initial_value = 1
						if neighbour_ground_atlas == GRASS_TILE_ATLAS:
							link_initial_value = GRASS_VALUE
						links_value[str(neighbour_position)] = link_initial_value
			links_dict[str(vector2i_position)] = links_value

########################################### TILE MAP HIGHLIGHT DATA FUNCTIONS ###########################################

func refresh_targeted_cells(start: Vector2, end: Vector2) -> void:
	# Clear previous targeted cells
	for pos in targeted_cells:
		var position_coords_map = tile_map.local_to_map(pos)
		if position_coords_map not in locked_targeted_cells:
			var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
			if ground_atlas_position != Vector2i(-1,-1):
				if str(position_coords_map) not in goal_local_positions and position_coords_map in global_path_cells:
					change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 3)
				else:
					change_cell_to_its_original(position_coords_map, ground_atlas_position)
				pass

	# Calculate new targeted cells
	targeted_cells = maths_script.get_positions_between(start, end, AIM_STEPS)

	for pos in targeted_cells:
		var position_coords_map = tile_map.local_to_map(pos)
		var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
		if ground_atlas_position == WALL_TILE_ATLAS:
			return
		elif position_coords_map not in locked_targeted_cells:
			if ground_atlas_position != Vector2i(-1,-1):
				change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 1)
				pass
	pass

func refresh_locked_targeted_cells(start: Vector2, end: Vector2) -> void:
	# Clear previous targeted cells
	for position_coords_map in locked_targeted_cells:
		var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
		if ground_atlas_position != Vector2i(-1,-1):
			if str(position_coords_map) not in goal_local_positions and position_coords_map in global_path_cells:
				change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 3)
			else:
				change_cell_to_its_original(position_coords_map, ground_atlas_position)
			# Update links valuation to original
			release_links_valuation(position_coords_map)
			pass

	locked_targeted_cells = []

	# Calculate new targeted cells
	for pos in maths_script.get_positions_between(start, end, AIM_STEPS):
		var position_coords_map = tile_map.local_to_map(pos)
		locked_targeted_cells.append(position_coords_map)
		var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
		if ground_atlas_position != Vector2i(-1,-1):
			if ground_atlas_position == WALL_TILE_ATLAS:
				return
			else:
				change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 2)
				if ground_atlas_position != WATER_TILE_ATLAS:
					# Update links valuation to 99
					change_links_valuation(position_coords_map)
			pass
	pass

func change_cell_to_its_alternate_color(tile_position: Vector2, atlas_position:Vector2, alternate_num:int) -> void:
	ground_node.set_cell(tile_position, 0, atlas_position, alternate_num)
	pass

func change_cell_to_its_original(tile_position: Vector2, atlas_position:Vector2) -> void:
	if str(tile_position) in goal_yellow_positions:
		change_cell_to_its_alternate_color(tile_position, atlas_position, GOAL_TILE_ATLAS_YELLOW_ALT)
	elif str(tile_position) in goal_green_positions:
		# TOZ
		change_cell_to_its_alternate_color(tile_position, atlas_position, GOAL_TILE_ATLAS_GREEN_ALT)
	else: 
		ground_node.set_cell(tile_position, 0, atlas_position, 0)
	pass

func erase_if_not_in_others_path(node: Vector2i, unique_id: int) -> void:
	# Erase from id car
	car_path_cells[str(unique_id)].erase(node)
	# Chech others
	var z = 0
	var is_on_another_car_path = false
	while z < car_increment :
		if z != unique_id and str(z) in car_path_cells.keys() and node in car_path_cells[str(z)]:
			is_on_another_car_path = true
			break
		z += 1
	if not is_on_another_car_path:
		global_path_cells.erase(node)
		if node not in locked_targeted_cells:
			change_cell_to_its_original(node, ground_node.get_cell_atlas_coords(node))
	pass

########################################### LINKS VALUATION FUNCTIONS ###########################################

func change_links_valuation(vector2i_position: Vector2i) -> void:
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbour_position = vector2i_position + offset
		var neighbour_ground_atlas = ground_node.get_cell_atlas_coords(neighbour_position)
		if neighbour_ground_atlas != Vector2i(-1,-1) and neighbour_ground_atlas != WATER_TILE_ATLAS and neighbour_ground_atlas != WALL_TILE_ATLAS:
			links_dict[str(neighbour_position)][str(vector2i_position)] = INF
	pass

func release_links_valuation(vector2i_position: Vector2i) -> void:
	var position_ground_atlas = ground_node.get_cell_atlas_coords(vector2i_position)
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbour_position = vector2i_position + offset
		var neighbour_ground_atlas = ground_node.get_cell_atlas_coords(neighbour_position)
		if neighbour_ground_atlas != Vector2i(-1,-1) and neighbour_ground_atlas != WATER_TILE_ATLAS and neighbour_ground_atlas != WALL_TILE_ATLAS:
			var link_value = INF
			# TODO modify if tiles modified
			if position_ground_atlas != WATER_TILE_ATLAS and position_ground_atlas != WALL_TILE_ATLAS:
				link_value = 1
				if position_ground_atlas == GRASS_TILE_ATLAS:
					link_value = GRASS_VALUE
				links_dict[str(neighbour_position)][str(vector2i_position)] = link_value
	pass

	
		
			
		
