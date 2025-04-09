@tool
extends GaeaNodeResource


func get_data(
	passed_data: Array[Dictionary],
	output_port: int,
	_area: AABB,
	_generator_data: GaeaData
) -> Dictionary:
	return passed_data[output_port]


func _use_caching(_output_port:int, _generator_data:GaeaData) -> bool:
	return false


func get_type() -> GaeaGraphNode.SlotTypes:
	return GaeaGraphNode.SlotTypes.NULL


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")
