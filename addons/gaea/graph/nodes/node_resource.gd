@tool
@icon("../../assets/gaea_node_resource.svg")
class_name GaeaNodeResource
extends Resource
## A node in a Gaea graph.
##
## Nodes are the base of Gaea's generation system. Some nodes generate data from scratch,
## while others modify said data to produce different results.[br][br]
##
## This resource holds data such as required inputs, [member params], [member outputs], etc.,
## and are in charge of the generation and/or modification of data/values. See [GaeaValue]
## for what this data can be.[br][br]
##
## They are then modified using [GaeaGraphNode]s in the bottom Gaea panel.
##
## @tutorial(Anatomy of a Graph): https://gaea-godot.github.io/gaea-docs/#/2.0/tutorials/anatomy-of-a-graph


#region Description Formatting
const PARAM_TEXT_COLOR := "cdbff0"
const PARAM_BG_COLOR := "bfbfbf1a"
const CODE_TEXT_COLOR := "da8a95"
const CODE_BG_COLOR := "8080801a"

const GAEA_MATERIAL_HINT := "Resource used to tell GaeaRenderers what to place."
const GAEA_MATERIAL_GRADIENT_HINT := "Resource that maps values from 0.0-1.0 to certain GaeaMaterials."
#endregion

## A list of parameters and/or input slots.
@export var params: Array[GaeaNodeSlotParam]
## A list of the output slots this node has.
@export var outputs: Array[GaeaNodeSlotOutput]

## The title to be used in the 'Create Node' pop-up or in the graph.
@export var title: String = "Node"
## The description to be used in the 'Create Node' pop-up or as a tooltip when
## hovering over the node in the graph.
@export_multiline var description: String = ""

## List of all connections to this node. Doesn't include connections [i]from[/i] this node.[br]
## The dictionaries contain the following properties:
## [codeblock]
## {
##    from_node: int, # Index of the node in [member GaeaData.resources]
##    from_port: int, # Index of the port of the node
##    to_node: int,   # Index of the node in [member GaeaData.resources]
##    to_port: int,   # Index of the port of the node
##    keep_alive: bool
## }
## [/codeblock]
var connections: Array[Dictionary]
## The UID of the original resource this was duplicated from.
var resource_uid: String
## The related [GaeaGraphNode] for editing in the Gaea graph editor.
var node: GaeaGraphNode
## A Dictionary holding the values of the arguments in [member params]
## where the keys are their names.
var data: Dictionary
## An additional value added to the generation's seed to prevent
## duplicates of the same node from having the same randomness. (See [member GaeaGenerator.seed]).
var salt: int = 0

## Used in [method _get_axis_range].
enum Axis {
	X,
	Y,
	Z
}


#region Execution
## Traverses the graph using this node's connections, and returns the result for [param output_port].
func traverse(output_port: GaeaNodeSlotOutput, area: AABB, generator_data:GaeaData) -> Variant:
	_log_traverse(generator_data)

	# Caching
	var use_caching = _use_caching(output_port, generator_data)
	if use_caching and _has_cached_data(output_port, generator_data):
		return _get_cached_data(output_port, generator_data)

	# Validation
	if not _has_inputs_connected(_get_required_params(), generator_data):
		return {}

	# Get Data
	var results:Dictionary = _get_data(output_port, area, generator_data)

	if use_caching:
		_set_cached_data(output_port, generator_data, results)
	return results


## Returns the data corresponding to [param output_port]. Should be overriden to create custom
## behavior for each node.
@warning_ignore("unused_parameter")
func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	return {}
#endregion


#region Caching
## Checks if this node should use caching or not. Can be overriden to disable it.
func _use_caching(_output_port: GaeaNodeSlotOutput, _generator_data:GaeaData) -> bool:
	return true


## Adds or sets data to the cache at GaeaNodeResource, then output_port index.
## This is called during [method traverse] if [method _use_caching] returns [code]true[/code],
## but can also be called in special cases where you want to manually add cached values.
func _set_cached_data(output_port: GaeaNodeSlotOutput, generator_data:GaeaData, new_data:Dictionary) -> void:
	var node_cache:Dictionary = generator_data.cache.get_or_add(self, {})
	node_cache[output_port.name] = new_data


# Checks if the cache has data corresponding to this node, then if it has it for output_port.
func _has_cached_data(output_port: GaeaNodeSlotOutput, generator_data:GaeaData) -> bool:
	return generator_data.cache.has(self) and generator_data.cache[self].has(output_port.name)


# Gets cached data by GaeaNodeResource, then output_port index.
# Assumes that data exists, will error out if it doesn't.
func _get_cached_data(output_port: GaeaNodeSlotOutput, generator_data:GaeaData) -> Dictionary:
	return generator_data.cache[self][output_port.name]
#endregion


#region Inputs
## Returns an array of the name of the parameters that are expected to be connected for the Node Resource to
## execute properly. Can be overridden in nodes that extend [GaeaNodeResource].
func _get_required_params() -> Array[StringName]:
	return []


# Returns [code]true[/code] if all [param required] inputs are connected.
func _has_inputs_connected(required: Array[StringName], generator_data:GaeaData) -> bool:
	for idx in required:
		if _get_input_resource(idx, generator_data) == null:
			return false
	return true


# Gets the [GaeaNodeResource] connected to the input of name [param param_name].
func _get_input_resource(param_name: StringName, generator_data:GaeaData) -> GaeaNodeResource:
	var param := _find_param_by_name(param_name)
	var connection = _get_param_connection(param)
	if connection.is_empty() or connection.from_node == -1:
		return null

	var data_input_resource: GaeaNodeResource = generator_data.resources.get(connection.from_node)
	if not is_instance_valid(data_input_resource):
		return null

	return data_input_resource
#endregion


#region Args
## Returns the value of the argument of [param name]. Pass in [param generator_data] to allow overriding with input slots.[br]
## [param area] is used for values of the type Data or Map. (See [enum GaeaValue.Type]).
func _get_arg(name: StringName, area: AABB, generator_data: GaeaData) -> Variant:
	_log_arg(name, generator_data)

	var param := _find_param_by_name(name)
	if not is_instance_valid(param):
		return null

	var connection := _get_param_connection(param)
	if not connection.is_empty():
		var connected_idx = connection.from_node
		var connected_node = generator_data.resources[connected_idx]
		var connected_output = connected_node.connection_idx_to_output(connection.from_port)
		var connected_data = connected_node.traverse(
			connected_output,
			area,
			generator_data
		)
		if connected_data.has("value"):
			var connected_value = connected_data.get("value")
			var connected_type: GaeaValue.Type = connected_output.type
			if connected_data.has("type"):
				connected_type = connected_data.get("type")
			if connected_type == param.type:
				return connected_value
			else:
				return GaeaValue.cast_value(connected_type, param.type, connected_value)
		else:
			_log_error("Could not get data from previous node, using default value instead.", generator_data, connected_idx)
			return param.default_value

	return data.get(name, param.default_value)
#endregion


#region Params connections
# Returns the [GaeaNodeSlotParam] in [member params] corresponding to [param param_name].
func _find_param_by_name(param_name: StringName) -> GaeaNodeSlotParam:
	for param in params:
		if param.name == param_name:
			return param
	return null


## Returns the connection idx of [param param].
func param_to_connection_idx(param: GaeaNodeSlotParam) -> int:
	return params.find(param)


## Returns the [GaeaNodeSlotParam] corresponding to [param param_idx].
func connection_idx_to_param(param_idx: int) -> GaeaNodeSlotParam:
	return params[param_idx]


# Returns the connection data corresponding to [param param].
func _get_param_connection(param: GaeaNodeSlotParam) -> Dictionary:
	var idx = param_to_connection_idx(param)
	for connection in connections:
		if connection.to_port == idx:
			return connection
	return {}
#endregion


#region Output connections
# Returns the [GaeaNodeSlotOutput] in [member outputs] corresponding to [param output_name].
func _find_output_by_name(output_name: StringName) -> GaeaNodeSlotOutput:
	for output in outputs:
		if output.name == output_name:
			return output
	return null


## Returns the connection idx of [param output].
func output_to_connection_idx(output: GaeaNodeSlotOutput) -> int:
	return outputs.find(output)


## Returns the [GaeaNodeSlotOutput] corresponding to [param output_idx].
func connection_idx_to_output(output_idx: int) -> GaeaNodeSlotOutput:
	return outputs[output_idx]
#endregion


#region Logging
# If enabled in [member GaeaData.logging], log the execution information. (See [enum GaeaData.Log]).
func _log_execute(message:String, area:AABB, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Execute > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sArea %s on %s" % [message, area, title])


# If enabled in [member GaeaData.logging], log the layer information. (See [enum GaeaData.Log]).
func _log_layer(message:String, layer:int, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Execute > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sLayer %d on %s" % [message, layer, title])


# If enabled in [member GaeaData.logging], log the traverse information. (See [enum GaeaData.Log]).
func _log_traverse(generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Traverse > 0:
		print("Traverse  |   %s" % [title])


## If enabled in [member GaeaData.logging], log the data information. (See [enum GaeaData.Log]).
## Should be called in [method _get_data]
func _log_data(output_port: GaeaNodeSlotOutput, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Data > 0:
		print("Data      |   %s from port &\"%s\"" % [title, output_port.name])


# If enabled in [member GaeaData.logging], log the argument information. (See [enum GaeaData.Log]).
func _log_arg(arg:String, generator_data:GaeaData):
	if is_instance_valid(generator_data) and generator_data.logging & GaeaData.Log.Args > 0:
		print("Arg       |   %s on %s" % [arg, title])


## Display a error message in the Output log panel.
## If a [param node_idx] is provided, it will display the path and position of the node.
## Otherwise, it will display the path of the resource.
## The [param node_idx] is the index of the node in the generator_data.resources array.
func _log_error(message:String, generator_data:GaeaData, node_idx: int = -1):
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
## Public version of [method _get_scene].
func get_scene() -> PackedScene:
	return _get_scene()


## Virtual method. Should be overriden if the node should use a different scene in the Gaea editor from the base one.
func _get_scene() -> PackedScene:
	return preload("uid://b7e2d15kxt2im")


## Returns an array of points in the [param axis] of [param area].
func _get_axis_range(axis: Axis, area: AABB) -> Array:
	match axis:
		Axis.X: return range(area.position.x, area.end.x)
		Axis.Y: return range(area.position.y, area.end.y)
		Axis.Z: return range(area.position.z, area.end.z)
	return []


## Used by the 'Create Node' tree to display [member description] in an organized manner.
static func get_formatted_text(unformatted_text: String) -> String:
	unformatted_text = unformatted_text.replace("[param]", "[color=%s][bgcolor=%s]" % [PARAM_TEXT_COLOR, PARAM_BG_COLOR])
	unformatted_text = unformatted_text.replace("GaeaMaterial ", "[hint=%s]GaeaMaterial[/hint] " % GAEA_MATERIAL_HINT)
	unformatted_text = unformatted_text.replace("GaeaMaterialGradient ", "[hint=%s]GaeaMaterialGradient[/hint] " % GAEA_MATERIAL_GRADIENT_HINT)
	unformatted_text = unformatted_text.replace("[code]", "[color=%s][bgcolor=%s]" % [CODE_TEXT_COLOR, CODE_BG_COLOR])

	unformatted_text = unformatted_text.replace("[/c]", "[/color]")
	unformatted_text = unformatted_text.replace("[/bg]", "[/bgcolor]")
	return unformatted_text


## Returns the type of the last output to be used for icon and title color.
func get_type() -> GaeaValue.Type:
	if outputs.size() > 0:
		return outputs[-1].type
	return GaeaValue.Type.NULL


## Returns the corresponding type icon.
func get_icon() -> Texture2D:
	return GaeaValue.get_display_icon(get_type())


## Returns the corresponding type color.
func get_title_color() -> Color:
	return GaeaValue.get_color(get_type())


## Returns whether or not it's an output node.
func is_output() -> bool:
	return has_meta(&"is_output") and get_meta(&"is_output") == true


func _is_point_outside_area(area: AABB, point: Vector3) -> bool:
	area.end -= Vector3.ONE
	return (point.x < area.position.x or point.y < area.position.y or point.z < area.position.z or
			point.x > area.end.x or point.y > area.end.y or point.z > area.end.z)


func _instantiate_duplicate() -> GaeaNodeResource:
	var new_resource = duplicate() as GaeaNodeResource
	new_resource.resource_uid = ResourceUID.id_to_text(
		ResourceLoader.get_resource_uid(resource_path)
	)
	return new_resource
#endregion


func _load_save_data(saved_data: Dictionary) -> void:
	salt = saved_data.get("salt", 0)
	data = saved_data.get("data", {})
