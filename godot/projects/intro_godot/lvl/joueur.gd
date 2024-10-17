extends Node2D

var count = 0
@export var speed : Vector2 = Vector2(100,0)
@export var scale_growth : Vector2 = Vector2(1.05,1.05)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello, world!")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	count+=1
	print("Frame count: ", count)

	$logo.transform.origin = $logo.transform.origin + speed * delta
	$logo.scale = $logo.scale * scale_growth

	pass
