@tool
class_name GaeaNodeToHeight
extends GaeaNodeResource
## Node description.


enum Type {
	TYPE_2D, TYPE_3D
}

var type: Type


func _get_title() -> String:
	return "ToHeight"


func _get_description() -> String:
	return "Node description."


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return Type


func _get_enum_option_display_name(_enum_idx: int, option_value: int) -> String:
	return Type.find_key(option_value).trim_prefix("TYPE_")



# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	return [&"reference_data", &"reference_y",
			&"height_offset", &"displacement_intensity"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"reference_data": return GaeaValue.Type.DATA
		_: return GaeaValue.Type.INT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"displacement_intensity": return 16
	return super(arg_name)


# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(_output_port: StringName, area: AABB, graph: GaeaGraph) -> Variant:
	var reference_data: Dictionary = _get_arg(&"reference_data", area, graph)
	var row: int = _get_arg(&"reference_y", area, graph)
	var height_offset: int = _get_arg(&"height_offset", area, graph)
	var displacement: int = _get_arg(&"displacement_intensity", area, graph)
	var data: Dictionary[Vector3i, float] = {}
	var type: Type = get_enum_selection(0)

	for x in _get_axis_range(Vector3i.AXIS_X, area):
		if not reference_data.has(Vector3i(x, row, 0)):
			continue
		var z_range: Array = [0] if (type == Type.TYPE_2D) else (_get_axis_range(Vector3i.AXIS_Z, area))
		for z in z_range:
			var height: int = floor(reference_data[Vector3i(x, row, z)] * displacement + height_offset)
			for y in _get_axis_range(Vector3i.AXIS_Y, area):
				if (y >= -height and type == Type.TYPE_2D) or (y <= height and type == Type.TYPE_3D):
					data[Vector3i(x, y, z)] = 1.0
	return data
