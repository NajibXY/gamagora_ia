extends Node2D

var logo_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logo_node = get_node("joueur/logo")
	$joueur.position.x = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (logo_node.scale.x > 2):
		logo_node.scale = Vector2(0.3, 0.3)

	$tete.transform.origin += Input.get_vector("gauche", "droite", "haut", "bas") * 2
	pass
