@tool
extends GaeaNodeResource


func get_data(
	_passed_data: Array[Dictionary], _output_port: int, _area: AABB, _generator_data: GaeaData
) -> Dictionary:
	return _passed_data[_output_port]


func get_type() -> GaeaGraphNode.SlotTypes:
	return GaeaGraphNode.SlotTypes.NULL


static func get_scene() -> PackedScene:
	return preload("uid://b2rceqo8rtr88")
