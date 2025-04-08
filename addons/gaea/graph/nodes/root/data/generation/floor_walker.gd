@tool
extends GaeaNodeResource


@export var second_axis: Axis = Axis.Y


class Walker:
	var dir: Vector3
	var pos: Vector3


func get_data(_passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)
	
	var _starting_position: Vector3 = get_arg("starting_position", generator_data)
	_starting_position = _starting_position.round()

	var rotation_weights: Dictionary = {
		PI / 2.0: get_arg("rotate_90_weight", generator_data),
		-PI / 2.0: get_arg("rotate_-90_weight", generator_data),
		PI: get_arg("rotate_180_weight", generator_data)
	}
	var direction_change_chance: float = float(get_arg("direction_change_chance", generator_data)) / 100.0
	var new_walker_chance: float = float(get_arg("new_walker_chance", generator_data)) / 100.0
	var destroy_walker_chance: float = float(get_arg("destroy_walker_chance", generator_data)) / 100.0
	var bigger_room_chance: float = float(get_arg("bigger_room_chance", generator_data)) / 100.0
	var bigger_room_size_range: Dictionary = get_arg("bigger_room_size_range", generator_data)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.set_seed(generator_data.generator.seed + salt)
	seed(generator_data.generator.seed + salt)
	var max_cells: int = get_arg("max_cells", generator_data)
	max_cells = mini(
		max_cells,
		roundi(area.size.x) * (roundi(area.size.y) if second_axis == Axis.Y else roundi(area.size.z))
	)

	var _walkers: Array[Walker]
	var _walked_cells: Array[Vector3i]

	var iterations: int = 0

	_add_walker(_starting_position, _walkers)

	while iterations < 10000 and _walked_cells.size() < max_cells:
		for walker in _walkers:

			if rng.randf() <= destroy_walker_chance and _walkers.size() > 1:
				_walkers.erase(walker)
				continue

			if rng.randf() <= new_walker_chance:
				_add_walker(walker.pos, _walkers)

			if rng.randf() <= direction_change_chance:
				walker.dir = walker.dir.rotated(
					Vector3(0, 0, 1) if second_axis == Axis.Y else Vector3(0, 1, 0),
					rotation_weights.keys()[rng.rand_weighted(rotation_weights.values())]
					).round()

			if rng.randf() <= bigger_room_chance:
				var size: int = rng.randi_range(bigger_room_size_range.min, bigger_room_size_range.max)
				for cell in _get_square_room(walker.pos, Vector3(size, size if second_axis == Axis.Y else 1, size if second_axis == Axis.Z else 1)):
					cell = cell.clamp(area.position, area.end - Vector3.ONE)
					if not _walked_cells.has(Vector3i(cell)):
						_walked_cells.append(Vector3i(cell))

			walker.pos += walker.dir
			walker.pos = walker.pos.clamp(area.position, area.end - Vector3.ONE )

			if not _walked_cells.has(Vector3i(walker.pos)):
				_walked_cells.append(Vector3i(walker.pos))

			if _walked_cells.size() >= max_cells:
				break

		iterations += 1

	var grid: Dictionary[Vector3i, float]
	for cell in _walked_cells:
		grid[cell] = 1.0

	return grid


func _add_walker(pos: Vector3, array: Array[Walker]) -> void:
	var walker: Walker = Walker.new()
	walker.pos = pos
	walker.dir = [
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.DOWN if second_axis == Axis.Y else Vector3.FORWARD,
		Vector3.UP if second_axis == Axis.Y else Vector3.BACK].pick_random()
	array.append(walker)


func _get_square_room(starting_pos: Vector3, size: Vector3) -> PackedVector3Array:
	var tiles: PackedVector3Array = []
	var x_offset = floor(size.x / 2)
	var y_offset = floor(size.y / 2)
	var z_offset = floor(size.z / 2)
	for x in size.x:
		for y in size.y:
			for z in size.z:
				var coords = starting_pos + Vector3(x - x_offset, y - y_offset, z - z_offset)
				tiles.append(coords)
	return tiles
