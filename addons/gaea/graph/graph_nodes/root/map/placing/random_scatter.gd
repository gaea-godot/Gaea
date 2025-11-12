@tool
class_name GaeaNodeRandomScatter
extends GaeaNodeResource
## Randomly places [param amount] [param material]s in the cells of [param reference].


func _get_title() -> String:
	return "RandomScatter"


func _get_description() -> String:
	return "Randomly places [param amount] [param material]s in the cells of [param reference]."


func _get_arguments_list() -> Array[StringName]:
	return [&"reference", &"material", &"amount"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"reference":
			return GaeaValue.Type.SAMPLE
		&"material":
			return GaeaValue.Type.MATERIAL
		&"amount":
			return GaeaValue.Type.INT
	return GaeaValue.Type.NULL


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference", &"material"]


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Map:
	var reference_sample: GaeaValue.Sample = _get_arg(&"reference", graph, pouch)
	var material: GaeaMaterial = _get_arg(&"material", graph, pouch)

	var result: GaeaValue.Map = GaeaValue.Map.new()
	var cells_to_place_on: Array = reference_sample.get_cells()
	cells_to_place_on.shuffle()
	cells_to_place_on.resize(mini(_get_arg(&"amount", graph, pouch), cells_to_place_on.size()))

	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		material = _get_arg(&"material", graph, pouch)
		var error := (
			"Recursive limit reached (%d): Invalid material provided at %s"
			% [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path]
		)
		_log_error(error, graph, graph.resources.find(self))
		return result

	for cell: Vector3i in cells_to_place_on:
		result.set_cell(cell, material.execute_sample(rng, reference_sample.get_cell(cell)))

	return result
