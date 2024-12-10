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


enum State { IDLE, SOLVING, DRAWING, COMPLETED }
var state = State.IDLE

func _ready():
	# Set up a static grid
	grid = [
		[Color.BLACK, Color.WHITE, Color.WHITE, Color.WHITE],
		[Color.BLACK, Color.BLACK, Color.WHITE, Color.WHITE],
		[Color.BLACK, Color.BLACK, Color.BLACK, Color.WHITE],
		[Color.BLACK, Color.BLACK, Color.BLACK, Color.BLACK]
	]
	# TODO
	solution_path = [
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1),
		Vector2(2, 1), Vector2(3, 1), Vector2(3, 2),
		Vector2(3, 3)
	]

	# var x_pos = 0
	# var y_pos = 0
	# for y in range(grid_size + 1):
	# 	for x in range(grid_size + 1):
	# 		intersection_points_coordinates.append(Vector2(x_pos, y_pos))
	# 		x_pos += tile_size
	# 	y_pos += tile_size			

func _unhandled_input(event):
	match state:
		"Idle":
			_handle_idle(event)
		"Drawing":
			_handle_drawing(event)
		_:
			pass


func _draw():
	for y in range(grid_size):
		for x in range(grid_size):
			_draw_tile(Vector2(x, y), grid[y][x])
	_draw_start_and_end_points()

	# Optionally draw start and end points
	_draw_start_and_end_points()

	for point in path_points:
		draw_circle(point, tile_size * 0.1, Color.BLUE)
	


func _draw_tile(grid_pos: Vector2, color: Color):
	# Calculate position in the grid
	var tile_position = grid_pos * tile_size
	#canvas_item.update()
	# Offset the tile position by 10 pixels to center it
	tile_position += Vector2(10, 10)

	var rect = Rect2(tile_position, Vector2(tile_size-10, tile_size-10))
	draw_rect(rect, color)
	print("Drawing tile at:", grid_pos, "with color:", color, " at position:", tile_position)
	# canvas_item.connect("draw", Callable(self, "_draw_rectangle"))
	# canvas_item.connect("draw", self.Callable("_draw_rectangle"), [position, tile_size, color])

func _draw_grid():
	for y in range(grid_size):
		for x in range(grid_size):
			_draw_tile(Vector2(x, y), grid[y][x])

	
func _draw_start_and_end_points():
	# Draw markers for start and end points
	print("drawing circle")
	draw_circle(start_point, tile_size * 0.1, Color.RED)
	draw_circle(end_point, tile_size * 0.1, Color.GREEN)


func _handle_idle(event):
	return
	# if event is InputEventScreenTouch and event.pressed:
	# 	# Start drawing a path
	# 	state = "Drawing"
	# 	line.clear_points()  # Clear previous path
	# 	path_points.clear()

func _handle_drawing(event):
	return
	# if event is InputEventScreenTouch:
	# 	# Add points to the path as the player moves
	# 	path_points.append(event.position)
	# 	line.add_point(event.position)

	# if event is InputEventScreenTouch and not event.pressed:
	# 	# Finished drawing
	# 	state = "Validating"
	# 	_validate_path()

func _input(event) -> void:
	# if event is InputEventMouseButton and event.pressed:
		# Get mouse position in grid coordinates
	# var mouse_pos = get_viewport().get_mouse_position()
	# var grid_x = int(mouse_pos.x / tile_size)
	# var grid_y = int(mouse_pos.y / tile_size)

	# # Check if the click is inside the grid
	# if grid_x >= 0 and grid_x < grid_size and grid_y >= 0 and grid_y < grid_size:
	# 	# line.clear_points()
	# 	# line.add_point(Vector2(grid_x * tile_size, grid_y * tile_size))
	# 	print("inside grid with x :", grid_x, " y: ", grid_y)
	# 	# Draw a line in red as outline of cells
	# 	# draw_line(Vector2(grid_x * tile_size, grid_y * tile_size), Vector2(grid_x * tile_size + tile_size, grid_y * tile_size), Color.RED)
		
	# 	print("appending line")
	# 	lines.append([Vector2(5, 0), Vector2(5, 64)])
	# 	queue_redraw()
	
	if event is InputEventMouseButton and event.pressed:
		if state == State.IDLE:
		# Move to solving state when the player clicks the grid
			state = State.SOLVING
		elif state == State.SOLVING:
			var mouse_pos = get_viewport().get_mouse_position()
			# Check if it's near the start point
			if start_point.distance_to(mouse_pos) < tile_size * 0.5:
				state = State.DRAWING
				path_points.clear()

	elif event is InputEventMouseMotion:
		if state == State.DRAWING:
			var mouse_pos = get_viewport().get_mouse_position()
			# Check if it's near the end point
			if end_point.distance_to(mouse_pos) < tile_size * 0.5:
				# TODO Check if the path is correct
				state = State.COMPLETED
			else:
				var grid_x = int(mouse_pos.x / tile_size)
				var grid_y = int(mouse_pos.y / tile_size)
				var cell_pos = Vector2(grid_x, grid_y) * tile_size

				# Check if the mouse position is on the border of the cell
				if (abs(mouse_pos.x - cell_pos.x) < 5 or abs(mouse_pos.x - (cell_pos.x + tile_size)) < 5 or
					abs(mouse_pos.y - cell_pos.y) < 5 or abs(mouse_pos.y - (cell_pos.y + tile_size)) < 5):
					
					# Ensure the path is connected
					if path_points.size() > 0:
						var last_point = path_points[path_points.size() - 1]
						if last_point.distance_to(mouse_pos) <= tile_size * 0.1:
							path_points.append(mouse_pos)
							queue_redraw()
					else:
						path_points.append(mouse_pos)
						queue_redraw()

	# Handle right click
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if state == State.DRAWING:
			state = State.SOLVING
			path_points.clear()
			queue_redraw()
	
	
	
	
	


	
	
			
	
	
