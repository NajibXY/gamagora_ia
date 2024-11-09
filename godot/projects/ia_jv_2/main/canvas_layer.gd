extends CanvasLayer

@onready var boid_manager = $"/root/main_scene"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HBoxMaxVel/HSlider.value_changed.connect(update_max_velocity)
	$VBoxContainer/HBoxMinVel/HSlider.value_changed.connect(update_min_velocity)
	$VBoxContainer/HBoxFriRad/HSlider.value_changed.connect(update_friendly_radius)
	$VBoxContainer/HBoxAvoRad/HSlider.value_changed.connect(update_avoiding_radius)
	$VBoxContainer/HBoxAliFac/HSlider.value_changed.connect(update_alignment_factor)
	$VBoxContainer/HBoxCohFac/HSlider.value_changed.connect(update_cohesion_factor)
	$VBoxContainer/HBoxSepFac/HSlider.value_changed.connect(update_separation_factor)

	$VBoxContainer/HBoxMaxVelMul/HSlider.value_changed.connect(update_max_velocity_mul)
	$VBoxContainer/HBoxMinVelMul/HSlider.value_changed.connect(update_min_velocity_mul)
	$VBoxContainer/HBoxFriRadMul/HSlider.value_changed.connect(update_friendly_radius_mul)
	$VBoxContainer/HBoxAvoRadMul/HSlider.value_changed.connect(update_avoiding_radius_mul)
	$VBoxContainer/HBoxAliFacMul/HSlider.value_changed.connect(update_alignment_factor_mul)
	$VBoxContainer/HBoxCohFacMul/HSlider.value_changed.connect(update_cohesion_factor_mul)
	$VBoxContainer/HBoxSepFacMul/HSlider.value_changed.connect(update_separation_factor_mul)

	$VBoxContainer/HBoxStuOnKick/CheckButton.toggled.connect(update_stutter_on_kick)
	pass # Replace with function body.

func update_max_velocity (value) :
	boid_manager.max_velocity = value

func update_min_velocity (value) :
	boid_manager.min_velocity = value

func update_friendly_radius (value) :
	boid_manager.friendly_radius = value

func update_avoiding_radius (value) :
	boid_manager.avoiding_radius = value

func update_alignment_factor (value) :
	boid_manager.alignment_factor = value

func update_cohesion_factor (value) :
	boid_manager.cohesion_factor = value

func update_separation_factor (value) :
	boid_manager.separation_factor = value

##############################################################################################################

func update_max_velocity_mul (value) :
	boid_manager.audio_mult_maxv = value

func update_min_velocity_mul (value) :
	boid_manager.audio_mult_minv = value

func update_friendly_radius_mul (value) :
	boid_manager.audio_mult_friendly = value

func update_avoiding_radius_mul (value) :
	boid_manager.audio_mult_avoiding = value

func update_alignment_factor_mul (value) :
	boid_manager.audio_mult_alignment = value

func update_cohesion_factor_mul (value) :
	boid_manager.audio_mult_cohesion = value

func update_separation_factor_mul (value) :
	boid_manager.audio_mult_separation = value

func update_stutter_on_kick (checked: bool) :
	print(checked)
	boid_manager.stutter_on_kick = checked

##############################################################################################################


##TOFDO: Add the rest of the sliders, frequency, threshhold etc ?

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
