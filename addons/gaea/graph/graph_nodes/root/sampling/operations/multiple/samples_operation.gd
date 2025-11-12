@tool
class_name GaeaNodeSamplesOp
extends GaeaNodeResource
## Operation between 2 sample grids.

enum Operation { ADD, SUBTRACT, MULTIPLY, DIVIDE, LERP }


class Definition:
	var args: Array[StringName]
	var output: String
	var conversion: Callable

	func _init(_args: Array[StringName], _output: String, _conversion: Callable):
		args = _args
		output = _output
		conversion = _conversion


## All possible operations.
var operation_definitions: Dictionary[Operation, Definition]:
	get = _get_operation_definitions


func _get_title() -> String:
	return "SamplesOp"


func _get_description() -> String:
	if get_tree_name() == "SamplesOp" and not is_instance_valid(node):
		return "Operation between 2 sample grids."

	match get_enum_selection(0):
		Operation.ADD:
			return "Adds all cells in [param B] to all cells in [param A]."
		Operation.SUBTRACT:
			return "Adds all cells in [param B] from all cells in [param A]."
		Operation.MULTIPLY:
			return "Multiplies all cells in [param B] with all cells in [param A]."
		Operation.DIVIDE:
			return "Adds all cells in [param A] by all cells in [param B]."
		Operation.LERP:
			return "Linearly interpolates between all cells in [param A] and [param B] by [param weight]."
		_:
			return super()


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	items.append_array(super())
	for operation in operation_definitions.keys():
		var item: GaeaNodeResource = get_script().new()
		var operation_name: String = Operation.find_key(operation).to_pascal_case()
		var output_name: String = operation_definitions[operation].output
		var tree_name := "%sSamples (%s)" % [operation_name, output_name]
		item.set_tree_name_override(tree_name)
		item.set_default_enum_value_override(0, operation)
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var options: Dictionary = {}

	for operation in operation_definitions.keys():
		options.set(Operation.find_key(operation), operation)

	return options


func _get_arguments_list() -> Array[StringName]:
	return operation_definitions.get(get_enum_selection(0)).args


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"weight":
		return GaeaValue.Type.FLOAT
	return GaeaValue.Type.SAMPLE


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name == &"weight":
		return {"min": 0.0, "max": 1.0}
	return super(arg_name)


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _get_output_port_display_name(_output_name: StringName) -> String:
	return operation_definitions[get_enum_selection(0)].output


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Sample:
	var operation: Operation = get_enum_selection(0) as Operation
	var a_grid: GaeaValue.Sample = _get_arg(&"a", graph, pouch)
	var b_grid: GaeaValue.Sample = _get_arg(&"b", graph, pouch)
	var result: GaeaValue.Sample = GaeaValue.Sample.new()
	var operation_definition: Definition = operation_definitions[operation]
	var static_args: Array
	for arg in operation_definition.args:
		if _get_argument_type(arg) == GaeaValue.Type.SAMPLE:
			continue

		static_args.append(_get_arg(arg, graph, pouch))
	for cell: Vector3i in a_grid.get_cells():
		if not b_grid.has(cell):
			continue

		result.set_cell(
			cell, operation_definition.conversion.callv(
				[a_grid.get_cell(cell), b_grid.get_cell(cell)] + static_args
			)
		)
	return result


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not operation_definitions.is_empty():
		return operation_definitions

	operation_definitions = {
		Operation.ADD:
		Definition.new([&"a", &"b"], "A + B", func(a: Variant, b: Variant): return a + b),
		Operation.SUBTRACT:
		Definition.new([&"a", &"b"], "A - B", func(a: Variant, b: Variant): return a - b),
		Operation.MULTIPLY:
		Definition.new([&"a", &"b"], "A * B", func(a: Variant, b: Variant): return a * b),
		Operation.DIVIDE:
		Definition.new(
			[&"a", &"b"],
			"A / B",
			func(a: Variant, b: Variant): return 0 if is_zero_approx(b) else a / b
		),
		Operation.LERP: Definition.new([&"a", &"b", &"weight"], "lerp(a, b, weight)", lerpf)
	}
	return operation_definitions
