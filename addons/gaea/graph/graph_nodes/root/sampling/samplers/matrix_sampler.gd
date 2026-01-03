@tool
class_name GaeaNodeMatrixSampler
extends GaeaNodeResource
## Sampling using 2 data grids and one matrix as reference. Mostly used to generate biome with a Whittaker Diagram.


func _get_title() -> String:
	return "MatrixSampler"


func _get_description() -> String:
	return "Sampling using 2 data grids and one matrix as reference. Mostly used to generate biome with a Whittaker Diagram."



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


func _get_data(output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	assert(output_port == &"result", "Invalid output_port")
	var data_x: GaeaValue.Sample = _get_arg(&"x", graph, pouch)
	var data_y: GaeaValue.Sample = _get_arg(&"y", graph, pouch)
	var matrix: GaeaValue.Sample = _get_arg(&"matrix", graph, pouch)
	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				var x_position = roundi(lerpf(matrix.position.x, matrix.end.x, data_x.get_xyz(x, y, z)))
				if is_nan(x_position):
					continue
				var y_position = roundi(lerpf(matrix.position.y, matrix.end.y, data_y.get_xyz(x, y, z)))
				if is_nan(y_position):
					continue
				result.set_xyz(x, y, z, matrix.get_xyz(x_position, y_position, 0, 0.0))
	return result
