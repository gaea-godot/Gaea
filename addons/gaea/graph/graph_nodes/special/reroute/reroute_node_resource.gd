@tool
class_name GaeaNodeReroute
extends GaeaNodeResource
## Allows rerouting a connection within the Gaea graph.
##
## Can be placed by pressing [kbd]Right Click[/kbd] in a connection wire and selecting the option,
## and it'll automatically adapt to the type of the selected wire.

var type: GaeaValue.Type = GaeaValue.Type.NULL:
	set(new_value):
		type = new_value
		notify_argument_list_changed()


func _get_title() -> String:
	return "Reroute"


func _get_description() -> String:
	return "Allows rerouting a connection within the Gaea graph."


#region Arguments
func _get_arguments_list() -> Array[StringName]:
	return [&"value"]


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return type
#endregion


#region Outputs
func _get_output_ports_list() -> Array[StringName]:
	return _get_arguments_list()


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return type
#endregion


func _get_scene() -> PackedScene:
	return load("uid://b2rceqo8rtr88")


func _get_data(output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	return _get_arg(output_port, graph, pouch)


func _use_caching(_output_port: StringName, _graph: GaeaGraph) -> bool:
	return false


func _load_save_data(saved_data: Dictionary) -> void:
	type = saved_data.get(&"reroute_type", GaeaValue.Type.NULL)
	super(saved_data)


func _get_custom_saved_data() -> Dictionary[StringName, Variant]:
	return {&"reroute_type": type}
