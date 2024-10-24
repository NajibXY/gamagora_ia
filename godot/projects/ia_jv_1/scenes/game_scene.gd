extends Node2D

## Components
var player_model

var tile_map
var player_scene_node
var ground_node : TileMapLayer
var wall_node : TileMapLayer
var positions_init_values_dict = {} # 1 if possible to go, 0 if not, -10 if targetted by tank, 99 for spawn, 42 for target
var spawn_local_positions = []
var goal_local_positions = []


## Consts
const speed = 25
const water_tile_atlas = Vector2i(0,2)
const goal_tile_atlas = Vector2i(1,0)
const spawn_tile_atlas = Vector2i(1,6)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_components_variables()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_input()
	pass

########################################### COMPONENTS FUNCTIONS ###########################################

func init_components_variables() -> void:
	tile_map = $TileMap
	ground_node = tile_map.get_node("ground")
	wall_node = tile_map.get_node("wall")
	player_scene_node = get_node("player_node")
	player_model = player_scene_node.get_node("player")
	init_positions_dictionnaries()
	for key in positions_init_values_dict.keys():
		print(key, positions_init_values_dict[key])
	pass


########################################### INPUT FUNCTIONS ###########################################

func handle_input() -> void:
	handle_mouse_input()
	handle_movement_input()
	pass

func handle_mouse_input() -> void:
	### Handle click
	# if Input.is_action_just_pressed("left_click"):
	# 	var mouse_position = get_global_mouse_position()
	# 	var mouse_position_map = tile_map.global_to_map(mouse_position)
	# 	var mouse_position_coords_map = tile_map.local_to_map(mouse_position_map)
	# 	print(mouse_position_coords_map)
	# 	if positions_init_values_dict.has(mouse_position_coords_map):
	# 		print("mouse clicked on a valid position")
	# 		if positions_init_values_dict[mouse_position_coords_map] == 1:
	# 			print("mouse clicked on a valid position")
	# 			positions_init_values_dict[mouse_position_coords_map] = -10
	# 			player_model.play("default")
	# 			player_model.position = tile_map.map_to_world(mouse_position_map)
	# 			player_scene_node.transform.origin = player_model.position
	# 		else:
	# 			print("mouse clicked on a invalid position")
	
	pass

func handle_movement_input() -> void:
	var new_position = player_scene_node.transform.origin + Input.get_vector("left", "right", "up", "down") * speed * get_process_delta_time()
	var new_position_coords_map = tile_map.local_to_map(new_position)
	if (ground_node.get_cell_atlas_coords(new_position_coords_map) != Vector2i(-1,-1) and 
	   wall_node.get_cell_atlas_coords(new_position_coords_map) != water_tile_atlas) :
		player_scene_node.transform.origin = new_position
	pass


########################################### TILE MAP DATA FUNCTIONS ###########################################
func init_positions_dictionnaries() -> void:
	print("init_dicts")
	# Get the size of the TileMap (in cells)
	var used_rect = ground_node.get_used_rect()
	print(used_rect)
	for y in range(int(used_rect.size.y)):
		for x in range(int(used_rect.size.x)):
			# Get the tile ID at this position (if any)
			var vector2i_position = Vector2i(used_rect.position.x + x, used_rect.position.y + y)
			# Get cell ID
			var ground_atlas = ground_node.get_cell_atlas_coords(vector2i_position)
			var wall_atlas = wall_node.get_cell_atlas_coords(vector2i_position)

			var tile_initial_value = 1
			if ground_atlas == spawn_tile_atlas :
				tile_initial_value = 99
				spawn_local_positions.append(vector2i_position)
			elif ground_atlas == goal_tile_atlas :
				tile_initial_value = 42
			elif (ground_atlas == Vector2i(-1,-1) or wall_atlas == water_tile_atlas) :
				tile_initial_value = 0
			positions_init_values_dict[vector2i_position] = tile_initial_value
		
			
		
