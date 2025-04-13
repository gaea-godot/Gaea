@tool
class_name GaeaNodeResource
extends Resource


#region Description Formatting
const PARAM_TEXT_COLOR := "cdbff0"
const PARAM_BG_COLOR := "bfbfbf1a"
const CODE_TEXT_COLOR := "da8a95"
const CODE_BG_COLOR := "8080801a"

const GAEA_MATERIAL_HINT := "Resource used to tell GaeaRenderers what to place."
const GAEA_MATERIAL_GRADIENT_HINT := "Resource that maps values from 0.0-1.0 to certain GaeaMaterials."
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


#region Execution
func execute(_area: AABB, _generator_data: GaeaData, _generator: GaeaGenerator) -> void:
	pass


# Traversal
func traverse(output_port:int, area: AABB, generator_data:GaeaData) -> Dictionary:
	log_traverse(generator_data)

	# Caching
	var use_caching = _use_caching(output_port, generator_data)
	if use_caching and has_cached_data(output_port, generator_data):
		return get_cached_data(output_port, generator_data)

	# Validation
	if not has_inputs_connected(_get_required_input_ports(), generator_data):
		return {}

	# Traversal
	var passed_data:Array[Dictionary] = []
	for slot in range(input_slots.size()):
		var data_input_resource = get_input_resource(slot, generator_data)
		var slot_data:Dictionary = {}

		if is_instance_valid(data_input_resource):
			var connected_port = get_connected_port_to(slot)
			var connected_type := data_input_resource.get_output_port_type(connected_port)
			var input_slot_type = input_slots[slot].left_type
			slot_data = data_input_resource.traverse(
				connected_port,
				area, generator_data
			)
			if connected_type != input_slot_type:
				slot_data = GaeaNodeResource.cast_value(connected_type, input_slot_type, slot_data)
		passed_data.append(slot_data)

	var results:Dictionary = get_data(passed_data, output_port, area, generator_data)

	if use_caching:
		set_cached_data(output_port, generator_data, results)
	return results


# Data Retrieval
func get_data(_passed_data:Array[Dictionary], _output_port: int, _area: AABB, _generator_data: GaeaData) -> Dictionary:
	return {}
#endregion


#region Caching
## Checks if this node should use caching or not.
func _use_caching(_output_port:int, _generator_data:GaeaData) -> bool:
	return true

## Adds or sets data to the cache at GaeaNodeResource, then output_port index.
func set_cached_data(output_port:int, generator_data:GaeaData, new_data:Dictionary) -> void:
	var node_cache:Dictionary = generator_data.cache.get_or_add(self, {})
	node_cache[output_port] = new_data

## Checks if the cache has data corresponding to GaeaNodeResource, then output_port index.
func has_cached_data(output_port:int, generator_data:GaeaData) -> bool:
	return generator_data.cache.has(self) and generator_data.cache[self].has(output_port)

## Gets cached data by GaeaNodeResource, then output_port index.
## Assumes that data exists, will error out if it doesn't.
func get_cached_data(output_port:int, generator_data:GaeaData) -> Dictionary:
	return generator_data.cache[self][output_port]
#endregion


#region Inputs
## Returns an array of input port indexes that are
## expected to be connected for the Node Resource to
## execute properly. Should be overridden in nodes
## that extend NodeResource.
func _get_required_input_ports() -> Array[int]:
	return []

func has_inputs_connected(required: Array[int], generator_data:GaeaData) -> bool:
	for idx in required:
		if get_input_resource(idx, generator_data) == null:
			return false
	return true

func get_input_resource(slot:int, generator_data:GaeaData) -> GaeaNodeResource:
	var data_connected_idx: int = get_connected_resource_idx(slot)
	if data_connected_idx == -1:
		return null

	var data_input_resource: GaeaNodeResource = generator_data.resources.get(data_connected_idx)
	if not is_instance_valid(data_input_resource):
		return null

	return data_input_resource
#endregion


#region Args
## Pass in `generator_data` to allow overriding with input slots.
func get_arg(name: String, generator_data: GaeaData) -> Variant:
	log_arg(name, generator_data)

	var arg_connection_idx: int = 0
	var arg_slot_type: GaeaGraphNode.SlotTypes
	var args_with_input: Array[GaeaNodeArgument] = args.filter(func(arg: GaeaNodeArgument) -> bool:
		return not arg.type == GaeaNodeArgument.Type.CATEGORY and not arg.disable_input_slot
	)
	for i in args_with_input.size():
		if args_with_input[i].name == name:
			arg_slot_type = GaeaNodeArgument.get_slot_type_equivalent(args_with_input[i].type)
			arg_connection_idx = i + input_slots.size()
			break

	if arg_connection_idx != -1 and is_instance_valid(generator_data):
		var connected_idx: int = get_connected_resource_idx(arg_connection_idx)
		if connected_idx != -1:
			var connected_node = generator_data.resources[connected_idx]
			var connected_port = get_connected_port_to(arg_connection_idx)
			var connected_data = connected_node.traverse(
				connected_port,
				AABB(),
				generator_data
			)
			if connected_data.has("value"):
				var connected_type := connected_node.get_output_port_type(connected_port)
				if arg_slot_type == connected_type:
					return connected_data.get("value")
				return GaeaNodeResource.cast_value(connected_type, arg_slot_type, connected_data.get("value"))
			else:
				log_error("Could not get data from previous node, using default value instead.", generator_data, connected_idx)
	return data.get(name)
#endregion


#region Connections
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


## Return the output port type for a specific port index
func get_output_port_type(port_index: int) -> GaeaGraphNode.SlotTypes:
	for input_slot in input_slots:
		if input_slot.right_enabled:
			if port_index == 0:
				return input_slot.right_type
			port_index -= 1
	for arg in args:
		if arg.add_output_slot:
			if port_index == 0:
				return GaeaNodeArgument.get_slot_type_equivalent(arg.type)
			port_index -= 1
	for output_slot in output_slots:
		if output_slot.right_enabled:
			if port_index == 0:
				return output_slot.right_type
			port_index -= 1
	return get_type()


## Return the input port type for a specific port index
func get_input_port_type(port_index: int) -> GaeaGraphNode.SlotTypes:
	for input_slot in input_slots:
		if input_slot.left_enabled:
			if port_index == 0:
				return input_slot.left_type
			port_index -= 1
	for arg in args:
		if not arg.disable_input_slot:
			if port_index == 0:
				return GaeaNodeArgument.get_slot_type_equivalent(arg.type)
			port_index -= 1
	for output_slot in output_slots:
		if output_slot.left_enabled:
			if port_index == 0:
				return output_slot.left_type
			port_index -= 1
	return get_type()

#endregion


#region Logging
func log_execute(message:String, area:AABB, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Execute > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sArea %s on %s" % [message, area, title])

func log_layer(message:String, layer:int, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Execute > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sLayer %d on %s" % [message, layer, title])

func log_traverse(generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Traverse > 0:
		print("Traverse  |   %s" % [title])

func log_data(output_port:int, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Data > 0:
		print("Data      |   %s from port %d" % [title, output_port])

func log_arg(arg:String, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Args > 0:
		print("Arg       |   %s on %s" % [arg, title])

## Display a error message in the Output log panel.
## If a node_id is provided, it will display the path and position of the node.
## Otherwise, it will display the path of the resource.
## The node_idx is the index of the node in the generator_data.resources array.
func log_error(message:String, generator_data:GaeaData, node_idx: int = -1):
	if node_idx >= 0:
		printerr("%s:%s in node '%s' - %s" % [
			generator_data.resources[node_idx].resource_path,
			generator_data.node_data[node_idx].position,
			generator_data.resources[node_idx].title,
			message,
		])
	else:
		printerr("%s - %s" % [
			generator_data.resource_path,
			message,
		])
#endregion


#region Miscelaneous
func get_scene() -> PackedScene:
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
	unformatted_text = unformatted_text.replace("GaeaMaterial ", "[hint=%s]GaeaMaterial[/hint] " % GAEA_MATERIAL_HINT)
	unformatted_text = unformatted_text.replace("GaeaMaterialGradient ", "[hint=%s]GaeaMaterialGradient[/hint] " % GAEA_MATERIAL_GRADIENT_HINT)
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
#endregion


#region Data casting methods
static func cast_value(from_type: GaeaGraphNode.SlotTypes, to_type: GaeaGraphNode.SlotTypes, value: Variant) -> Variant:
	match [from_type, to_type]:
		#region Range -> Any
		[GaeaGraphNode.SlotTypes.RANGE, GaeaGraphNode.SlotTypes.VECTOR2]:
			return Vector2(
				value.get("min"), value.get("max")
			)
		#endregion

		#region Number -> Any
		[GaeaGraphNode.SlotTypes.NUMBER, GaeaGraphNode.SlotTypes.VECTOR2]:
			return Vector2(
				value, value
			)
		[GaeaGraphNode.SlotTypes.NUMBER, GaeaGraphNode.SlotTypes.VECTOR3]:
			return Vector3(
				value, value, value
			)
		[GaeaGraphNode.SlotTypes.NUMBER, GaeaGraphNode.SlotTypes.BOOL]:
			return bool(value)
		#endregion

		#region Vector -> Any
		[GaeaGraphNode.SlotTypes.VECTOR2, GaeaGraphNode.SlotTypes.RANGE]:
			return {
				"min": value.x, "max": value.y
			}
		[GaeaGraphNode.SlotTypes.VECTOR2, GaeaGraphNode.SlotTypes.VECTOR3]:
			return Vector3(
				value.x, value.y, 0.0
			)
		[GaeaGraphNode.SlotTypes.VECTOR3, GaeaGraphNode.SlotTypes.VECTOR2]:
			return Vector2(
				value.x, value.y
			)
		[GaeaGraphNode.SlotTypes.VECTOR2, GaeaGraphNode.SlotTypes.NUMBER],\
		[GaeaGraphNode.SlotTypes.VECTOR3, GaeaGraphNode.SlotTypes.NUMBER]:
			return value.x
		#endregion

		#region Boolean -> Any
		[GaeaGraphNode.SlotTypes.BOOL, GaeaGraphNode.SlotTypes.NUMBER]:
			return float(value)
		[GaeaGraphNode.SlotTypes.BOOL, GaeaGraphNode.SlotTypes.VECTOR2]:
			return Vector2(float(value), float(value))
		[GaeaGraphNode.SlotTypes.BOOL, GaeaGraphNode.SlotTypes.VECTOR3]:
			return Vector3(float(value), float(value), float(value))
		#endregion


	printerr("Could not get data from previous node, missing cast method from %s to %s" % [
		GaeaGraphNode.SlotTypes.find_key(from_type),
		GaeaGraphNode.SlotTypes.find_key(to_type),
	])
	return {}
#endregion
