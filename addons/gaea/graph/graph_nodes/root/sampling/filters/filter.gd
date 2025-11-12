@tool
@abstract
class_name GaeaNodeFilter
extends GaeaNodeResource
## Abstract class used for filter nodes.


func _get_arguments_list() -> Array[StringName]:
	return [&"input_grid"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"input_grid":
		return get_type()
	return GaeaValue.Type.NULL


func _get_argument_display_name(arg_name: StringName) -> String:
	if arg_name == &"input_grid":
		return "Sample" if get_type() == GaeaValue.Type.SAMPLE else "Map"
	return super(arg_name)


func _get_required_arguments() -> Array[StringName]:
	return [&"input_grid"]


func _get_output_ports_list() -> Array[StringName]:
	return [&"filtered_grid"]


func _get_output_port_display_name(output_name: StringName) -> String:
	if output_name == &"filtered_grid":
		return "Filtered " + _get_argument_display_name(&"input_grid")
	return super(output_name)


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.GridType:
	var input_sample: GaeaValue.GridType = _get_arg(&"input_grid", graph, pouch)
	var new_data: GaeaValue.GridType = GaeaValue.get_default_value(_get_output_port_type(_output_port))
	var args: Dictionary[StringName, Variant]
	for arg in get_arguments_list():
		if arg == &"input_grid":
			continue
		args.set(arg, _get_arg(arg, graph, pouch))

	for cell: Vector3i in input_sample.get_cells():
		if _passes_filter(input_sample, cell, args):
			new_data.set_cell(cell, input_sample.get_cell(cell))

	return new_data


## Override this method to change the filtering functionality. Should return [code]true[/code]
## if the [param cell] in [param input_sample] passes the filter, and therefore should be included
## in the output.
@abstract
func _passes_filter(
	input_sample: GaeaValue.GridType, cell: Vector3i, args: Dictionary[StringName, Variant]
) -> bool
