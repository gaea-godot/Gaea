@tool
class_name GaeaNodeFloorWalker
extends GaeaNodeResource
#gdlint:disable = max-line-length
## Generates a floor by using [b]walkers[/b], which move around and
## set cells where they walk to [code]1.0[/code], while changing direction and/or spawning new walkers.
##
## The algorithm starts from the [param starting_point]. It spawns a [GaeaNodeWalker] with that
## position, and that walker starts moving randomly. Depending on the chances configured,
## every 'turn' it has a chance to spawn a new walker, to change its direction, to be destroyed,
## to place cells in a bigger area, etc. All cells where it walks will be set to a value of
## [code]1.0[/code].[br]
## When a size of [param max_cells] is reached, the generation will stop.[br][br]
## This is how [url=https://nuclearthrone.com]Nuclear Throne[/url] does its generation,
## for example, as seen [url=https://web.archive.org/web/20151009004931/https://www.vlambeer.com/2013/04/02/random-level-generation-in-wasteland-kings/]here[/url].
#gdlint:enable = max-line-length

enum AxisType { XY, XZ }


## Walker as used in [GaeaNodeFloorWalker].
class Walker:
	var dir: Vector3  ## Current direction, should be in 90-degrees angles.
	var pos: Vector3  ## Current position, should be rounded.


func _get_title() -> String:
	return "FloorWalker"


func _get_description() -> String:
	return """Generates a floor by using [b]walkers[/b], which move around and set cells \
where they walk to [code]1.0[/code], while changing direction and/or spawning new walkers."""


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return AxisType


func _get_enum_option_display_name(_enum_idx: int, option_value: int) -> String:
	return "%s Axis" % AxisType.find_key(option_value)


func _get_arguments_list() -> Array[StringName]:
	return [
		&"max_cells",
		&"starting_position",
		&"CATEGORY_DIRECTION_CHANCES",
		&"direction_change_chance",
		&"rotate_90_weight",
		&"rotate_-90_weight",
		&"rotate_180_weight",
		&"CATEGORY_WALKER_CHANCE",
		&"new_walker_chance",
		&"destroy_walker_chance",
		&"bigger_room_chance",
		&"bigger_room_size_range"
	]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name.begins_with(&"CATEGORY"):
		return GaeaValue.Type.CATEGORY

	match arg_name:
		&"starting_position":
			return GaeaValue.Type.VECTOR3I
		&"bigger_room_size_range":
			return GaeaValue.Type.RANGE
		_:
			return GaeaValue.Type.INT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"max_cells":
			return 100
		&"direction_change_chance":
			return 50
		&"rotate_90_weight", &"rotate_-90_weight", &"rotate_180_weight":
			return 40
		&"new_walker_chance", &"destroy_walker_chance":
			return 5
		&"bigger_room_chance":
			return 15
		&"bigger_room_size_range":
			return {"min": 2, "max": 3}
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name == &"bigger_room_size_range":
		return {"min": 1, "max": 5, "suffix": "²", "step": 1, "allow_lesser": false}

	if arg_name.ends_with(&"chance"):
		return {"suffix": "%", "min": 0, "max": 100}

	if arg_name.ends_with(&"weight") or arg_name == &"max_cells":
		return {"min": 0}

	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_preview_simulation_size() -> SimSize:
	return SimSize.WORLD


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	_log_data(_output_port, graph)
	var axis_type: AxisType = get_enum_selection(0) as AxisType

	var starting_position: Vector3 = _get_arg(&"starting_position", graph, pouch)
	starting_position = starting_position.round()

	var rotation_weights: Dictionary = {
		PI * 0.5: _get_arg(&"rotate_90_weight", graph, pouch),
		-PI * 0.5: _get_arg(&"rotate_-90_weight", graph, pouch),
		PI: _get_arg(&"rotate_180_weight", graph, pouch)
	}
	var direction_change_chance: float = (
		float(_get_arg(&"direction_change_chance", graph, pouch)) * 0.01
	)
	var new_walker_chance: float = float(_get_arg(&"new_walker_chance", graph, pouch)) * 0.01
	var destroy_walker_chance: float = (
		float(_get_arg(&"destroy_walker_chance", graph, pouch)) * 0.01
	)
	var bigger_room_chance: float = float(_get_arg(&"bigger_room_chance", graph, pouch)) * 0.01
	var bigger_room_size_range: Dictionary = _get_arg(&"bigger_room_size_range", graph, pouch)

	var max_cells: int = _get_arg(&"max_cells", graph, pouch)
	max_cells = mini(
		max_cells,
		(
			roundi(pouch.area.size.x)
			* (roundi(pouch.area.size.y) if axis_type == AxisType.XY else roundi(pouch.area.size.z))
		)
	)

	var walkers: Array[Walker]
	var walked_cells: Array[Vector3i]

	var iterations: int = 0

	_add_walker(starting_position, walkers)

	while iterations < 10000 and walked_cells.size() < max_cells:
		for walker in walkers:
			if rng.randf() <= destroy_walker_chance and walkers.size() > 1:
				walkers.erase(walker)
				continue

			if rng.randf() <= new_walker_chance:
				_add_walker(walker.pos, walkers)

			if rng.randf() <= direction_change_chance:
				var direction: int = rng.rand_weighted(rotation_weights.values())
				walker.dir = walker.dir.rotated(
					Vector3(0, 0, 1) if axis_type == AxisType.XY else Vector3(0, 1, 0),
					rotation_weights.keys()[direction]
					).round()

			if rng.randf() <= bigger_room_chance:
				var size: int = rng.randi_range(
					bigger_room_size_range.min, bigger_room_size_range.max
				)
				for cell in _get_square_room(
					walker.pos,
					Vector3(
						size,
						size if axis_type == AxisType.XY else 1,
						size if axis_type == AxisType.XZ else 1
					)
				):
					cell = cell.clamp(pouch.area.position, pouch.area.end - Vector3.ONE)
					if not walked_cells.has(Vector3i(cell)):
						walked_cells.append(Vector3i(cell))

			walker.pos += walker.dir
			walker.pos = walker.pos.clamp(pouch.area.position, pouch.area.end - Vector3.ONE)

			if not walked_cells.has(Vector3i(walker.pos)):
				walked_cells.append(Vector3i(walker.pos))

			if walked_cells.size() >= max_cells:
				break

		iterations += 1

	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	for cell in walked_cells:
		result.set_cell(cell, 1.0)

	return result


func _add_walker(pos: Vector3, array: Array[Walker]) -> void:
	var walker: Walker = Walker.new()
	walker.pos = pos
	walker.dir = (
		[
			Vector3.LEFT,
			Vector3.RIGHT,
			Vector3.DOWN if get_enum_selection(0) == AxisType.XY else Vector3.FORWARD,
			Vector3.UP if get_enum_selection(0) == AxisType.XY else Vector3.BACK
		]
		. pick_random()
	)
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
