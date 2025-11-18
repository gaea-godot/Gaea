@tool
@abstract
class_name GaeaNodeParameter
extends GaeaNodeResource
## Generic class for [b]TypeParameter[/b] nodes. See [enum GaeaValue.Type].
##
## Adds a variable of [member type], with [member hint] and [member hint_string], editable in the
## inspector, which can be accessed by other nodes through this node's output.[br]
## Parameters are added to the [member GaeaGraph._parameters] array.

## See [enum Variant.Type] and equivalents in [method GaeaValue.from_variant_type].
var type: int:
	get = _get_variant_type
## See [enum PropertyHint].
var hint: PropertyHint:
	get = _get_property_hint
## See [enum PropertyHint].
var hint_string: String:
	get = _get_property_hint_string


func _on_added_to_graph(graph: GaeaGraph) -> void:
	var name := _get_available_name(graph.get_node_argument(id, &"name", _get_title()))
	graph.set_node_argument(
		id, &"name", name
	)
	arguments.set(&"name", name)
	graph.add_parameter(name, {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
		"value": GaeaValue.get_default_value(type),
		"usage": PROPERTY_USAGE_EDITOR
	})


func _on_removed_from_graph(graph: GaeaGraph) -> void:
	graph.remove_parameter(graph.get_node_argument(id, &"name"))
	graph.notify_property_list_changed()


## Override this method to determine the [enum Variant.Type] for the variable this node adds.[br][br]
## Overriding this method is [b]required[/b].
func _get_variant_type() -> int:
	return TYPE_NIL


## Override this method to set a [enum PropertyHint] for the variable this node adds.
func _get_property_hint() -> PropertyHint:
	return PROPERTY_HINT_NONE


## Override this method to set the hint string for the [enum PropertyHint] of the variable this node adds.
func _get_property_hint_string() -> String:
	return ""


func _get_arguments_list() -> Array[StringName]:
	return [&"name"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.VARIABLE_NAME


func _get_argument_default_value(_arg_name: StringName) -> Variant:
	return _get_available_name(_get_title())


func _get_available_name(from: String) -> String:
	if not is_instance_valid(node) or not node is GaeaGraphNode:
		return from
	var graph: GaeaGraph = (node as GaeaGraphNode).graph_edit.graph

	from = from.rstrip("1234567890")
	var available_name: String = from
	var suffix: int = 1
	while graph.has_parameter(available_name):
		suffix += 1
		available_name = "%s%s" % [from, suffix]
	return available_name


func _get_output_ports_list() -> Array[StringName]:
	return [&"value"]


func _get_overridden_output_port_idx(_output_name: StringName) -> int:
	return 0


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.from_variant_type(
		_get_variant_type(), _get_property_hint(), _get_property_hint_string()
	)


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	return graph.get_parameter(_get_arg(&"name", graph, pouch))


func _is_available() -> bool:
	return _get_variant_type() != TYPE_NIL


func _get_scene_script() -> GDScript:
	return load("uid://cdihgtg613ft2")
