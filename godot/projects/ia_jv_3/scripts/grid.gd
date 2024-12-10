extends Node2D

@onready var line = $Line2D  # Reference to the Line2D node
@export var grid_size = 4  # Grid size (4x4)
@export var tile_size = 64  # Tile size in pixels
@export var colors = [Color.BLACK, Color.WHITE]  # Tile colors (black and white)

# Start and end points
@onready var start_point = $StartPoint.global_position
@onready var end_point = $EndPoint.global_position

var grid = []  # Store the static grid
var path_points: Array[Vector2] = []  # Store the player's drawn path
var state = "Idle"  # Current state
var solution_path: Array[Vector2] = []  # Static solution path


func _ready():
	# Set up a static grid
	grid = [
		[Color.BLACK, Color.WHITE, Color.BLACK, Color.WHITE],
		[Color.WHITE, Color.BLACK, Color.WHITE, Color.BLACK],
		[Color.BLACK, Color.WHITE, Color.BLACK, Color.WHITE],
		[Color.WHITE, Color.BLACK, Color.WHITE, Color.BLACK]
	]
	solution_path = [
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1),
		Vector2(2, 1), Vector2(3, 1), Vector2(3, 2),
		Vector2(3, 3)
	]

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
	draw_circle(start_point, tile_size * 0.1, Color.GREEN)
	draw_circle(end_point, tile_size * 0.1, Color.RED)


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
