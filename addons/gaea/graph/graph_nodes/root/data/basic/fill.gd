@tool
extends GaeaNodeResource
class_name GaeaNodeFill
## Fills the grid with [param value].


func _get_title() -> String:
	return "Fill"


func _get_description() -> String:
	return "Fills the grid with [param]value[/bg][/c]."


func _get_arguments_list() -> Array[StringName]:
	return [&"value"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid: Dictionary[Vector3i, float]
	var value: float = _get_arg(&"value", area, generator_data)
	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			for z in _get_axis_range(Axis.Z, area):
				grid[Vector3i(x, y, z)] = value
	return grid
