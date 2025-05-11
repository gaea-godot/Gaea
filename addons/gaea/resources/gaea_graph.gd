@tool
@icon("../assets/graph.svg")
class_name GaeaGraph
extends Resource
## Resource that holds the saved data for a Gaea graph.

## Current save version used for [GaeaGraphMigration].
const CURRENT_SAVE_VERSION := 3

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
@export_storage var connections: Array[Dictionary]
## List of all UIDs of the [GaeaNodeResource]s in the graph.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var resource_uids: Array[String]
## Used for migration of old save data.
var resources: Array[GaeaNodeResource]
## Saved data for each [GaeaNodeResource] such as position in the graph and changed arguments.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var node_data: Array[Dictionary]
## List of parameters created with [GaeaNodeParameter].
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
## Use [method set_parameter] instead.
@export_storage var parameters: Dictionary[StringName, Variant]
## Other saved data, such as [GaeaGraphFrame] information.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var other: Dictionary

## The currently related generator.
var generator: GaeaGenerator
## Cache used during generation to avoid calculating data more than once when unnecessary.
var cache: Dictionary[GaeaNodeResource, Dictionary] = {}


func _init() -> void:
	resource_local_to_scene = true
	notify_property_list_changed()

## Get the parameter of [param name] from [member parameters].
func get_parameter(name: StringName) -> Variant:
	return _get(name)


## Set the parameter of [param name] from [member parameters] to [param value].
func set_parameter(name: StringName, value: Variant) -> void:
	_set(name, value)


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	list.append({
		"name": "Parameters",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	for variable in parameters.values():
		if variable == null:
			parameters.erase(parameters.find_key(variable))
			continue

		list.append(variable)

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property and typeof(value) == variable.type:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			return variable.value
	return


func _setup_local_to_scene() -> void:
	#Data migration from previous version.
	if other.get(&"save_version", -1) != CURRENT_SAVE_VERSION:
		GaeaGraphMigration.migrate(self)

	resources = []
	for idx in resource_uids.size():
		var base_uid = resource_uids[idx]
		var data: Dictionary = node_data[idx]
		var resource: GaeaNodeResource = load(base_uid).new()
		if not resource is GaeaNodeResource:
			push_error("Something went wrong, the resource at %s is not a GaeaNodeResource" % base_uid)
			return
		resource._load_save_data(data)
		resources.append(resource)
