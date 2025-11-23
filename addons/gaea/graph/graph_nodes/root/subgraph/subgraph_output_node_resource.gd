@tool
class_name GaeaNodeSubGraphOutput
extends GaeaNodeSubGraphSlot
## Adds an output slot to the subgraph node.


func _get_title() -> String:
	return "Out"


func _get_description() -> String:
	return "Adds an output slot to the subgraph node."


# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return []


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func get_type() -> GaeaValue.Type:
	return get_enum_selection(0) as GaeaValue.Type


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	return _get_arg(&"value", graph, pouch)
