@tool
class_name GaeaNodeSampleOp
extends GaeaNodeNumOp
## Operations between all the cells of a sample grid and a [float] number.


func _get_title() -> String:
	return "SampleOp"


func _get_description() -> String:
	if get_tree_name() == "SampleOp" and not is_instance_valid(node):
		return "Operation between a sample grid and a [code]float[/code] number."

	match get_enum_selection(0):
		Operation.ADD:
			return "Adds a [code]float[/code] number to all cells in [param A]."
		Operation.SUBTRACT:
			return "Adds a [code]float[/code] number from all cells in [param A]."
		Operation.MULTIPLY:
			return "Adds a [code]float[/code] number with all cells in [param A]."
		Operation.DIVIDE:
			return "Divides all cells in [param A] by a [code]float[/code] number."
		Operation.POWER:
			return (
				super().replace("base", "a")
				+ "\n\nOperates over all cells of [param A], [param a] being the cells' value."
			)
		_:
			return (
				super()
				+ "\n\nOperates over all cells of [param A], [param a] being the cells' value."
			)


func _get_argument_display_name(arg_name: StringName) -> String:
	if arg_name == &"a":
		return "A"
	return super(arg_name)


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"a":
		return GaeaValue.Type.SAMPLE
	return GaeaValue.Type.FLOAT


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	var definitions := super()
	for definition: Definition in definitions.values():
		# Kind of horrible code but it's fine
		definition.output = definition.output.replace("a ", "A ")
		definition.output = definition.output.replace(" a", " A")
		definition.output = definition.output.replace("a,", "A,")
		definition.output = definition.output.replace("(a)", "(A)")
		definition.output = definition.output.replace("base", "A")
	definitions[Operation.POWER].args[0] = &"a"
	return definitions


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var operation: Operation = get_enum_selection(0) as Operation
	var operation_definition: Definition = operation_definitions[operation]
	var args: Array
	var input_grid: GaeaValue.Sample = _get_arg(&"a", graph, pouch)
	for arg_name: StringName in operation_definitions[operation].args:
		if arg_name == &"a":
			continue
		args.append(_get_arg(arg_name, graph, pouch))
	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	var grid_value_pos: int = _get_arguments_list().find(&"a")

	for cell: Vector3i in input_grid.get_cells():
		var cell_args = args.duplicate()
		cell_args.insert(grid_value_pos, input_grid.get_cell(cell))
		result.set_cell(cell, operation_definition.conversion.callv(cell_args))
	return result
