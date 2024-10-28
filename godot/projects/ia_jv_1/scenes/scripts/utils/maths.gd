########################################### Geometric Functions ###########################################


func get_positions_between(start: Vector2, end: Vector2, steps: int) -> Array:
    var positions = []
    for i in range(steps + 1):
        var t = i / float(steps)
        var interpolated_position = start.lerp(end, t)
        positions.append(interpolated_position)
    return positions