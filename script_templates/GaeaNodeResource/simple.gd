# meta-default: true
# meta-description: Simple node to be used in the Gaea editor.
@tool
# class_name GaeaNode...
extends GaeaNodeResource
## Node description.


func _get_title() -> String:
	return "NodeTitle"


func _get_description() -> String:
	return "Node description."


# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	return []


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_argument_default_value(arg_name: StringName) -> Variant:
	return GaeaValue.Type.NULL


# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return []


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_data(output_port: StringName, area: AABB, graph: GaeaGraph) -> Variant:
	return null
