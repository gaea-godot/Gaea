@tool
extends GaeaNodeResource
class_name GaeaNodeOperation
## Generic class for all kind of operation nodes. Applies [member operation] to [member a] and [member b].


## The operation to be applied.
@export_enum("Sum", "Substraction", "Multiplication", "Division") var operation: int = 0


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var a: Variant = _get_arg(&"a", area, generator_data)
	var b: Variant = _get_arg(&"b", area, generator_data)

	return output_port.return_value(_get_new_value(a, b))


func _get_new_value(a: Variant, b: Variant) -> Variant:
	if typeof(a) != typeof(b):
		return a

	match operation:
		0: return a + b
		1: return a - b
		2: return a * b
		3:
			if (b is float and b == 0.0) or (b is Vector2 and b == Vector2.ZERO) or (b is Vector3 and b == Vector3.ZERO):
				return b
			return a / b
	return a
