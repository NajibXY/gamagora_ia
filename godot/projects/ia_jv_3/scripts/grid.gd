extends Node2D

@onready var line2D = $Line2D  # Reference to the Line2D node
@export var grid_size = 4  # Grid size (4x4)
@export var tile_size = 64  # Tile size in pixels
@export var colors = [Color.BLACK, Color.WHITE]  # Tile colors (black and white)

# Start and end points
@onready var start_point = $StartPoint.global_position
@onready var end_point = $EndPoint.global_position

var grid = []  # Store the static grid
var path_points: Array[Vector2] = []  # Store the player's drawn path
var solution_path: Array[Vector2] = []  # Static solution path

var intersection_points = []
var last_point = Vector2(0, 0)
var possibles_intersects = []

enum State { IDLE, FOCUS, DRAWING, CHECKING, COMPLETED }
var state = State.IDLE

var line_color:Color = Color.GREEN
var opacity_value = 0.1

func _ready():
	# Set up a static grid
	grid = [
		[Color.BLACK, Color.WHITE, Color.BLACK, Color.BLACK],
		[Color.BLACK, Color.WHITE, Color.BLACK, Color.BLACK],
		[Color.BLACK, Color.BLACK, Color.BLACK, Color.BLACK],
		[Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
	]
	
	# Static solution path
	solution_path = [
		Vector2(5, 5), Vector2(69, 5), Vector2(69, 69), Vector2(69, 133),
		Vector2(133, 133), Vector2(133, 69), Vector2(133, 5), Vector2(197, 5),
		Vector2(261, 5), Vector2(261, 69), Vector2(261, 133), Vector2(261, 197),
		Vector2(197, 197), Vector2(133, 197), Vector2(69, 197), Vector2(5, 197),
		Vector2(5, 261), Vector2(69, 261), Vector2(133, 261), Vector2(197, 261)
	]

	# Intersection coordinates
	# Nurture intersection_points with intersections between tiles
	for y in range(grid_size + 1):
		for x in range(grid_size + 1):
			intersection_points.append(Vector2(x * tile_size + 5, y * tile_size +5))
	
	# Set window opacity to opacity_value



# Main draw function, called at ready and when we queue_redraw() 
func _draw():
	for y in range(grid_size):
		for x in range(grid_size):
			_draw_tile(Vector2(x, y), grid[y][x])
	_draw_start_and_end_points()

	# Optionally draw start and end points
	_draw_start_and_end_points()

	# Drawing points
	for point in path_points:
		var point_color = Color.BLUE
		point_color.a = opacity_value # Set opacity to opacity_value
		draw_circle(point, tile_size * 0.1, point_color)

	# Draw line for path
	_draw_lines()

# Drawing lines between path points
func _draw_lines():
	# Draw lines between path points
	if path_points.size() > 1:
		line2D.clear_points()
		for point in path_points:
			line2D.add_point(point)
		line2D.default_color = line_color
		line2D.default_color.a = opacity_value # Set opacity to opacity_value
		line2D.queue_redraw()

# Draw the grid
func _draw_grid():
	for y in range(grid_size):
		for x in range(grid_size):
			_draw_tile(Vector2(x, y), grid[y][x])

# Drawing tiles
func _draw_tile(grid_pos: Vector2, color: Color):
	# Calculate position in the grid
	var tile_position = grid_pos * tile_size
	# Offset the tile position by 10 pixels to center it
	tile_position += Vector2(10, 10)
	var rect = Rect2(tile_position, Vector2(tile_size - 10, tile_size - 10))
	# Set opacity to opacity_value
	var tile_color = color
	tile_color.a = opacity_value
	draw_rect(rect, tile_color)

# Draw markers for start and end points
func _draw_start_and_end_points():
	# Draw markers for start and end points
	draw_circle(start_point, tile_size * 0.1, Color(1, 0, 0, opacity_value))  # Red with opacity_valueopacity
	draw_circle(end_point, tile_size * 0.1, Color(0, 1, 0, opacity_value))  # Green with opacity_valueopacity

func compare_path_to_solution() -> bool:
	if path_points.size() != solution_path.size():
		return false
	for i in range(path_points.size()):
		if path_points[i] != solution_path[i]:
			return false
	return true

func _input(event) -> void:
	
	if state == State.IDLE:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Move to FOCUS state when the player clicks the grid
			opacity_value = 1.0
			state = State.FOCUS
			$Label.text = "FOCUS"
			queue_redraw()

	elif state == State.FOCUS:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			# Check if it's near the start point
			if start_point.distance_to(mouse_pos) < tile_size * 0.5:
				print("Drawing")
				state = State.DRAWING
				opacity_value = 0.6
				$Label.text = "DRAWING"
				# make last_point the point in the intersection_points that is nearest the start_point
				var initial_point = Vector2(start_point.x + 2, start_point.y + 2)
				last_point = initial_point
				path_points.append(initial_point)
				# Update possibles_intersects to the new possible points from the last_point
				possibles_intersects.clear()
				for new_point in intersection_points:
					if last_point.distance_to(new_point) <= tile_size and last_point != new_point and new_point not in path_points:
						possibles_intersects.append(new_point)
				queue_redraw()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			print(state)
			print("back to idle")
			state = State.IDLE
			opacity_value = 0.1
			$Label.text = "IDLE"
			path_points.clear()
			# clear line2d
			line2D.clear_points()
			queue_redraw()

	elif state == State.DRAWING:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_viewport().get_mouse_position()
			if end_point.distance_to(mouse_pos) < tile_size * 0.5:
				## TODO add Control path TEMP
				# If coming from an intersect near end_point
				print(last_point.distance_to(end_point))
				print(tile_size+1)
				print(last_point.distance_to(end_point) <= tile_size+1)
				if last_point.distance_to(end_point) <= tile_size + 1:
					# add end_point to path_points
					path_points.append(end_point)
					$Label.text = "Checking..."
					queue_redraw()
					state = State.CHECKING
			# else if the click is in possible_intersects
			else:
				for point in possibles_intersects:
					if point.distance_to(mouse_pos) < tile_size * 0.5:
						path_points.append(point)
						last_point = point
						# Update possibles_intersects to the new possible points from the last_point
						possibles_intersects.clear()
						for new_point in intersection_points:
							if last_point.distance_to(new_point) <= tile_size and last_point != new_point and new_point not in path_points:
								possibles_intersects.append(new_point)
						print("added point")
						print(path_points)
						queue_redraw()
						break
		# Handle right click
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			print("reset to FOCUS")
			$Label.text = "FOCUS"
			opacity_value = 1.0
			state = State.FOCUS
			path_points.clear()
			# clear line2d
			line2D.clear_points()
			queue_redraw()

	elif state == State.CHECKING:
		print(compare_path_to_solution())
	# todo checking and completing
		

	
	
	
	
	


	
	
			
	
	
