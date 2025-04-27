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
		return "Operation between 2 [code]int[/bg][/c] numbers."

	match get_enum_selection(0):
		Operation.Add:
			return "Sums 2 [code]int[/bg][/c] numbers."
		Operation.Subtract:
			return "Subtracts 2 [code]int[/bg][/c] numbers."
		Operation.Multiply:
			return "Multiplies 2 [code]int[/bg][/c] numbers together."
		Operation.Divide:
			return "Divides 2 [code]int[/bg][/c] numbers together."
		_:
			return super()


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	var definitions := super()
	#definitions.erase(Operation.Snapped)
	definitions.erase(Operation.Ceil)
	definitions.erase(Operation.Floor)
	definitions.erase(Operation.Round)
	definitions.erase(Operation.Smoothstep)
	definitions.erase(Operation.Remap)
	return definitions
