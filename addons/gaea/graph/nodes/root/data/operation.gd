@tool
extends GaeaNodeResource


@export_enum("Sum", "Substraction", "Multiplication", "Division") var operation: int = 0


func get_data(_passed_data:Array[Dictionary], output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var a: Variant = get_arg("a", generator_data)
	var b: Variant = get_arg("b", generator_data)

	return {"value": _get_new_value(a, b)}


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
