extends Node

# Static variable to keep track of the ID counter
static var next_id: int = 0

# Static method to get a new incremented ID
static func get_new_id() -> int:
    var current_id = next_id
    next_id += 1
    return current_id