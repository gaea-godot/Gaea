@tool
extends GaeaNodeResource
class_name GaeaNodeDataComplement
## Returns the complement of [param data].
##
## Returns all the points outside [param data] set to [code]1.0[/code].


func _get_required_params() -> Array[StringName]:
	return [&"data"]


@warning_ignore("unused_parameter")
func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var input_grid = _get_arg(&"data", area, generator_data)
	var grid: Dictionary = {}

	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			for z in _get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				if input_grid.get(cell) == null:
					grid.set(cell, 1.0)

	return output_port.return_value(grid)
