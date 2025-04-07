@tool
extends GaeaNodeResource

@export var type: GaeaGraphNode.SlotTypes = GaeaGraphNode.SlotTypes.NUMBER



func get_data(_output_port: int, _area: AABB, _generator_data: GaeaData) -> Dictionary:
	return {}


func get_type() -> GaeaGraphNode.SlotTypes:
	return type


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")

func get_icon() -> Texture2D:
	return get_icon_for_slot_type(get_type())
