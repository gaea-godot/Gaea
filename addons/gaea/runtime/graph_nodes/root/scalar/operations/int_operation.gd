@tool
class_name GaeaNodeIntOp
extends GaeaNodeNumOp
## [int] operation.

static var _custom_operation_definitions: Dictionary[Operation, Definition] = {}

func _get_title() -> String:
	return "IntOp"


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT


func _get_description() -> String:
	if get_tree_name() == "IntOp" and not is_instance_valid(get_meta(&"_gaea_graph_node")):
		return "Operation between 2 [code]int[/code] numbers."

	match get_enum_selection(0):
		Operation.ADD:
			return "Sums 2 [code]int[/code] numbers."
		Operation.SUBTRACT:
			return "Subtracts 2 [code]int[/code] numbers."
		Operation.MULTIPLY:
			return "Multiplies 2 [code]int[/code] numbers together."
		Operation.DIVIDE:
			return "Divides 2 [code]int[/code] numbers together."
		_:
			return super()


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not _custom_operation_definitions.is_empty():
		return _custom_operation_definitions

	_custom_operation_definitions = super().duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	_custom_operation_definitions.erase(Operation.CEIL)
	_custom_operation_definitions.erase(Operation.FLOOR)
	_custom_operation_definitions.erase(Operation.ROUND)
	_custom_operation_definitions.erase(Operation.SMOOTHSTEP)
	_custom_operation_definitions.erase(Operation.REMAP)
	return _custom_operation_definitions
