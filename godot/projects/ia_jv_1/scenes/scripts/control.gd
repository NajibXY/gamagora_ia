extends Control

var game_node
var difficulty = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_easy_button_pressed() -> void:
	difficulty = 0
	game_node = get_node("/root/global_scene_node")
	if game_node != null:
		get_tree().root.remove_child(game_node)
	game_node = preload("res://scenes/scene/global_scene.tscn").instantiate()
	get_tree().root.add_child(game_node)
	get_tree().root.remove_child(self)
	pass # Replace with function body.


func _on_medium_button_pressed() -> void:
	difficulty = 1
	game_node = get_node("/root/global_scene_node")
	if game_node != null:
		get_tree().root.remove_child(game_node)
	game_node = preload("res://scenes/scene/global_scene.tscn").instantiate()
	get_tree().root.add_child(game_node)
	get_tree().root.remove_child(self)
	pass # Replace with function body.


func _on_hard_button_pressed() -> void:
	difficulty = 2
	game_node = get_node("/root/global_scene_node")
	if game_node != null:
		get_tree().root.remove_child(game_node)
	game_node = preload("res://scenes/scene/global_scene.tscn").instantiate()
	get_tree().root.add_child(game_node)
	get_tree().root.remove_child(self)
	pass # Replace with function body.
