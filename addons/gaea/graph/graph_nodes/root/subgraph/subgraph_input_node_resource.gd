@tool
class_name GaeaNodeSubGraphInput
extends GaeaNodeSubGraphSlot
## Adds an input argument to the subgraph node.


var parent_node: GaeaNodeSubGraph
var parent_graph: GaeaGraph


func _get_title() -> String:
	return "In"


func _get_description() -> String:
	return "Adds an input argument to the subgraph node."


func _get_output_ports_list() -> Array[StringName]:
	return [&"value"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return get_enum_selection(0) as GaeaValue.Type


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	return parent_node._get_arg(_get_arg(&"name", graph, pouch), parent_graph, pouch)
