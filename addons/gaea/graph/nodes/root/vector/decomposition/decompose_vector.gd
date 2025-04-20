@tool
extends GaeaNodeResource
class_name GaeaNodeDecomposeVector
## Decomposes a Vector2/3 into 2/3 numbers.
##
## Generic class for both the [b]DecomposeVector2[/b] and the [b]DecomposeVector3[/b] nodes.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)
	var vector = _get_arg(&"vector", area, generator_data)
	match output_port.name:
		&"x":
			return output_port.return_value(vector.x)
		&"y":
			return output_port.return_value(vector.y)
		&"z":
			return output_port.return_value(vector.z)
	return {}
