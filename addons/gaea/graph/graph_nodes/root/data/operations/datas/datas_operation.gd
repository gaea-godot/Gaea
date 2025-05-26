@tool
class_name GaeaNodeDatasOp
extends GaeaNodeResource
## Operation between 2 data grids.


enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	LERP
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


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"weight":
		return GaeaValue.Type.FLOAT
	return GaeaValue.Type.DATA


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name == &"weight":
		return {"min": 0.0, "max": 1.0}
	return super(arg_name)

func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_output_port_display_name(_output_name: StringName) -> String:
	return OPERATION_DEFINITIONS[get_enum_selection(0)].output



func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Dictionary[Vector3i, float]:
	var operation: Operation = get_enum_selection(0) as Operation
	var a_grid: Dictionary = _get_arg(&"a", area, graph)
	var b_grid: Dictionary = _get_arg(&"b", area, graph)
	var new_grid: Dictionary[Vector3i, float]
	var operation_definition: Definition = OPERATION_DEFINITIONS[operation]
	var static_args: Array
	for arg in operation_definition.args:
		if _get_argument_type(arg) == GaeaValue.Type.DATA:
			continue

		static_args.append(_get_arg(arg, area, graph))
	for cell: Vector3i in a_grid:
		if not b_grid.has(cell):
			continue
		new_grid.set(cell, operation_definition.conversion.callv([a_grid[cell], b_grid[cell]] + static_args))
	return new_grid


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not OPERATION_DEFINITIONS.is_empty():
		return OPERATION_DEFINITIONS

	OPERATION_DEFINITIONS = {
		Operation.ADD:
			Definition.new([&"a", &"b"], "A + B", func(a: Variant, b: Variant): return a + b),
		Operation.SUBTRACT:
			Definition.new([&"a", &"b"], "A - B", func(a: Variant, b: Variant): return a - b),
		Operation.MULTIPLY:
			Definition.new([&"a", &"b"], "A * B", func(a: Variant, b: Variant): return a * b),
		Operation.DIVIDE:
			Definition.new([&"a", &"b"], "A / B", func(a: Variant, b: Variant): return 0 if is_zero_approx(b) else a / b),
		Operation.LERP:
			Definition.new([&"a", &"b", &"weight"], "lerp(a, b, weight)", lerpf)
	}
	return OPERATION_DEFINITIONS
