@tool
extends GaeaNodeResource
class_name GaeaNodeFilter
## Abstract class used for filter nodes.


func _get_required_params() -> Array[StringName]:
	return [params[0].name]


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	seed(generator_data.generator.seed + salt)

	var input_data: Dictionary = _get_arg(params[0].name, area, generator_data)
	var new_data: Dictionary = {}
	for cell: Vector3i in input_data:
		if _passes_filter(input_data, cell, area, generator_data):
			new_data.set(cell, input_data.get(cell))

	return output_port.return_value(new_data)


## Override this method to change the filtering functionality. Should return [code]true[/code]
## if the [param cell] in [param input_data] passes the filter, and therefore should be included
## in the output.
@warning_ignore("unused_parameter")
func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	return true
