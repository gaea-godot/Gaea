@tool
class_name GaeaNodeComposeVector
extends GaeaNodeVectorBase
## Composes floats to vector.


func _get_title() -> String:
	return "VectorCompose"


func _get_description() -> String:
	return (
		"Composes %d [code]float[/code]s into [code]%s[/code]."
		% [_get_arguments_list().size(), _get_vector_type_name()]
	)


#region Arguments
func _get_arguments_list() -> Array[StringName]:
	match get_enum_selection(0):
		VectorType.VECTOR2, VectorType.VECTOR2I:
			return [&"x", &"y"]
		VectorType.VECTOR3, VectorType.VECTOR3I:
			return [&"x", &"y", &"z"]
	return []


func _get_argument_display_name(arg_name: StringName) -> String:
	return arg_name


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT if _is_integer_vector() else GaeaValue.Type.FLOAT


#endregion


#region Outputs
func _get_output_ports_list() -> Array[StringName]:
	return [&"vector"]


func _get_output_port_display_name(_output_name: StringName) -> String:
	return "Composed %s" % _get_vector_type_name()


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return get_enum_selection(0) as GaeaValue.Type


#endregion


func _get_tree_items() -> Array[GaeaNodeResource]:
	var array: Array[GaeaNodeResource] = []

	for i in VectorType.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(0, i)
		item.set_tree_name_override(_get_enum_option_display_name(0, i) + "Compose")
		array.append(item)

	return array


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	match get_enum_selection(0):
		VectorType.VECTOR2:
			return Vector2(
				_get_arg(&"x", graph, pouch),
				_get_arg(&"y", graph, pouch),
			)
		VectorType.VECTOR3:
			return Vector3(
				_get_arg(&"x", graph, pouch),
				_get_arg(&"y", graph, pouch),
				_get_arg(&"z", graph, pouch),
			)
		VectorType.VECTOR2I:
			return Vector2i(
				_get_arg(&"x", graph, pouch),
				_get_arg(&"y", graph, pouch),
			)
		VectorType.VECTOR3I:
			return Vector3i(
				_get_arg(&"x", graph, pouch),
				_get_arg(&"y", graph, pouch),
				_get_arg(&"z", graph, pouch),
			)
	return null
