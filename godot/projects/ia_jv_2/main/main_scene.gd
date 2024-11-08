extends Node2D

# Boid parameters
@export_category("Boid Parameters")
@export_range(1,300) var max_velocity : float = 50.0
@export_range(0,100) var min_velocity : float = 10.0
@export_range(0,50) var friendly_radius : float = 30.0
@export_range(0,50) var avoiding_radius : float = 15.0
@export_range(0,50) var alignment_factor : float = 10.0
@export_range(0,10) var cohesion_factor : float = 1.0
@export_range(0,50) var separation_factor : float = 2.0

# Audio reaction parameters
@export_category("Audio Reaction Parameters")
@export_range(1,10) var audio_mult_maxv : int = 1
@export_range(1,10) var audio_mult_minv : int = 1
@export_range(1,10) var audio_mult_friendly : int = 1
@export_range(1,10) var audio_mult_avoiding : int = 1
@export_range(1,10) var audio_mult_alignment : int = 1
@export_range(1,10) var audio_mult_cohesion : int = 1
@export_range(1,10) var audio_mult_separation : int = 1
@export var stutter_on_kick : bool = false

@export_range(0,10) var Multiplier : float = 5.0
@export var kick_frequency_min : float = 50.0  # Minimum frequency for kick
@export var kick_frequency_max : float = 150.0  # Maximum frequency for kick
@export var kick_threshold = 0.1  # Adjust this based on sensitivity
var is_kick = false

# @export_range(0,100) var max_velocity : float = 50.0
# @export_range(0,100) var min_velocity : float = 10.0
# @export_range(0,50) var friendly_radius : float = 30.0
# @export_range(0,50) var avoiding_radius : float = 15.0
# @export_range(0,100) var alignment_factor : float = 10.0
# @export_range(0,100) var cohesion_factor : float = 1.0
# @export_range(0,100) var separation_factor : float = 2.0

const NUMBER_OF_BOIDS = 30000

var boids_positions = []
var boids_velocities = []

var IMAGE_SIZE = int(ceil(sqrt(NUMBER_OF_BOIDS)))
var boid_data : Image
var boid_data_texture : ImageTexture

# Compute shader stuff
var SIMULATE_GPU = true
var rd : RenderingDevice
var boid_compute_shader : RID
var boid_pipeline : RID
var bindings : Array
var uniform_set : RID

var boid_pos_buffer : RID
var boid_vel_buffer : RID
var params_buffer: RID
var params_uniform : RDUniform
var boid_data_buffer : RID

var last_delta = 0.0

@onready var file_dialog : FileDialog = $FileDialog
@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# for i in range(NUMBER_OF_BOIDS):
	# 	print("Boid position: ", boids_positions[i], " // Boid velocity: ", boids_velocities[i])

	boid_data = Image.create(IMAGE_SIZE, IMAGE_SIZE, false, Image.FORMAT_RGBAH)
	boid_data_texture = ImageTexture.create_from_image(boid_data)

	generate_boids()

	$BoidParticles.amount = NUMBER_OF_BOIDS
	$BoidParticles.process_material.set_shader_parameter("boid_data", boid_data_texture)

	if SIMULATE_GPU:
		setup_computer_shader()
		update_boids_on_gpu(0)

	file_dialog.popup_centered()
	file_dialog.filters = ["*.mp3 ; MP3 Files", "*.wav ; WAV Files"]
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	file_dialog.show()

	pass # Replace with function body.

func _on_file_selected(path: String):
	# Load and play the selected audio file
	var audio_stream = load(path) as AudioStream
	if audio_stream:
		audio_stream_player.stream = audio_stream
		audio_stream_player.play()
		var audio_spectrum_helper = get_node("/root/main_scene/AudioSpectrumHelper")
		audio_spectrum_helper.spectrum_data.connect(Callable(self, "_on_spectrum_data_received"))
	pass

func _on_spectrum_data_received(effects):
	print("received")
	is_kick = true
	pass

func generate_boids():
	for i in range(NUMBER_OF_BOIDS):
		boids_positions.append(Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y))
		boids_velocities.append(Vector2(randf_range(-1.0, 1.0) * max_velocity, randf_range(-1.0, 1.0) * max_velocity))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Changing File menu ?
	if Input.is_action_just_pressed("ui_file"):
		file_dialog.popup_centered()
		file_dialog.filters = ["*.mp3 ; MP3 Files", "*.wav ; WAV Files"]
		file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
		file_dialog.show()

	last_delta = delta
	get_window().title = "FPS : " + str(Engine.get_frames_per_second()) + " / " + " Boids : " + str(NUMBER_OF_BOIDS)
	
	if SIMULATE_GPU:
		sync_boids_on_gpu()
	else:
		update_data_on_cpu(delta)

	update_data_texture()

	if SIMULATE_GPU:
		update_boids_on_gpu(delta)

	pass

func update_data_texture():
	if SIMULATE_GPU:
		var data := rd.texture_get_data(boid_data_buffer, 0)
		boid_data.set_data(IMAGE_SIZE, IMAGE_SIZE, false, Image.FORMAT_RGBAH, data)
	else:
		for i in range(NUMBER_OF_BOIDS):
			var pixel_pos = Vector2(int(i / float(IMAGE_SIZE)), int(i % IMAGE_SIZE))
			boid_data.set_pixel(pixel_pos.x, pixel_pos.y, Color(boids_positions[i].x, boids_positions[i].y, boids_velocities[i].angle(), 0))
	boid_data_texture.update(boid_data)

func update_data_on_cpu(delta: float):
	for i in NUMBER_OF_BOIDS:
		# Get the boid position and velocity
		var boid_pos = boids_positions[i]
		var boid_vel = boids_velocities[i]

		# Init vectors
		var avg_vel = Vector2.ZERO
		var middle_pos = Vector2.ZERO
		var separation_vec = Vector2.ZERO
		var num_friends = 0
		var num_avoids = 0 
		for j in NUMBER_OF_BOIDS:
			if i != j:
				var other_boid_pos = boids_positions[j]
				var other_boid_vel = boids_velocities[j]
				var dist = boid_pos.distance_to(other_boid_pos)
				if dist < friendly_radius:
					avg_vel += other_boid_vel
					middle_pos += other_boid_pos
					num_friends += 1
				if dist < avoiding_radius:
					separation_vec += boid_pos - other_boid_pos
					num_avoids += 1
		if num_friends > 0:
			avg_vel /= num_friends
			avg_vel += avg_vel.normalized() * alignment_factor

			middle_pos /= num_friends
			boid_vel += (middle_pos - boid_pos).normalized() * cohesion_factor
			
			if num_avoids > 0:
				separation_vec /= num_avoids
				boid_vel += separation_vec.normalized() * separation_factor

		var velocity_magnitude = boid_vel.length()
		velocity_magnitude = clamp(velocity_magnitude, min_velocity, max_velocity)
		boid_vel = boid_vel.normalized() * velocity_magnitude

		boid_pos += boid_vel * delta
		boid_pos = Vector2(wrapf(boid_pos.x, 0, get_viewport_rect().size.x, ), 
						   wrapf(boid_pos.y, 0, get_viewport_rect().size.y, ))

		boids_positions[i] = boid_pos
		boids_velocities[i] = boid_vel
	pass
	
############################################### INIT COMPUTE SHADER ###############################################

func setup_computer_shader():
	rd = RenderingServer.create_local_rendering_device()

	var shader_file := load("res://compute_shaders/boid_simulation.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	boid_compute_shader = rd.shader_create_from_spirv(shader_spirv)
	boid_pipeline = rd.compute_pipeline_create(boid_compute_shader)

	boid_pos_buffer = generate_vec2_buffer(boids_positions)
	var boid_pos_uniform = generate_uniform(boid_pos_buffer, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, 0)

	boid_vel_buffer = generate_vec2_buffer(boids_velocities)
	var boid_vel_uniform = generate_uniform(boid_vel_buffer, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, 1)

	params_buffer = generate_parameter_buffer(0)
	params_uniform = generate_uniform(params_buffer, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, 2)

	var fmt := RDTextureFormat.new()
	fmt.width = IMAGE_SIZE
	fmt.height = IMAGE_SIZE
	fmt.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

	var view := RDTextureView.new()
	boid_data_buffer = rd.texture_create(fmt, view, [boid_data.get_data()])
	var boid_data_buffer_uniform = generate_uniform(boid_data_buffer, RenderingDevice.UNIFORM_TYPE_IMAGE, 3)

	bindings = [boid_pos_uniform, boid_vel_uniform, params_uniform, boid_data_buffer_uniform]



func generate_vec2_buffer(data):
	var data_buffer_bytes := PackedVector2Array(data).to_byte_array()
	var data_buffer = rd.storage_buffer_create(data_buffer_bytes.size(), data_buffer_bytes)
	return data_buffer

func generate_int_buffer(size):
	var data = []
	data.resize(size)
	var data_buffer_bytes = PackedInt32Array(data).to_byte_array()
	var data_buffer = rd.storage_buffer_create(data_buffer_bytes.size(), data_buffer_bytes)
	return data_buffer
	
func generate_uniform(data_buffer, type, binding):
	var data_uniform = RDUniform.new()
	data_uniform.uniform_type = type
	data_uniform.binding = binding
	data_uniform.add_id(data_buffer)
	return data_uniform

func generate_parameter_buffer(delta):
	var params_buffer_bytes : PackedByteArray = PackedFloat32Array(
		[NUMBER_OF_BOIDS, 
		IMAGE_SIZE, 
		friendly_radius,
		avoiding_radius,
		min_velocity, 
		max_velocity,
		alignment_factor,
		cohesion_factor,
		separation_factor,
		get_viewport_rect().size.x,
		get_viewport_rect().size.y,
		delta,
		false
		# , pause, boid_color_mode
		]).to_byte_array()
	
	return rd.storage_buffer_create(params_buffer_bytes.size(), params_buffer_bytes)

func generate_parameter_buffer_reaction_kick(delta):
	#todo clamp values ?
	var params_buffer_bytes : PackedByteArray = PackedFloat32Array(
		[NUMBER_OF_BOIDS, 
		IMAGE_SIZE, 
		friendly_radius / audio_mult_friendly,
		avoiding_radius * audio_mult_avoiding,
		min_velocity * audio_mult_minv, 
		max_velocity * audio_mult_maxv,
		alignment_factor / audio_mult_alignment,
		cohesion_factor / audio_mult_cohesion,
		separation_factor * audio_mult_separation,
		get_viewport_rect().size.x,
		get_viewport_rect().size.y,
		delta,
		stutter_on_kick
		# , pause, boid_color_mode
		]).to_byte_array()
	
	return rd.storage_buffer_create(params_buffer_bytes.size(), params_buffer_bytes)

############################################## RUN COMPUTE SHADER ##############################################
func update_boids_on_gpu(delta):
	if is_kick:
		rd.free_rid(params_buffer)
		params_buffer = generate_parameter_buffer_reaction_kick(delta)
		params_uniform.clear_ids()
		params_uniform.add_id(params_buffer)
		uniform_set = rd.uniform_set_create(bindings, boid_compute_shader, 0)

		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, boid_pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)

		rd.compute_list_dispatch(compute_list, ceil(NUMBER_OF_BOIDS/1024.), 1, 1)
		rd.compute_list_end()
		rd.submit()
		is_kick = false
	else:
		rd.free_rid(params_buffer)
		params_buffer = generate_parameter_buffer(delta)
		params_uniform.clear_ids()
		params_uniform.add_id(params_buffer)
		uniform_set = rd.uniform_set_create(bindings, boid_compute_shader, 0)

		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, boid_pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)

		rd.compute_list_dispatch(compute_list, ceil(NUMBER_OF_BOIDS/1024.), 1, 1)
		rd.compute_list_end()
		rd.submit()

func sync_boids_on_gpu():
	rd.sync()

func _exit_tree():
	if SIMULATE_GPU:
		sync_boids_on_gpu()
		rd.free_rid(uniform_set)
		rd.free_rid(boid_pos_buffer)
		rd.free_rid(boid_vel_buffer)
		rd.free_rid(params_buffer)
		rd.free_rid(boid_data_buffer)
		rd.free_rid(boid_compute_shader)
		rd.free_rid(boid_pipeline)
		rd.free()
	pass
