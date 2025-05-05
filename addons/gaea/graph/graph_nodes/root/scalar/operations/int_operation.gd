@tool
class_name GaeaNodeIntOp
extends GaeaNodeNumOp
## [int] operation.



func _get_title() -> String:
	return "IntOp"


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT


func _get_description() -> String:
	if get_tree_name() == "IntOp" and not is_instance_valid(node):
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
	var definitions := super()
	#definitions.erase(Operation.SNAPPED)
	definitions.erase(Operation.CEIL)
	definitions.erase(Operation.FLOOR)
	definitions.erase(Operation.ROUND)
	definitions.erase(Operation.SMOOTHSTEP)
	definitions.erase(Operation.REMAP)
	return definitions
