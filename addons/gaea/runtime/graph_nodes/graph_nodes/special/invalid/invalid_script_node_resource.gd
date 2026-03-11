@tool
class_name GaeaNodeInvalidScript
extends GaeaNodeResource
## An invalid node added to the graph when an other node script was not able to load.

var _saved_data: Dictionary = {}
var _argument_count: int = 0
var _output_count: int = 0


func _init(argument_count: int = 0, output_count: int = 0) -> void:
	_argument_count = argument_count
	_output_count = output_count


func _load_save_data(saved_data: Dictionary) -> void:
	_saved_data = saved_data.duplicate_deep()
	super(saved_data)


func _get_title() -> String:
	return "Invalid Script"


func _get_description() -> String:
	return "An invalid node added to the graph when an other node script was not able to load."


func _get_arguments_list() -> Array[StringName]:
	var list: Array[StringName] = []
	for i in range(_argument_count):
		list.append("Argument #%d" % i)
	return list


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.ANY


func _get_output_ports_list() -> Array[StringName]:
	var list: Array[StringName] = []
	for i in range(_output_count):
		list.append("Output #%d" % i)
	return list


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.ANY


func _is_available() -> bool:
	return false


func _display_documentation_button() -> bool:
	return false


func _get_scene_script() -> GDScript:
	return load("uid://wlocahhk6rt")


func _get_data(_output_port: StringName, _pouch: GaeaGenerationPouch) -> Dictionary[String, float]:
	return {}
