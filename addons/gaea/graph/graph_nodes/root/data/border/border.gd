@tool
extends GaeaNodeResource
class_name GaeaNodeBorder2D
## Returns the border of [param data]. If [param inside] is [code]true[/code], returns the inner border.
##
## Loops through all the points in the generation area.[br]
## - If [param inside] is [code]false[/code],
## returns only the points that don't exist in [param data]
## and that have a value in all the [param neighbors] offsets.[br]
## - If [param inside] is [code]true[/code],
## it'll return instead the cells in [param data] that have empty points in all the [param neighbors] offsets.[br][br]
## Output data is a grid of [code]1.0[/code]s.


func _get_title() -> String:
	return "Border2D"


func _get_description() -> String:
	return "Returns the border of [param data]. If [param inside] is [code]true[/code], returns the inner border."


func _get_arguments_list() -> Array[StringName]:
	return [&"data", &"neighbors", &"inside"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"data": return GaeaValue.Type.DATA
		&"neighbors": return GaeaValue.Type.NEIGHBORS
		&"inside": return GaeaValue.Type.BOOLEAN
	return GaeaValue.Type.NULL


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"neighbors": return [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	return super (arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"border"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_required_arguments() -> Array[StringName]:
	return [&"data"]


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var neighbors: Array = _get_arg(&"neighbors", area, graph)
	var inside: bool = _get_arg(&"inside", area, graph)
	var input_data: Dictionary[Vector3i, float] = _get_arg(&"data", area, graph)

	var border: Dictionary[Vector3i, float] = {}
	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			for z in _get_axis_range(Vector3i.AXIS_Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if (inside and input_data.get(cell) == null) or (not inside and input_data.get(cell) != null):
					continue

				for n: Vector2i in neighbors:
					if not inside:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if input_data.get(neighboring_cell) != null:
							border.set(cell, 1)
							break
					else:
						var neighboring_cell: Vector3i = Vector3i(cell.x - n.x, cell.y - n.y, cell.z)
						if input_data.get(neighboring_cell) == null:
							border.set(cell, 1)
							break

	return border
