extends Label

var game_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game scene node update signal reception
	game_node = get_node("/root/global_scene_node/game_node")
	game_node.connect("score_signal", Callable(self, "_on_score_update"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_score_update():
	self.text = "Score : " + str(game_node.current_score)
	pass
