extends Node2D

var game_node : Node2D
var start_node
var goal_nodes
var nodes_graph
var djikstra_script

const Djisktra = preload("res://scenes/scripts/utils/djikstra.gd")

## TODO:
	# delete after test
var i = 0
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
	goal_nodes = game_node.goal_local_positions
	nodes_graph = game_node.links_dict
	print("Car Variables Ready")
	djikstra_script.launch_djikstra(start_node, goal_nodes, nodes_graph)

	# TODO delete
	initial_start_node = start_node
	#
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		## TODO:
		# delete after test
	i += 1
	print("i: ", i)
	if i == 4:
		i = 0
		start_node = initial_start_node
	start_node = start_node + Vector2i(0,i)
	djikstra_script.launch_djikstra(start_node, goal_nodes, nodes_graph)
		# TODO delete
	pass
