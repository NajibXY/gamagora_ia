extends Node2D

signal ready_signal

## Components
var player_model

var tile_map
var player_scene_node
var ground_node : TileMapLayer
var wall_node : TileMapLayer
var positions_init_values_dict = {} # 1 if possible to go, 0 if not, -10 if targetted by tank, 99 for spawn, 42 for target
var links_dict = {}
var spawn_local_positions = []
var goal_local_positions = []
var movement_vector = Vector2(0,0)

## Consts
const speed = 25
const water_tile_atlas = Vector2i(0,2)
const goal_tile_atlas = Vector2i(1,0)
const spawn_tile_atlas = Vector2i(1,6)

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
	pass

########################################### COMPONENTS FUNCTIONS ###########################################

func init_components_variables() -> void:
	tile_map = $TileMap
	ground_node = tile_map.get_node("ground")
	wall_node = tile_map.get_node("wall")
	player_scene_node = get_node("player_node")
	player_model = player_scene_node.get_node("player")
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
	# Handle movement
	# Back or up ?
	var factor
	if (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		if Input.is_action_pressed("up"):
			factor = 1
		else:
			factor = -1
		var new_position = player_scene_node.transform.origin + movement_vector * speed * get_process_delta_time() * factor
		# var new_position_coords_map = tile_map.local_to_map(offset_by_frame_size(new_position))
		var new_position_coords_map = tile_map.local_to_map(new_position)
		if (ground_node.get_cell_atlas_coords(new_position_coords_map) != Vector2i(-1,-1) and 
			wall_node.get_cell_atlas_coords(new_position_coords_map) != water_tile_atlas) :
			player_scene_node.transform.origin = new_position
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
			# Get cell ID
			var ground_atlas = ground_node.get_cell_atlas_coords(vector2i_position)
			var wall_atlas = wall_node.get_cell_atlas_coords(vector2i_position)
			
			# TODO modify if tiles modified
			var tile_initial_value = 1
			if ground_atlas == spawn_tile_atlas :
				tile_initial_value = 99
				spawn_local_positions.append(str(vector2i_position))
			elif ground_atlas == goal_tile_atlas :
				tile_initial_value = 42
				goal_local_positions.append(str(vector2i_position))
			elif (ground_atlas == Vector2i(-1,-1) or wall_atlas == water_tile_atlas) :
				tile_initial_value = 0
			positions_init_values_dict[str(vector2i_position)] = tile_initial_value
			# Initial Links calculations
			links_value = {}
			# Check the 4 neightbours values
			for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var neighbour_position = vector2i_position + offset
				var neighbour_ground_atlas = ground_node.get_cell_atlas_coords(neighbour_position)
				var neighbour_wall_atlas = wall_node.get_cell_atlas_coords(neighbour_position)
				if neighbour_ground_atlas != Vector2i(-1,-1):
					var link_initial_value = INF
					# TODO modify if tiles modified
					if neighbour_wall_atlas != water_tile_atlas:
						link_initial_value = 1
						links_value[str(neighbour_position)] = link_initial_value
			links_dict[str(vector2i_position)] = links_value


		
			
		
