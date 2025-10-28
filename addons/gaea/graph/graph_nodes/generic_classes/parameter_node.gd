@tool
extends GaeaGraphNode

var type: Variant.Type
var hint: PropertyHint
var hint_string: String


func _on_added() -> void:
	super()
	custom_minimum_size.x = 192.0


func _on_removed() -> void:
	generator.data.remove_parameter(get_arg_value(&"name"))
	generator.data.notify_property_list_changed()


func _on_argument_value_changed(
	value: Variant, _node: GaeaGraphNodeArgumentEditor, arg_name: String
) -> void:
	if arg_name != "name" and value is not String:
		return

	var current_name: String = generator.data.get_node_argument(resource.id, &"name")
	if value == current_name:
		return

	if generator.data.rename_parameter(current_name, value) == OK:
		generator.data.set_node_argument(resource.id, &"name", value)
