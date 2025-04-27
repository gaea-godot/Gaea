@tool
class_name GaeaNodeDatasOp
extends GaeaNodeResource
## Operation between 2 data grids.


enum Operation {
	Add,
	Subtract,
	Multiply,
	Divide,
}

class Definition:
	var args: Array[StringName]
	var output: String
	var conversion: Callable
	func _init(_args: Array[StringName], _output: String, _conversion: Callable):
		args = _args
		output = _output
		conversion = _conversion


## All possible operations.
var OPERATION_DEFINITIONS: Dictionary[Operation, Definition] : get = _get_operation_definitions


func _get_title() -> String:
	return "DatasOp"


func _get_description() -> String:
	if get_tree_name() == "DatasOp" and not is_instance_valid(node):
		return "Operation between 2 data grids."

	match get_enum_selection(0):
		Operation.Add:
			return "Adds all cells in [param B] to all cells in [param A]."
		Operation.Subtract:
			return "Adds all cells in [param B] from all cells in [param A]."
		Operation.Multiply:
			return "Multiplies all cells in [param B] with all cells in [param A]."
		Operation.Divide:
			return "Adds all cells in [param A] by all cells in [param B]."
		_:
			return super()


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	items.append_array(super())
	for operation in OPERATION_DEFINITIONS.keys():
		var item: GaeaNodeResource = get_script().new()
		item.set_tree_name_override("%sDatas (%s)" % [Operation.find_key(operation).to_pascal_case(), OPERATION_DEFINITIONS[operation].output] )
		item.set_default_enum_value_override(0, operation)
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var options: Dictionary = {}

	for operation in OPERATION_DEFINITIONS.keys():
		options.set(Operation.find_key(operation), operation)

	return options


func _get_arguments_list() -> Array[StringName]:
	return OPERATION_DEFINITIONS.get(get_enum_selection(0)).args


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_output_port_display_name(_output_name: StringName) -> String:
	return OPERATION_DEFINITIONS[get_enum_selection(0)].output



func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)
	var operation: Operation = get_enum_selection(0) as Operation
	var a_grid: Dictionary = _get_arg(&"a", area, generator_data)
	var b_grid: Dictionary = _get_arg(&"b", area, generator_data)
	var new_grid: Dictionary[Vector3i, float]
	var operation_definition: Definition = OPERATION_DEFINITIONS[operation]
	for cell: Vector3i in a_grid:
		if not b_grid.has(cell):
			return a_grid.get(cell)
		new_grid.set(cell, operation_definition.conversion.callv([a_grid[cell], b_grid[cell]]))
	return new_grid


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not OPERATION_DEFINITIONS.is_empty():
		return OPERATION_DEFINITIONS

	OPERATION_DEFINITIONS = {
		Operation.Add:
			Definition.new([&"a", &"b"], "A + B", func(a: Variant, b: Variant): return a + b),
		Operation.Subtract:
			Definition.new([&"a", &"b"], "A - B", func(a: Variant, b: Variant): return a - b),
		Operation.Multiply:
			Definition.new([&"a", &"b"], "A * B", func(a: Variant, b: Variant): return a * b),
		Operation.Divide:
			Definition.new([&"a", &"b"], "A / B", func(a: Variant, b: Variant): return 0 if is_zero_approx(b) else a / b)
	}
	return OPERATION_DEFINITIONS
