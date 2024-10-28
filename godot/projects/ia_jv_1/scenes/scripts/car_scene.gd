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
var i = 1

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
	while (i < djikstra_result["path"].size()):
		var target_node = djikstra_result["path"][i]
		target_node = Vector2i(target_node.split(",")[0].to_int(), target_node.split(",")[1].to_int())
		var target_pos = game_node.tile_map.map_to_local(target_node)
		# Make it not as precise as the car is not moving on a grid so that it be 0.1 precision
		target_pos = Vector2(round(target_pos.x), round(target_pos.y))
		while (self.transform.origin != target_pos):
			# TODO tune the speed
			self.transform.origin = self.transform.origin.move_toward(target_pos, delta * speed)
		await get_tree().create_timer(2.0).timeout
		i = i+1
	is_running = false
	pass

##################################### Personnal Djikstra functions #####################################
func do_djikstra_things(nodes_gr, start_no, goal_no) -> void:
	djikstra_result = djikstra_script.dijkstra_multi_goal(nodes_gr, str(start_no), goal_no)
	var path = djikstra_result["path"]
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
		game_node.path_cells.append(vec_pos)
		game_node.change_cell_to_its_alternate_color(vec_pos, ground_atlas_position, 0, 3)
	pass
