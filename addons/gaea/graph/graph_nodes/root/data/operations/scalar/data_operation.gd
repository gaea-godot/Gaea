@tool
class_name GaeaNodeDataOp
extends GaeaNodeNumOp
## Operations between all the cells of a data grid and a [float] number.


func _get_title() -> String:
	return "DataOp"


func _get_description() -> String:
	if get_tree_name() == "DataOp" and not is_instance_valid(node):
		return "Operation between a data grid and a [code]float[/bg][/c] number."

	match get_enum_selection(0):
		Operation.Add:
			return "Adds a [code]float[/bg][/c] number to all cells in [param]A[/bg][/c]."
		Operation.Subtract:
			return "Adds a [code]float[/bg][/c] number from all cells in [param]A[/bg][/c]."
		Operation.Multiply:
			return "Adds a [code]float[/bg][/c] number with all cells in [param]A[/bg][/c]."
		Operation.Divide:
			return "Divides all cells in [param]A[/bg][/c] by a [code]float[/bg][/c] number."
		_:
			return super() + "\n\nOperates over all cells of [param]A[/bg][/c], [param]a[/bg][/c] being the cells' value."


func _get_argument_display_name(arg_name: StringName) -> String:
	if arg_name == &"a":
		return "A"
	return super(arg_name)


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"a":
		return GaeaValue.Type.DATA
	return GaeaValue.Type.FLOAT


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	var definitions := super()
	for definition: Definition in definitions.values():
		# Kind of horrible code but it's fine
		definition.output = definition.output.replace("a ", "A ")
		definition.output = definition.output.replace(" a", " A")
		definition.output = definition.output.replace("a,", "A,")
		definition.output = definition.output.replace("(a)", "(A)")
	definitions.erase(Operation.Power)
	return definitions


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Variant:
	_log_data(output_port, generator_data)
	var operation: Operation = get_enum_selection(0) as Operation
	var operation_definition: Definition = OPERATION_DEFINITIONS[operation]
	var args: Array
	var input_grid: Dictionary = _get_arg(&"a", area, generator_data)
	for arg_name: StringName in OPERATION_DEFINITIONS[operation].args:
		if arg_name == &"a":
			continue
		args.append(_get_arg(arg_name, area, generator_data))
	var new_grid: Dictionary[Vector3i, float]

	for cell: Vector3i in input_grid:
		new_grid.set(cell, operation_definition.conversion.callv([input_grid[cell]] + args))
	return new_grid
