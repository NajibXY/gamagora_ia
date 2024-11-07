extends Node2D

@export_range(0,100) var max_velocity : float = 50.0
@export_range(0,100) var min_velocity : float = 10.0
@export_range(0,50) var friendly_radius : float = 30.0
@export_range(0,50) var avoiding_radius : float = 15.0
@export_range(0,100) var alignment_factor : float = 10.0
@export_range(0,100) var cohesion_factor : float = 1.0
@export_range(0,100) var separation_factor : float = 2.0

const NUMBER_OF_BOIDS = 200 

var boids_positions = []
var boids_velocities = []

var IMAGE_SIZE = int(ceil(sqrt(NUMBER_OF_BOIDS)))
var boid_data : Image
var boid_data_texture : ImageTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_boids()
	for i in range(NUMBER_OF_BOIDS):
		print("Boid position: ", boids_positions[i], " // Boid velocity: ", boids_velocities[i])

	boid_data = Image.create(IMAGE_SIZE, IMAGE_SIZE, false, Image.FORMAT_RGBAH)
	boid_data_texture = ImageTexture.create_from_image(boid_data)

	$BoidParticles.amount = NUMBER_OF_BOIDS
	$BoidParticles.process_material.set_shader_parameter("boid_data", boid_data_texture)

	pass # Replace with function body.

func generate_boids():
	for i in range(NUMBER_OF_BOIDS):
		boids_positions.append(Vector2(randf() * get_viewport_rect().size.x, randf() * get_viewport_rect().size.y))
		boids_velocities.append(Vector2(randf_range(-1.0, 1.0) * max_velocity, randf_range(-1.0, 1.0) * max_velocity))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_data_on_cpu(delta)
	update_data_texture()
	pass

func update_data_texture():
	for i in range(NUMBER_OF_BOIDS):
		var pixel_pos = Vector2(int(i / IMAGE_SIZE), int(i % IMAGE_SIZE))
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
	
