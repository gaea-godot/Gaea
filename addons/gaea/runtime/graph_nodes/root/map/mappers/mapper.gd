@tool
@abstract
class_name GaeaNodeMapper
extends GaeaNodeResource
## Abstract class for mappers.


func _get_extra_documentation(for_section: DocumentationSection) -> String:
	if for_section == DocumentationSection.DESCRIPTION:
		return ("A cell being mapped to [param material] means that, in the output Map, " +
				"that cell will contain that material.")
	return super(for_section)


func _get_arguments_list() -> Array[StringName]:
	return [&"reference", &"material"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE if arg_name == &"reference" else GaeaValue.Type.MATERIAL


func _get_argument_description(arg_name: StringName) -> String:
	match arg_name:
		&"reference":
			return "A grid of type Sample, which will be used as a reference for mapping."
		&"material":
			return "The [GaeaMaterial] used for the mapping."
		_:
			return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference", &"material"]


func _get_output_port_description(_output_name: StringName) -> String:
	return "The final, generated map."


func _get_data(_output_port: StringName, pouch: GaeaGenerationPouch) -> GaeaValue.Map:
	var result: GaeaValue.Map = GaeaValue.Map.new()
	var reference_sample: GaeaValue.Sample = _get_arg(&"reference", pouch)
	var material := _get_arg(&"material", pouch) as GaeaMaterial

	if not is_instance_valid(material):
		_log_error("Invalid material provided", graph.resources.find(self))
		return result

	var rng: RandomNumberGenerator = _get_rng(pouch)

	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		material = _get_arg(&"material", pouch)
		var error := (
			"Recursive limit reached (%d): Invalid material provided at %s"
			% [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path]
		)
		_log_error(error, graph.resources.find(self))
		return result

	var args: Dictionary[StringName, Variant]
	for arg in get_arguments_list():
		if arg == &"reference" or arg == &"material":
			continue
		args.set(arg, _get_arg(arg, pouch))

	for cell in reference_sample.get_cells():
		if _passes_mapping(reference_sample, cell, args):
			result.set_cell(cell, material.execute_sample(rng, reference_sample.get_cell(cell)))

	return result


## Should be overriden and return [code]true[/code] if the cell at [param cell] should be mapped to [param material] in the output.
@abstract
func _passes_mapping(
	reference_sample: GaeaValue.Sample, cell: Vector3i, args: Dictionary[StringName, Variant]
) -> bool
