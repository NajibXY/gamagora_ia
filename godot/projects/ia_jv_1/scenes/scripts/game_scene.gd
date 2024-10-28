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

var maths_script
const Maths = preload("res://scenes/scripts/utils/maths.gd")

## Highlight variables
var targeted_cells = []
var locked_targeted_cells = []
var path_cells = []

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
	refresh_targeted_cells(player_scene_node.transform.origin, local_mouse_pos, 30)

	# Lock targetted cells
	if Input.is_action_just_pressed("left_click") :
		refresh_locked_targeted_cells(player_scene_node.transform.origin, local_mouse_pos, 30)

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

########################################### TILE MAP HIGHLIGHT DATA FUNCTIONS ###########################################

func refresh_targeted_cells(start: Vector2, end: Vector2, steps: int) -> void:
	# Clear previous targeted cells
	for pos in targeted_cells:
		var position_coords_map = tile_map.local_to_map(pos)
		if position_coords_map not in locked_targeted_cells:
			print("NOT IN LOCKED TARGETED CELLS")
			var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
			var wall_atlas_position = wall_node.get_cell_atlas_coords(position_coords_map)
			if ground_atlas_position != Vector2i(-1,-1):
				if wall_atlas_position == water_tile_atlas:
					change_cell_to_its_original(position_coords_map, wall_atlas_position, 1)
				else:
					if position_coords_map in path_cells:
						change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 0, 3)
						print("IN PATH")
					else:
						change_cell_to_its_original(position_coords_map, ground_atlas_position, 0)
				pass

	# Calculate new targeted cells
	targeted_cells = maths_script.get_positions_between(start, end, steps)
	for pos in targeted_cells:
		var position_coords_map = tile_map.local_to_map(pos)
		if position_coords_map not in locked_targeted_cells:
			var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
			var wall_atlas_position = wall_node.get_cell_atlas_coords(position_coords_map)
			if ground_atlas_position != Vector2i(-1,-1):
				if wall_atlas_position == water_tile_atlas:
					change_cell_to_its_alternate_color(position_coords_map, wall_atlas_position, 1, 1)
				else:
					change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 0, 1)
				pass
	pass

func refresh_locked_targeted_cells(start: Vector2, end: Vector2, steps: int) -> void:
	# Clear previous targeted cells
	for position_coords_map in locked_targeted_cells:
		var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
		var wall_atlas_position = wall_node.get_cell_atlas_coords(position_coords_map)
		if ground_atlas_position != Vector2i(-1,-1):
			if wall_atlas_position == water_tile_atlas:
				change_cell_to_its_original(position_coords_map, wall_atlas_position, 1)
			else:
				if position_coords_map in path_cells:
					change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 0, 3)
				else:
					change_cell_to_its_original(position_coords_map, ground_atlas_position, 0)
			pass
	locked_targeted_cells = []

	# Calculate new targeted cells
	for pos in maths_script.get_positions_between(start, end, steps):
		var position_coords_map = tile_map.local_to_map(pos)
		locked_targeted_cells.append(position_coords_map)
		var ground_atlas_position = ground_node.get_cell_atlas_coords(position_coords_map)
		var wall_atlas_position = wall_node.get_cell_atlas_coords(position_coords_map)
		if ground_atlas_position != Vector2i(-1,-1):
			if wall_atlas_position == water_tile_atlas:
				change_cell_to_its_alternate_color(position_coords_map, wall_atlas_position, 1, 2)
			else:
				change_cell_to_its_alternate_color(position_coords_map, ground_atlas_position, 0, 2)
			pass
	pass

func change_cell_to_its_alternate_color(tile_position: Vector2, atlas_position:Vector2, layer:int, alternate_num:int) -> void:
	if (layer == 0):
		ground_node.set_cell(tile_position, 0, atlas_position, alternate_num)
	else:
		wall_node.set_cell(tile_position, 0, atlas_position, alternate_num)
	pass

func change_cell_to_its_original(tile_position: Vector2, atlas_position:Vector2, layer:int) -> void:
	if (layer == 0):
		ground_node.set_cell(tile_position, 0, atlas_position, 0)
	else:
		wall_node.set_cell(tile_position, 0, atlas_position, 0)
	pass
	
		
			
		
