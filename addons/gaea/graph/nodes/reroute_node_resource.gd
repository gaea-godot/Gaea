@tool
extends GaeaNodeResource

func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	return output_port.return_value(get_arg(&"value", area, generator_data))


func _use_caching(_output_port: GaeaNodeSlotOutput, _generator_data:GaeaData) -> bool:
	return false


func get_type() -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")


func _instantiate_duplicate() -> GaeaNodeResource:
	var new_resource = super()
	for input_slot_idx in new_resource.params.size():
		new_resource.params[input_slot_idx] = new_resource.params[input_slot_idx].duplicate()
		new_resource.outputs[input_slot_idx] = new_resource.outputs[input_slot_idx].duplicate()
	return new_resource
