@tool
extends GaeaNodeVectorBase
class_name GaeaNodeDecomposeVector
## Decomposes vector to floats.


func _get_title() -> String:
	return "VectorDecompose"


func _get_description() -> String:
	return "Decomposes a [code]%s[/code] into %d [code]float[/code]s." % [_get_vector_type_name(), _get_output_ports_list().size()]


#region Arguments
func _get_arguments_list() -> Array[StringName]:
	return [&"vector"]


func _get_argument_display_name(_arg_name: StringName) -> String:
	return ""


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return get_enum_selection(0) as GaeaValue.Type
#endregion


#region Outputs
func _get_output_ports_list() -> Array[StringName]:
	match get_enum_selection(0):
		VectorType.VECTOR2, VectorType.VECTOR2I:
			return [&"x", &"y"]
		VectorType.VECTOR3, VectorType.VECTOR3I:
			return [&"x", &"y", &"z"]
	return []


func _get_output_port_display_name(output_name: StringName) -> String:
	return output_name


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return (GaeaValue.Type.INT if _is_integer_vector() else GaeaValue.Type.FLOAT)
#endregion


func _get_tree_items() -> Array[GaeaNodeResource]:
	var array: Array[GaeaNodeResource] = []

	for i in VectorType.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(0, i)
		item.set_tree_name_override(
			_get_enum_option_display_name(0, i) + "Decompose"
		)
		array.append(item)

	return array


func _get_data(output_port: StringName, area: AABB, graph: GaeaGraph) -> float:
	return _get_arg(&"vector", area, graph)[output_port]
