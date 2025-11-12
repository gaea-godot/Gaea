@tool
class_name GaeaNodeVectorOp
extends GaeaNodeVectorBase
## Base class for operations between 2 vectors.

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
}


class Definition:
	var args: Array[StringName]
	var output: String
	var conversion: Callable

	func _init(_args: Array[StringName], _output: String, _conversion: Callable):
		args = _args
		output = _output
		conversion = _conversion


var operation_definitions: Dictionary[Operation, Definition]:
	get = _get_operation_definitions


func _get_title() -> String:
	return "VectorOp"


func _get_description() -> String:
	if get_tree_name() == _get_title() and not is_instance_valid(node):
		return "Operation between 2 [code]Vector[/code]s."

	var vector_name := _get_enum_option_display_name(0, get_enum_selection(0))
	match get_enum_selection(1):
		Operation.ADD:
			return "Sums 2 [code]%s[/code]s." % vector_name
		Operation.SUBTRACT:
			return "Subtracts 2 [code]%s[/code]s." % vector_name
		Operation.MULTIPLY:
			return "Multiplies 2 [code]%s[/code]s together." % vector_name
		Operation.DIVIDE:
			return "Divides 2 [code]%s[/code]s together." % vector_name
	return ""


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	items.append_array(super())
	for vector_type in VectorType.keys():
		for operation in operation_definitions.keys():
			var item: GaeaNodeResource = get_script().new()
			item.set_tree_name_override(
				(
					"%s (%s)"
					% [
						Operation.find_key(operation).to_pascal_case(),
						operation_definitions[operation].output
					]
				)
			)
			item.set_default_enum_value_override(0, VectorType[vector_type])
			item.set_default_enum_value_override(1, operation)
			items.append(item)
	return items


func _get_enums_count() -> int:
	return super() + 1


func _get_enum_options(_idx: int) -> Dictionary:
	if _idx < super._get_enums_count():
		return super(_idx)

	var options: Dictionary = {}
	for operation in operation_definitions.keys():
		options.set(Operation.find_key(operation), operation)
	return options


func _get_enum_option_icon(enum_idx: int, option_value: int) -> Texture:
	if enum_idx < super._get_enums_count():
		return super(enum_idx, option_value)
	return null


func _get_arguments_list() -> Array[StringName]:
	return operation_definitions.get(get_enum_selection(1)).args


func _get_argument_display_name(arg_name: StringName) -> String:
	return arg_name


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return get_type()


func _is_available() -> bool:
	return get_type() != GaeaValue.Type.NULL


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_display_name(_output_name: StringName) -> String:
	return operation_definitions[get_enum_selection(1)].output


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return get_enum_selection(0) as GaeaValue.Type


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	var operation: Operation = get_enum_selection(1) as Operation
	var args: Array
	for arg_name: StringName in operation_definitions[operation].args:
		args.append(_get_arg(arg_name, graph, pouch))
	return _get_new_value(operation, args)


func _get_new_value(operation: Operation, args: Array) -> Variant:
	return operation_definitions[operation].conversion.callv(args)


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not operation_definitions.is_empty():
		return operation_definitions

	operation_definitions = {
		Operation.ADD:
		Definition.new([&"a", &"b"], "a + b", func(a: Variant, b: Variant): return a + b),
		Operation.SUBTRACT:
		Definition.new([&"a", &"b"], "a - b", func(a: Variant, b: Variant): return a - b),
		Operation.MULTIPLY:
		Definition.new([&"a", &"b"], "a * b", func(a: Variant, b: Variant): return a * b),
		Operation.DIVIDE:
		Definition.new(
			[&"a", &"b"],
			"a / b",
			func(a: Variant, b: Variant): return 0 if b.is_zero_approx() else a / b
		),
	}
	return operation_definitions
