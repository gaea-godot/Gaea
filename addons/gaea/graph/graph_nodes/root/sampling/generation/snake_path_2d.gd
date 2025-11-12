@tool
class_name GaeaNodeSnakePath2D
extends GaeaNodeResource
## Generates a path that goes from the top of the world to the bottom,
## with each cell consisting of flags that indicate their exits (up, down, left, right).
##
## The algorithm starts from a random point in the top row of the generation area.[br]
## From there, it'll either move left, right or down, depending on the configured weights.[br]
## If it reaches a border, and tries to move outside the bounds of the generation area, it'll
## drop down.[br][br]
## Each cell has a value with flags representing the path the algorithm took. Whenever it drops down,
## the cell where it ended up will have the [param up] flag, for example, showing that the
## path is connected with an exit to the cell above (which has the [param down] flag).[br][br]
## This is how [url=https://www.spelunkyworld.com/]Spelunky[/url]
## generates its level layouts as seen [url=https://tinysubversions.com/spelunkyGen/]here[/url].


func _get_title() -> String:
	return "SnakePath2D"


func _get_description() -> String:
	return """Generates a path that goes from the top of the world to the bottom, \
with each cell consisting of flags that indicate their exits (up, down, left, right)."""


func _get_arguments_list() -> Array[StringName]:
	return [
		&"move_left_weight",
		&"move_right_weight",
		&"move_down_weight",
		&"CATEGORY_FLAGS",
		&"left",
		&"right",
		&"down",
		&"up"
	]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"move_left_weight", &"move_right_weight", &"move_down_weight":
			return GaeaValue.Type.INT
		&"left", &"right", &"down", &"up":
			return GaeaValue.Type.BITMASK_EXCLUSIVE

	return GaeaValue.Type.NULL


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"move_left_weight", &"move_right_weight", &"move_down_weight":
			return 40
		&"left":
			return 1
		&"right":
			return 2
		&"down":
			return 4
		&"up":
			return 8
	return super(arg_name)


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name.ends_with(&"weight"):
		return {"min": 0}

	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var direction_weights: Dictionary[Vector2i, float] = {
		Vector2i.LEFT: _get_arg(&"move_left_weight", graph, pouch),
		Vector2i.RIGHT: _get_arg(&"move_right_weight", graph, pouch),
		Vector2i.DOWN: _get_arg(&"move_down_weight", graph, pouch),
	}
	var left_flag: int = _get_arg(&"left", graph, pouch)
	var right_flag: int = _get_arg(&"right", graph, pouch)
	var down_flag: int = _get_arg(&"down", graph, pouch)
	var up_flag: int = _get_arg(&"up", graph, pouch)
	var direction_to_flags: Dictionary = {
		Vector2i.LEFT: left_flag,
		Vector2i.RIGHT: right_flag,
		Vector2i.DOWN: down_flag,
		Vector2i.UP: up_flag
	}

	var path: Dictionary
	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	var starting_cell: Vector2i = Vector2i(rng.randi_range(0, roundi(pouch.area.size.x - 1)), 0)
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

		if (current_cell + direction).x < 0 or (current_cell + direction).x >= pouch.area.size.x:
			direction = Vector2i.DOWN

		if direction == Vector2i.DOWN and (current_cell.y + 1) >= pouch.area.size.y:
			break

		path[current_cell] |= direction_to_flags.get(direction)

		last_cell = current_cell
		last_direction = direction
		current_cell += direction

	for cell in path:
		result.set_xyz(cell.x, cell.y, 0, path.get(cell))

	return result
