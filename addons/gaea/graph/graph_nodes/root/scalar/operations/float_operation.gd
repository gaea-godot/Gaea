@tool
class_name GaeaNodeFloatOp
extends GaeaNodeNumOp
## A [float] operator.



func _get_title() -> String:
	return "FloatOp"


func _get_description() -> String:
	if get_tree_name() == "FloatOp" and not is_instance_valid(node):
		return "Operation between 2 [code]float[/bg][/c] numbers."

	match get_enum_selection(0):
		Operation.Add:
			return "Sums 2 [code]float[/bg][/c] numbers."
		Operation.Subtract:
			return "Subtracts 2 [code]float[/bg][/c] numbers."
		Operation.Multiply:
			return "Multiplies 2 [code]float[/bg][/c] numbers together."
		Operation.Divide:
			return "Divides 2 [code]float[/bg][/c] numbers together."
		_:
			return super()


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT
