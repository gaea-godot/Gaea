@tool
extends GaeaGraphNode

var type: Variant.Type
var hint: PropertyHint
var hint_string: String


func _on_added() -> void:
	super()
	custom_minimum_size.x = 192.0


func _on_argument_value_changed(
	value: Variant, _node: GaeaGraphNodeArgumentEditor, arg_name: String
) -> void:
	if arg_name != "name" and value is not String:
		return

	var current_name: String = graph_edit.graph.get_node_argument(resource.id, &"name")
	if value == current_name:
		return

	if graph_edit.graph.rename_parameter(current_name, value) == OK:
		graph_edit.graph.set_node_argument(resource.id, &"name", value)
