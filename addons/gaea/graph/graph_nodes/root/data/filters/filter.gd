@tool
@abstract
extends GaeaNodeResource
class_name GaeaNodeFilter
## Abstract class used for filter nodes.


func _get_arguments_list() -> Array[StringName]:
	return [&"input_grid"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"input_grid":
		return get_type()
	return GaeaValue.Type.NULL


func _get_argument_display_name(arg_name: StringName) -> String:
	if arg_name == &"input_grid":
		return "Data" if get_type() == GaeaValue.Type.DATA else "Map"
	return super(arg_name)


func _get_required_arguments() -> Array[StringName]:
	return [&"input_grid"]


func _get_output_ports_list() -> Array[StringName]:
	return [&"filtered_grid"]


func _get_output_port_display_name(output_name: StringName) -> String:
	if output_name == &"filtered_grid":
		return "Filtered " + _get_argument_display_name(&"input_grid")
	return super(output_name)


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary:
	seed(graph.generator.seed + salt)

	var input_data: Dictionary = _get_arg(&"input_grid", area, graph)
	var new_data: Dictionary = GaeaValue.get_default_value(_get_output_port_type(_output_port))

	for cell: Vector3i in input_data:
		if _passes_filter(input_data, cell, area, graph):
			new_data.set(cell, input_data.get(cell))

	return new_data


## Override this method to change the filtering functionality. Should return [code]true[/code]
## if the [param cell] in [param input_data] passes the filter, and therefore should be included
## in the output.
func _passes_filter(_input_data: Dictionary, _cell: Vector3i, _area: AABB, _graph: GaeaGraph) -> bool:
	return true
