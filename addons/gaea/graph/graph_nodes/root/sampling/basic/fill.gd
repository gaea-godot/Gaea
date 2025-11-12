@tool
class_name GaeaNodeFill
extends GaeaNodeResource
## Fills the grid with [param value].


func _get_title() -> String:
	return "Fill"


func _get_description() -> String:
	return "Fills the grid with [param value]."


func _get_arguments_list() -> Array[StringName]:
	return [&"value"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var sample: GaeaValue.Sample = GaeaValue.Sample.new()
	var value: float = _get_arg(&"value", graph, pouch)
	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				sample.set_xyz(x, y, z, value)
	return sample
