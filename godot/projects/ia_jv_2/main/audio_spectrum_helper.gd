extends Node


signal spectrum_data(effects: Array)

const VU_COUNT = 7
const FREQ_MAX = 11050.0
const MIN_DB = 60

var spectrum
var main_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = get_node("/root/main_scene")
	spectrum = AudioServer.get_bus_effect_instance(1,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var prev_hz = 0
	var effects = []
	# for i in range(1, VU_COUNT + 1):
		# var hz = i * FREQ_MAX / VU_COUNT;
		# var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		# var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		# var effect = energy * main_node.Multiplier
		# # Effect should be normalized between 0 and 10
		# effect = clamp(effect, 0, 10)
		# # round to two decimal places
		# effect = round(effect * 100) / 100
		# effects.append(effect)
		# prev_hz = hz
	var magnitude = spectrum.get_magnitude_for_frequency_range(main_node.kick_frequency_min, main_node.kick_frequency_max).length()
	if magnitude > main_node.kick_threshold:
		print("Magnitude: ", magnitude)
		effects.append(magnitude)
		emit_signal("spectrum_data", effects)
	
	pass
