@tool
@icon("../assets/graph.svg")
class_name GaeaGraph
extends Resource
## Resource that holds the saved data for a Gaea graph.

## Current save version used for [GaeaGraphMigration].
const CURRENT_SAVE_VERSION := 4

## Emitted when the size of [member layers] is changed, or when one of its values is changed.
signal layer_count_modified

## Flags used for determining what to log during generation. See [member logging].
enum Log {
	NONE=0,
	EXECUTE=1, ## Log execution data such as current area & current layer.
	TRAVERSE=2, ## Log traverse data (which nodes are being traversed in the graph).
	DATA=4,  ## Log which data is being generated from which port.
	ARGS=8  ## Log which arguments are being grabbed.
}

enum NodeType {
	NODE,
	FRAME
}

## [GaeaLayer]s as seen in the Output node in the graph. Can be used
## to allow more than one [GaeaMaterial] in a single tile.
@export var layers: Array[GaeaLayer] = [GaeaLayer.new()] :
	set(value):
		layers = value
		layer_count_modified.emit()
		emit_changed()
@export_group("Debug")
## Selection of what to print in the Output console during generation. See [enum Log].
@export_flags("Execute", "Traverse", "Data", "Args") var logging:int = Log.NONE
## List of all connections between nodes. The dictionaries contain the following properties:
## [codeblock]
## {
##    from_node: int, # Index of the node in [member resources]
##    from_port: int, # Index of the port of the node
##    to_node: int,   # Index of the node in [member resources]
##    to_port: int,   # Index of the port of the node
##    keep_alive: bool
## }
## [/codeblock]
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export var _connections: Array[Dictionary]
## @deprecated
## Kept for migration of old save data.
var connections: Array[Dictionary]
## @deprecated
## Kept for migration of old save data.
var resource_uids: Array[String]
## @deprecated
## Kept for migration of old save data.
var resources: Array[GaeaNodeResource]
## Used during generation to keep track of node resources.
var _resources: Dictionary[int, GaeaNodeResource]
## Saved data for each [GaeaNodeResource] such as position in the graph and changed arguments.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var _node_data: Dictionary[int, Dictionary]
## @deprecated
## Kept for migration of old save data.
var node_data: Array[Dictionary]
## List of parameters created with [GaeaNodeParameter].
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
## Use [method set_parameter] instead.
@export_storage var _parameters: Dictionary[StringName, Variant]
## @deprecated
## Kept for migration of old save data.
var parameters: Dictionary[StringName, Variant]
## Other saved data, such as [GaeaGraphFrame] information.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var _other: Dictionary
## @deprecated
## Kept for migration of old save data.
var other: Dictionary

## The currently related generator.
var generator: GaeaGenerator
## Cache used during generation to avoid calculating data more than once when unnecessary.
var cache: Dictionary[GaeaNodeResource, Dictionary] = {}


func _init() -> void:
	resource_local_to_scene = true
	notify_property_list_changed()


func add_node(node: GaeaNodeResource, position: Vector2, id: int) -> void:
	_node_data.set(id,
	{
		&"type": NodeType.NODE,
		&"position": position,
		&"salt": randi(),
		&"uid": ResourceUID.id_to_text(
					ResourceLoader.get_resource_uid(node.get_script().get_path())
				)
	}.merged(node.get_custom_saved_data()))


func add_frame(position: Vector2, id: int) -> void:
	_node_data.set(id,
	{
		&"type": NodeType.FRAME,
		&"position": position,
	})


func get_node(id: int) -> GaeaNodeResource:
	return _resources.get(id)


func get_nodes() -> Array[GaeaNodeResource]:
	return _resources.values()


func set_node_data(id: int, data: Dictionary) -> void:
	_node_data.set(id, data)


func get_node_data(id: int) -> Dictionary:
	return _node_data.get(id, {})


func get_ids() -> Array[int]:
	return _resources.keys()


func add_connection(from_id: int, from_port: int, to_id: int, to_port: int) -> void:
	var connection: Dictionary = {
		"from_node": from_id,
		"from_port": from_port,
		"to_node": to_id,
		"to_port": to_port
		}
	if _connections.has(connection):
		return

	_connections.append(connection)


func remove_connection(from_id: int, from_port: int, to_id: int, to_port: int) -> void:
	var connection: Dictionary = {
		"from_node": from_id,
		"from_port": from_port,
		"to_node": to_id,
		"to_port": to_port
		}
	_connections.erase(connection)


func get_connections_to(id: int) -> void:
	return _connections.filter(
		func(value: Dictionary): return value.get("to_node", NAN) == id
	)


func get_connections_from(id: int) -> void:
	return _connections.filter(
		func(value: Dictionary): return value.get("from_node", NAN) == id
	)


## Get the parameter of [param name] from [member _parameters].
func get_parameter(name: StringName) -> Variant:
	return _get(name)


## Set the parameter of [param name] from [member _parameters] to [param value].
func set_parameter(name: StringName, value: Variant) -> void:
	_set(name, value)


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	list.append({
		"name": "Parameters",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	for variable in _parameters.values():
		if variable == null:
			_parameters.erase(_parameters.find_key(variable))
			continue

		list.append(variable)

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in _parameters.values():
		if variable == null:
			continue

		if variable.name == property and typeof(value) == variable.type:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in _parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			return variable.value
	return


func _setup_local_to_scene() -> void:
	#Data migration from previous version.
	if other.get(&"save_version", -1) != CURRENT_SAVE_VERSION:
		GaeaGraphMigration.migrate(self)

	_resources.clear()
	for id in _node_data.keys():
		var base_uid: String = get_node_data(id).get(&"uid", "")
		if base_uid.is_empty():
			continue
		var data: Dictionary = _node_data.get(id, {})
		var resource: GaeaNodeResource = load(base_uid).new()
		if not resource is GaeaNodeResource:
			push_error("Something went wrong, the resource at %s is not a GaeaNodeResource" % base_uid)
			return
		resource._load_save_data(data)
		_resources.set(id, resource)
