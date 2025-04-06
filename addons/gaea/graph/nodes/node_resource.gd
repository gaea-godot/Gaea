@tool
class_name GaeaNodeResource
extends Resource


#region Description Formatting
const PARAM_TEXT_COLOR := "cdbff0"
const PARAM_BG_COLOR := "bfbfbf1a"
const CODE_TEXT_COLOR := "da8a95"
const CODE_BG_COLOR := "8080801a"

const GAEA_MATERIAL_HINT := "Resource used to tell GaeaRenderers what to place."
#endregion

@export var input_slots: Array[GaeaNodeSlot]
@export var args: Array[GaeaNodeArgument]
@export var output_slots: Array[GaeaNodeSlot]
@export var title: String = "Node"
@export_multiline var description: String = ""
@export var is_output: bool = false

@export_storage var data: Dictionary
@export_storage var salt: int = 0
var connections: Array[Dictionary]
var node: GaeaGraphNode

enum Axis {X, Y, Z}


func get_data(_output_port: int, _area: AABB, _generator_data: GaeaData) -> Dictionary:
	return {}


func execute(_area: AABB, _generator_data: GaeaData, _generator: GaeaGenerator) -> void:
	pass


## Pass in `generator_data` to allow overriding with input slots.
func get_arg(name: String, generator_data: GaeaData) -> Variant:
	var arg_connection_idx: int = 0
	var args_with_input: Array[GaeaNodeArgument] = args.filter(func(arg: GaeaNodeArgument) -> bool: return not arg.type == GaeaNodeArgument.Type.CATEGORY and not arg.disable_input_slot)
	for i in args_with_input.size():
		if args_with_input[i].name == name:
			arg_connection_idx = i + input_slots.size()
			break

	if arg_connection_idx != -1 and is_instance_valid(generator_data):
		var connected_idx: int = get_connected_resource_idx(arg_connection_idx)
		if connected_idx != -1:
			return generator_data.resources[connected_idx].get_data(
				get_connected_port_to(arg_connection_idx),
				AABB(),
				generator_data
			).get("value")

	return data.get(name)


func get_connected_resource_idx(at: int) -> int:
	for connection in connections:
		if connection.to_port == at:
			return connection.from_node
	return -1


func get_connected_port_to(to: int) -> int:
	for connection in connections:
		if connection.to_port == to:
			return connection.from_port
	return -1


static func get_scene() -> PackedScene:
	return preload("res://addons/gaea/graph/nodes/node.tscn")


func get_axis_range(axis: Axis, area: AABB) -> Array:
	match axis:
		Axis.X:
			return range(area.position.x, area.end.x)
		Axis.Y: return range(area.position.y, area.end.y)
		Axis.Z: return range(area.position.z, area.end.z)
	return []


static func get_formatted_text(unformatted_text: String) -> String:
	unformatted_text = unformatted_text.replace("[param]", "[color=%s][bgcolor=%s]" % [PARAM_TEXT_COLOR, PARAM_BG_COLOR])
	unformatted_text = unformatted_text.replace("GaeaMaterial", "[hint=%s]GaeaMaterial[/hint]" % GAEA_MATERIAL_HINT)
	unformatted_text = unformatted_text.replace("[code]", "[color=%s][bgcolor=%s]" % [CODE_TEXT_COLOR, CODE_BG_COLOR])

	unformatted_text = unformatted_text.replace("[/c]", "[/color]")
	unformatted_text = unformatted_text.replace("[/bg]", "[/bgcolor]")
	return unformatted_text


func get_type() -> GaeaGraphNode.SlotTypes:
	if output_slots.is_empty():
		return GaeaGraphNode.SlotTypes.NULL

	if not is_instance_valid(output_slots.back()):
		return GaeaGraphNode.SlotTypes.NULL

	return output_slots.back().right_type


func get_icon() -> Texture2D:
	return get_icon_for_slot_type(get_type())


func get_title_color() -> Color:
	return GaeaGraphNode.get_color_from_type(get_type())


static func get_icon_for_slot_type(slot_type: GaeaGraphNode.SlotTypes) -> Texture2D:
	match slot_type:
		GaeaGraphNode.SlotTypes.VALUE_DATA:
			return preload("../../assets/types/data_grid.svg")
		GaeaGraphNode.SlotTypes.MAP_DATA:
			return preload("../../assets/types/map.svg")
		GaeaGraphNode.SlotTypes.TILE_INFO:
			return preload("../../assets/types/material.svg")
		GaeaGraphNode.SlotTypes.VECTOR2:
			return preload("../../assets/types/vec2.svg")
		GaeaGraphNode.SlotTypes.NUMBER:
			return preload("../../assets/types/num.svg")
		GaeaGraphNode.SlotTypes.RANGE:
			return preload("../../assets/types/range.svg")
		GaeaGraphNode.SlotTypes.BOOL:
			return preload("../../assets/types/bool.svg")
		GaeaGraphNode.SlotTypes.VECTOR3:
			return preload("../../assets/types/vec3.svg")
	return null


func _is_point_outside_area(area: AABB, point: Vector3) -> bool:
	area.end -= Vector3.ONE
	return (point.x < area.position.x or point.y < area.position.y or point.z < area.position.z or
			point.x > area.end.x or point.y > area.end.y or point.z > area.end.z)
