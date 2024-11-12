extends CanvasLayer

@onready var boid_manager = $"/root/main_scene"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HBoxNumBoi/HSlider.value_changed.connect(update_boids_number)

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

	$VBoxContainer2/HBoxColMod/OptionButton.item_selected.connect(update_color_mode)
	pass # Replace with function body.

func update_color_mode(value) :
	boid_manager.boid_color_mode = value

func update_boids_number (value) :
	boid_manager.update_boids_number(value)

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
	boid_manager.stutter_on_kick = checked

##############################################################################################################

func set_parameters() :
	$VBoxContainer/HBoxNumBoi/HSlider.value = boid_manager.number_of_boids

	$VBoxContainer/HBoxMaxVel/HSlider.value = boid_manager.max_velocity
	$VBoxContainer/HBoxMinVel/HSlider.value = boid_manager.min_velocity
	$VBoxContainer/HBoxFriRad/HSlider.value = boid_manager.friendly_radius
	$VBoxContainer/HBoxAvoRad/HSlider.value = boid_manager.avoiding_radius
	$VBoxContainer/HBoxAliFac/HSlider.value = boid_manager.alignment_factor
	$VBoxContainer/HBoxCohFac/HSlider.value = boid_manager.cohesion_factor
	$VBoxContainer/HBoxSepFac/HSlider.value = boid_manager.separation_factor

	$VBoxContainer/HBoxMaxVelMul/HSlider.value = boid_manager.audio_mult_maxv
	$VBoxContainer/HBoxMinVelMul/HSlider.value = boid_manager.audio_mult_minv
	$VBoxContainer/HBoxFriRadMul/HSlider.value = boid_manager.audio_mult_friendly
	$VBoxContainer/HBoxAvoRadMul/HSlider.value = boid_manager.audio_mult_avoiding
	$VBoxContainer/HBoxAliFacMul/HSlider.value = boid_manager.audio_mult_alignment
	$VBoxContainer/HBoxCohFacMul/HSlider.value = boid_manager.audio_mult_cohesion
	$VBoxContainer/HBoxSepFacMul/HSlider.value = boid_manager.audio_mult_separation

	$VBoxContainer/HBoxStuOnKick/CheckButton.button_pressed = boid_manager.stutter_on_kick
	pass

##TOFDO: Add the rest of the sliders, frequency, threshhold etc ?

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
