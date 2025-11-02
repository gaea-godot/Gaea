@tool
class_name GaeaNodeDatasMatrixSampler
extends GaeaNodeResource
## Operation between 2 data grids.


func _get_title() -> String:
	return "DatasMatrixSampler"


func _get_description() -> String:
	return "Operation between 2 data grids."



func _get_enums_count() -> int:
	return 0


func _get_arguments_list() -> Array[StringName]:
	return [&"x", &"y", &"matrix"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var data_x: Dictionary[Vector3i, float] = _get_arg(&"x", area, graph)
	var data_y: Dictionary[Vector3i, float] = _get_arg(&"y", area, graph)
	var matrix: Dictionary[Vector3i, float] = _get_arg(&"matrix", area, graph)
	var result: Dictionary[Vector3i, float] = {}
	for x in _get_axis_range(Vector3i.AXIS_X, area):
		for y in _get_axis_range(Vector3i.AXIS_Y, area):
			for z in _get_axis_range(Vector3i.AXIS_Z, area):
				var cell_position := Vector3i(x, y, z)
				var x_position = roundi(lerpf(area.position.x, area.end.x, data_x.get(cell_position, 0.0)))
				var y_position = roundi(lerpf(area.position.y, area.end.y, data_y.get(cell_position, 0.0)))
				result.set(cell_position, matrix.get(Vector3i(x_position, y_position, 0.0)))
	return result
