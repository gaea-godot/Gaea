@tool
class_name GaeaSubGraph
extends GaeaGraph


@export var title: String = "SubGraph" : set = set_title
## Input nodes by their name and id.
@export_storage var inputs: Dictionary[int, StringName] : get = get_input_nodes
## Output nodes by their name and id.
@export_storage var outputs: Dictionary[int, StringName] : get = get_output_nodes


func _init() -> void:
	resource_local_to_scene = false

	if resource_path.is_empty():
		save_version = CURRENT_SAVE_VERSION


func add_node(node: GaeaNodeResource, position: Vector2, id: int = get_next_available_id()) -> int:
	# The editor doesn't allow adding parameter nodes to subgraphs, but
	# this is for pasted nodes.
	if node is GaeaNodeParameter:
		id = add_node(GaeaNodeSubGraphInput.new(), position, id)
		set_node_enum.call_deferred(id, 0, node.get_type())
		push_warning(
			"Can't add GaeaNodeParameters to SubGraphs. Changed to an In node of the same type instead."
		)
		return id

	id = super(node, position, id)
	# Deferred so pasted nodes have the right name.
	_on_node_added.call_deferred(node)

	return id


func add_node_with_data(node: GaeaNodeResource, data: Dictionary, id: int = get_next_available_id()) -> int:
	if node is GaeaNodeParameter:
		data.get_or_add(&"enums", []).append(node.get_type())
		node = GaeaNodeSubGraphInput.new()

	return super(node, data, id)


func _on_node_added(node: GaeaNodeResource) -> void:
	if node is GaeaNodeSubGraphInput:
		inputs.set(
			node.id, get_node_argument(node.id, &"name", node.get_argument_default_value(&"name"))
		)
	elif node is GaeaNodeSubGraphOutput:
		outputs.set(
			node.id, get_node_argument(node.id, &"name", node.get_argument_default_value(&"name"))
		)


func remove_node(id: int) -> void:
	inputs.erase(id)
	outputs.erase(id)

	super(id)


func set_node_argument(id: int, arg_name: StringName, value: Variant) -> void:
	super(id, arg_name, value)

	if arg_name == &"name":
		if id in inputs:
			inputs.set(id, value)
		elif id in outputs:
			outputs.set(id, value)


func set_title(value: String) -> void:
	title = value


func get_input_nodes() -> Dictionary[int, StringName]:
	return inputs


func get_output_nodes() -> Dictionary[int, StringName]:
	return outputs
