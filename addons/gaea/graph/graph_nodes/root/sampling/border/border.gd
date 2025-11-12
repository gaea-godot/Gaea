@tool
class_name GaeaNodeBorder2D
extends GaeaNodeResource
## Returns the border of [param sample]. If [param inside] is [code]true[/code], returns the inner border.
##
## Loops through all the points in the generation area.[br]
## - If [param inside] is [code]false[/code],
## returns only the points that don't exist in [param sample]
## and that have a value in all the [param neighbors] offsets.[br]
## - If [param inside] is [code]true[/code],
## it'll return instead the cells in [param sample] that have empty points in all the [param neighbors] offsets.[br][br]
## Output sample is a grid of [code]1.0[/code]s.


func _get_title() -> String:
	return "Border2D"


func _get_description() -> String:
	return "Returns the border of [param sample]. If [param inside] is [code]true[/code], returns the inner border."


func _get_arguments_list() -> Array[StringName]:
	return [&"sample", &"neighbors", &"inside"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"sample":
			return GaeaValue.Type.SAMPLE
		&"neighbors":
			return GaeaValue.Type.NEIGHBORS
		&"inside":
			return GaeaValue.Type.BOOLEAN
	return GaeaValue.Type.NULL


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"neighbors":
			return [Vector3i.RIGHT, Vector3i.LEFT, Vector3i.UP, Vector3i.DOWN]
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"border"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_required_arguments() -> Array[StringName]:
	return [&"sample"]


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var neighbors: Array = _get_arg(&"neighbors", graph, pouch)
	var inside: bool = _get_arg(&"inside", graph, pouch)
	var input_sample: GaeaValue.Sample = _get_arg(&"sample", graph, pouch)

	var border: GaeaValue.Sample = GaeaValue.Sample.new()
	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				var cell: Vector3i = Vector3i(x, y, z)
				var is_inside_border := inside and not input_sample.has(cell)
				var is_outside_border := not inside and input_sample.has(cell)
				if is_inside_border or is_outside_border:
					continue

				var filter: Callable
				if not inside:
					filter = func(neighbor: Vector3i) -> bool:
						return input_sample.has(neighbor)
				else:
					filter = func(neighbor: Vector3i) -> bool:
						return not input_sample.has(neighbor)

				for n: Vector3i in neighbors:
					var neighboring_cell: Vector3i = Vector3i(
						cell.x - n.x, cell.y - n.y, cell.z - n.z
					)
					if filter.call(neighboring_cell):
						border.set_cell(cell, 1)
						break

	return border
