@tool
extends GaeaNodeResource
class_name GaeaNodeComposeVector
## Composes a Vector2/3 from 2/3 numbers.
##
## Generic class for both the Vector2 and Vector3 versions of this node.
## It auto detects the type it should compose.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)
	if output_port.type == GaeaValue.Type.VECTOR2:
		return output_port.return_value(Vector2(
			_get_arg(&"x", area, generator_data),
			_get_arg(&"y", area, generator_data),
		))
	elif output_port.type == GaeaValue.Type.VECTOR3:
		return output_port.return_value(Vector3(
			_get_arg(&"x", area, generator_data),
			_get_arg(&"y", area, generator_data),
			_get_arg(&"z", area, generator_data),
		))
	return {}
