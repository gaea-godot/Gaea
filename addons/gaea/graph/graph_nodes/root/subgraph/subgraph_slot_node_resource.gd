@tool
@abstract
class_name GaeaNodeSubGraphSlot
extends GaeaNodeResource
## Abstract class which [GaeaNodeSubGraphInput] and [GaeaNodeSubGraphOutput] extend.


func _on_added_to_graph(graph: GaeaGraph) -> void:
	if graph is not GaeaSubGraph:
		return

	var name := _get_available_name(graph.get_node_argument(id, &"name", _get_title()), graph)
	graph.set_node_argument(
		id, &"name", name
	)
	arguments.set(&"name", name)


func _get_available_name(from: String, graph: GaeaSubGraph) -> String:
	if not is_instance_valid(node) or not node is GaeaGraphNode:
		return from

	from = from.rstrip("1234567890")
	var available_name: String = from
	var suffix: int = 1
	var unavailable_names: Array
	if self is GaeaNodeSubGraphInput:
		unavailable_names = graph.inputs.values()
	elif self is GaeaNodeSubGraphOutput:
		unavailable_names = graph.outputs.values()

	while unavailable_names.has(available_name):
		suffix += 1
		available_name = "%s%s" % [from, suffix]
	return available_name


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var wireable_types: Array = GaeaValue.get_wireable_types()
	var dict: Dictionary
	for type in wireable_types:
		dict[GaeaValue.Type.find_key(type)] = type
	return dict


func _get_enum_option_icon(_enum_idx: int, option_value: int) -> Texture:
	return GaeaValue.get_display_icon(option_value)


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_arguments_list() -> Array[StringName]:
	return [&"name", &"default_value"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"name":
		return GaeaValue.Type.VARIABLE_NAME
	return get_type()


func _get_argument_default_value(arg_name: StringName) -> Variant:
	if arg_name == &"name":
		return get_title()
	return GaeaValue.get_default_value(get_argument_type(arg_name))


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name == &"name":
		if self is GaeaNodeSubGraphInput:
			return {"mode": GaeaParameterNameArgumentEditor.Mode.SUBGRAPH_INPUT}

		if self is GaeaNodeSubGraphOutput:
			return {"mode": GaeaParameterNameArgumentEditor.Mode.SUBGRAPH_OUTPUT}

	return super(arg_name)


func _get_icon() -> Texture2D:
	return null
