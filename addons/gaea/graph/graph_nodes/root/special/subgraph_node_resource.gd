@tool
class_name GaeaNodeSubGraph
extends GaeaNodeResource
## Holds a sub-graph, which can take arguments in and output data.


## The sub-graph this node represents.
var subgraph: GaeaSubGraph


func _get_title() -> String:
	return "SubGraph"


func _get_description() -> String:
	return "Holds a sub-graph, which can take arguments in and output data."


func _on_added_to_graph(graph: GaeaGraph) -> void:
	if not is_instance_valid(subgraph):
		subgraph = GaeaSubGraph.new()
		graph.set_node_data_value(id, &"subgraph", subgraph)


func _get_scene() -> PackedScene:
	return load("uid://i4amiqtbm0bi")


# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	if not is_instance_valid(subgraph):
		return []
	return subgraph.get_input_nodes().values()


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if not is_instance_valid(subgraph):
		return GaeaValue.Type.NULL
	return subgraph.get_node(subgraph.get_input_nodes().find_key(arg_name)).get_type()


func _get_argument_default_value(arg_name: StringName) -> Variant:
	if not is_instance_valid(subgraph):
		return null
	return subgraph.get_node(
		subgraph.get_input_nodes().find_key(arg_name)
	).get_argument_default_value(arg_name)


func _is_input_only(_arg_name: StringName) -> bool:
	return true

# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	if not is_instance_valid(subgraph):
		return []
	return subgraph.get_output_nodes().values()


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	if not is_instance_valid(subgraph):
		return GaeaValue.Type.NULL
	return subgraph.get_node(subgraph.get_output_nodes().find_key(output_name)).get_type()


func _get_data(output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	for in_id in subgraph.get_input_nodes().keys():
		var in_node := subgraph.get_node(in_id)
		in_node.parent_node = self
		in_node.parent_graph = graph

	var output_node: GaeaNodeSubGraphOutput = subgraph.get_node(subgraph.get_output_nodes().find_key(output_port))
	return output_node.traverse(&"value", subgraph, pouch).value


func _get_icon() -> Texture2D:
	return load("uid://cerisdpavr7v3")


func _get_title_color() -> Color:
	return GaeaEditorSettings.get_configured_subgraph_color()


func _load_save_data(saved_data: Dictionary) -> void:
	subgraph = saved_data.get(&"subgraph")
	if is_instance_valid(subgraph):
		subgraph.ensure_initialized()
	super(saved_data)


func _get_custom_saved_data() -> Dictionary[StringName, Variant]:
	return {&"subgraph": subgraph}
