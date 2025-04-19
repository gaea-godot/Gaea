@tool
extends GaeaNodeResource


func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var direction_weights: Dictionary[Vector2i, float] = {
		Vector2i.LEFT: get_arg(&"move_left_weight", area, generator_data),
		Vector2i.RIGHT: get_arg(&"move_right_weight", area, generator_data),
		Vector2i.DOWN: get_arg(&"move_down_weight", area, generator_data),
	}
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var left_flag: int = get_arg(&"left", area, generator_data)
	var right_flag: int = get_arg(&"right", area, generator_data)
	var down_flag: int = get_arg(&"down", area, generator_data)
	var up_flag: int = get_arg(&"up", area, generator_data)
	var direction_to_flags: Dictionary = {
		Vector2i.LEFT: left_flag,
		Vector2i.RIGHT: right_flag,
		Vector2i.DOWN: down_flag,
		Vector2i.UP: up_flag
	}
	rng.set_seed(generator_data.generator.seed + salt)

	var path: Dictionary
	var grid: Dictionary[Vector3i, float] = {}
	var starting_cell: Vector2i = Vector2i(rng.randi_range(0, area.size.x - 1), 0)
	var last_cell: Vector2i = starting_cell
	var current_cell: Vector2i = starting_cell
	var last_direction: Vector2i = Vector2i.ZERO

	while true:
		path[current_cell] = direction_to_flags.get(-last_direction, 0)
		if path.get(last_cell, 0) & down_flag:
			path[current_cell] |= up_flag

		var direction: Vector2i
		while path.has(current_cell + direction):
			direction = direction_weights.keys()[rng.rand_weighted(direction_weights.values())]

		if (current_cell + direction).x < 0 or (current_cell + direction).x >= area.size.x:
			direction = Vector2i.DOWN

		if direction == Vector2i.DOWN and (current_cell.y + 1) >= area.size.y:
			break

		path[current_cell] |= direction_to_flags.get(direction)

		last_cell = current_cell
		last_direction = direction
		current_cell += direction

	for cell in path:
		grid[Vector3i(cell.x, cell.y, 0)] = path.get(cell)

	return output_port.return_value(grid)
