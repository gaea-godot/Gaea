@tool
extends GaeaGraphNode


var type: Variant.Type
var hint: PropertyHint
var hint_string: String

var previous_name: String


func _on_added() -> void:
	super()

	custom_minimum_size.x = 192.0

	if resource is not GaeaNodeParameter:
		return

	var _loading_loop_limit = 60
	while not _finished_loading and _loading_loop_limit > 0:
		await get_tree().process_frame
		_loading_loop_limit -= 1
	if not _finished_loading:
		push_error("Something went wrong during loading of the variable node '%s'" % resource.get_title())

	_add_parameter.call_deferred()


func _add_parameter() -> void:
	previous_name = get_arg_value(&"name")

	if generator.data.parameters.has(previous_name):
		return

	generator.data.parameters[previous_name] = {
		"name": previous_name,
		"type": resource.type,
		"hint": resource.hint,
		"hint_string": resource.hint_string,
		"value": _get_default_value(resource.type),
		"usage": PROPERTY_USAGE_EDITOR
	}

	generator.data.notify_property_list_changed()


func _on_removed() -> void:
	generator.data.parameters.erase(get_arg_value("name"))
	generator.data.notify_property_list_changed()



func _on_argument_value_changed(value: Variant, _node: GaeaGraphNodeArgumentEditor, arg_name: String) -> void:
	if arg_name != "name" and value is not String:
		return


	if value == previous_name:
		return

	generator.data.parameters[value] = generator.data.parameters.get(previous_name)
	generator.data.parameters.erase(previous_name)
	generator.data.parameters[value].name = value

	previous_name = value

	generator.data.notify_property_list_changed()
	save_requested.emit.call_deferred()



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
