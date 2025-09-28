@tool
extends GaeaGraphNode


var type: Variant.Type
var hint: PropertyHint
var hint_string: String

var current_name: String


func _on_added() -> void:
	super()

	custom_minimum_size.x = 192.0

	if resource is not GaeaNodeParameter:
		return

	_add_parameter.call_deferred()


func _add_parameter() -> void:
	current_name = get_arg_value(&"name")
	generator.data.set_node_argument(resource.id, &"name", current_name)

	generator.data.add_parameter(current_name, {
		"name": current_name,
		"type": resource.type,
		"hint": resource.hint,
		"hint_string": resource.hint_string,
		"value": _get_default_value(resource.type),
		"usage": PROPERTY_USAGE_EDITOR
	})


func _on_removed() -> void:
	generator.data.remove_parameter(get_arg_value(&"name"))
	generator.data.notify_property_list_changed()



func _on_argument_value_changed(value: Variant, _node: GaeaGraphNodeArgumentEditor, arg_name: String) -> void:
	if arg_name != "name" and value is not String:
		return

	if value == current_name:
		return

	if generator.data.rename_parameter(current_name, value) == OK:
		current_name = value



func _get_default_value(for_type: Variant.Type) -> Variant:
	match for_type:
		TYPE_FLOAT, TYPE_INT:
			return 0
		TYPE_BOOL:
			return false
		TYPE_VECTOR2:
			return Vector2(0, 0)
		TYPE_VECTOR2I:
			return Vector2i(0, 0)
		TYPE_VECTOR3:
			return Vector3(0, 0, 0)
		TYPE_VECTOR3I:
			return Vector3i(0, 0, 0)
	return null
