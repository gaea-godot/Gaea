@tool
extends GaeaNodeResource
class_name GaeaNodeVariable
## Generic class for [b]TypeVariable[/b] nodes. See [enum GaeaValue.Type].
##
## Adds a variable of [member type], with [member hint] and [member hint_string], editable in the
## inspector, which can be accessed by other nodes through this node's output.[br]
## Variables are added to the [member GaeaData.parameters] array.


## See [enum Variant.Type] and equivalents in [method GaeaValue.from_variant_type].
@export var type: Variant.Type:
	set(new_value):
		type = new_value
		_update_output_slot()
## See [enum PropertyHint].
@export var hint: PropertyHint:
	set(new_value):
		hint = new_value
		_update_output_slot()
## See [enum PropertyHint].
@export var hint_string: String:
	set(new_value):
		hint_string = new_value
		_update_output_slot()


func _update_output_slot():
	var output = GaeaNodeSlotOutput.new()
	output.name = "value"
	output.type = GaeaValue.from_variant_type(type, hint, hint_string)
	outputs = [output]


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)
	var data = generator_data.parameters.get(_get_arg(&"name", area, null))
	if data.has("value"):
		return output_port.return_value(data.get("value"))
	return {}


func _get_scene() -> PackedScene:
	return preload("uid://bodjhgqp1bpui")
