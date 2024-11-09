extends CanvasLayer

@onready var boid_manager = $"/root/main_scene"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HBoxMaxVel/HSlider.value_changed.connect(update_max_velocity)
	pass # Replace with function body.

func update_max_velocity (value) :
	print(value)
	boid_manager.max_velocity = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
