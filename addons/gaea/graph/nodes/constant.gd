@tool
extends GaeaNodeResource


func get_data(_output_port: int, _area: AABB, _generator_data: GaeaData) -> Dictionary:
	return {
		"value": get_arg("value", null)
	}


func get_type() -> GaeaGraphNode.SlotTypes:
	return GaeaNodeArgument.get_slot_type_equivalent(args.front().type)


func get_icon() -> Texture2D:
	var for_type: GaeaNodeArgument.Type = args.front().type
	if for_type == GaeaNodeArgument.Type.FLOAT:
		return preload("../../assets/types/float.svg")
	if for_type == GaeaNodeArgument.Type.INT:
		return preload("../../assets/types/int.svg")
	return get_icon_for_slot_type(get_type())
