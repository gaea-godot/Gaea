@tool
@icon("../../assets/gaea_node_resource.svg")
@abstract
class_name GaeaNodeResource
extends Resource
## A node in a Gaea graph.
##
## Nodes are the base of Gaea's generation system. Some nodes generate data from scratch,
## while others modify said data to produce different results.[br][br]
##
## Gaea nodes are configured and created through their script.
## They are then modified using [GaeaGraphNode]s in the bottom Gaea panel.
##
## @tutorial(Anatomy of a Graph): https://gaea-godot.github.io/gaea-docs/#/2.0/tutorials/anatomy-of-a-graph


@warning_ignore_start("unused_parameter")
@warning_ignore_start("unused_signal")

signal argument_list_changed
signal argument_value_changed(arg_name: StringName, new_value: Variant)
signal enum_value_changed(enum_idx: int, option_value: int)

#region Description Formatting
const PARAM_TEXT_COLOR := Color("cdbff0")
const PARAM_BG_COLOR := Color("bfbfbf1a")
const CODE_TEXT_COLOR := Color("da8a95")
const CODE_BG_COLOR := Color("8080801a")

const GAEA_MATERIAL_HINT := "Resource used to tell GaeaRenderers what to place."
const GAEA_MATERIAL_GRADIENT_HINT := "Resource that maps values from 0.0-1.0 to certain GaeaMaterials."
#endregion

## List of all connections to this node. Doesn't include connections [i]from[/i] this node.[br]
## The dictionaries contain the following properties:
## [codeblock]
## {
##    from_node: int, # Index of the node in [member GaeaGraph.resources]
##    from_port: int, # Index of the port of the node
##    to_node: int,   # Index of the node in [member GaeaGraph.resources]
##    to_port: int,   # Index of the port of the node
##    keep_alive: bool
## }
## [/codeblock]
var connections: Array[Dictionary]
## The related [GaeaGraphNode] for editing in the Gaea graph editor.
## This is null during runtime.
var node: GraphElement
## A Dictionary holding the values of the arguments
## where the keys are their names.
var arguments: Dictionary
## All the currently-selected values for the enums.
var enum_selections: Array
## An additional value added to the generation's seed to prevent
## duplicates of the same node from having the same randomness. (See [member GaeaGenerator.seed]).
var salt: int = 0
## Id in the [GaeaGraph] save data.
var id: int = 0
## If empty, [method _get_title] will be used instead.
var tree_name_override: String = "" : set = set_tree_name_override
@export_storage var default_value_overrides: Dictionary[StringName, Variant]
@export_storage var default_enum_value_overrides: Dictionary[int, int]


func notify_argument_list_changed() -> void:
	argument_list_changed.emit()


## Override the name used in the 'Create Node' dialog.
func set_tree_name_override(value: String) -> void:
	tree_name_override = value


## Override the default value of the argument of [param arg_name].
func set_default_argument_value_override(arg_name: StringName, value: Variant) -> void:
	default_value_overrides.set(arg_name, value)


## Clear the overridden default value of the argument of [param arg_name].
func clear_default_argument_value_override(arg_name: StringName) -> void:
	default_value_overrides.erase(arg_name)


## Override the default value of the enum at [param enum_idx].
func set_default_enum_value_override(enum_idx: int, value: int) -> void:
	default_enum_value_overrides.set(enum_idx, value)


## Clear the overridden default value of the enum at [param enum_idx].
func clear_default_enum_value_override(enum_idx: int) -> void:
	default_enum_value_overrides.erase(enum_idx)


## Public version of [method _get_tree_items]. Prefer to override that method over this one.
func get_tree_items() -> Array[GaeaNodeResource]:
	return _get_tree_items()


## Public version of [method _get_title]. Prefer to override that method over this one.
func get_title() -> String:
	return _get_title()


## Public version of [method get_description]. Prefer to override that method over this one.
func get_description() -> String:
	return _get_description()


func get_type() -> GaeaValue.Type:
	if not _get_output_ports_list().is_empty():
		return _get_output_port_type(_get_output_ports_list().back())
	return GaeaValue.Type.NULL


## Public version of [method _get_enums_count]. Prefer to override that method over this one.
func get_enums_count() -> int:
	return _get_enums_count()


## Public version of [method _get_enum_options]. Prefer to override that method over this one.
func get_enum_options(idx: int) -> Dictionary:
	return _get_enum_options(idx)


## Returns the currently selected option for the enum at [param idx].
func get_enum_selection(idx: int) -> int:
	return get_enum_default_value(idx) if enum_selections.size() <= idx else enum_selections[idx]


## Public version of [method _get_enum_option_display_name]. Prefer to override that method over this one.
func get_enum_option_display_name(enum_idx: int, option_value: int) -> String:
	return _get_enum_option_display_name(enum_idx, option_value)


func get_enum_option_icon(enum_idx: int, option_value: int) -> Texture:
	return _get_enum_option_icon(enum_idx, option_value)


## Public version of [method _get_enum_default_value]. Prefer to override that method over this one.
func get_enum_default_value(enum_idx: int) -> int:
	return default_enum_value_overrides.get(enum_idx, _get_enum_default_value(enum_idx))


## Public version of [method _get_arguments_list]. Prefer to override that method over this one.
func get_arguments_list() -> Array[StringName]:
	return _get_arguments_list()


## Public version of [method _get_argument_type]. Prefer to override that method over this one.
func get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name.begins_with(&"CATEGORY"):
		return GaeaValue.Type.CATEGORY

	return _get_argument_type(arg_name)


## Public version of [method _get_argument_display_name]. Prefer to override that method over this one.
func get_argument_display_name(arg_name: StringName) -> String:
	return _get_argument_display_name(arg_name)


## Public version of [method _get_argument_default_value]. Prefer to override that method over this one.
func get_argument_default_value(arg_name: StringName) -> Variant:
	return default_value_overrides.get(arg_name, _get_argument_default_value(arg_name))

## Public version of [method _get_argument_hint]. Prefer to override that method over this one.
func get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	return _get_argument_hint(arg_name)


## Public version of [method _has_input_slot]. Prefer to override that method over this one.
func has_input_slot(arg_name: StringName) -> bool:
	return _has_input_slot(arg_name)


## Public version of [method _get_output_ports_list]. Prefer to override that method over this one.
func get_output_ports_list() -> Array[StringName]:
	return _get_output_ports_list()


## Public version of [method _get_output_port_display_name]. Prefer to override that method over this one.
func get_output_port_display_name(output_name: StringName) -> String:
	return _get_output_port_display_name(output_name)


## Public version of [method _get_output_port_type]. Prefer to override that method over this one.
func get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return _get_output_port_type(output_name)


## Public version of [method _get_overridden_output_port_idx]. Prefer to override that method over this one.
func get_overridden_output_port_idx(output_name: StringName) -> int:
	return _get_overridden_output_port_idx(output_name)


## Get the name of the node as shown in the 'Create Node' dialog. Is normally the same
## title as in the graph, but can be overridden with [member tree_name_override].
func get_tree_name() -> String:
	return tree_name_override if not tree_name_override.is_empty() else _get_title()


## Public version of [method _is_available]. Prefer to override that method over this one.
func is_available() -> bool:
	return _is_available()


## Public version of [method _get_custom_saved_data]. Prefer to override that method over this one.
func get_custom_saved_data() -> Dictionary[StringName, Variant]:
	return _get_custom_saved_data()


## Override this method to define the name shown in the title bar of this node.
## Defining this method is [b]required[/b].
@abstract func _get_title() -> String


## Override this method to define the description shown in the 'Create Node' dialog and in a
## tooltip when hovering over this node in the graph editor.
## Defining this method is [b]optional[/b], but recommended. If not defined, the description will be empty.
func _get_description() -> String:
	return ""


## Override this method to change the items shown in the 'Create Node' dialog related to this resource.[br][br]
## Defining this method can be useful to add multiple items with different default values and names if needed,
## but it is not recommended to change this.
func _get_tree_items() -> Array[GaeaNodeResource]:
	return [get_script().new()]


## Override this method to add enum properties on the top of the nodes for things like changing
## operations or types.
func _get_enums_count() -> int:
	return 0


## Override this method to define the options available for the added enums.[br][br]
## The returned [Dictionary] should be [code]{String: int}[/code]. Built-in enums can be used directly.
func _get_enum_options(idx: int) -> Dictionary:
	return {}


## Override this method if you want to change the display name for the options in the added enums.[br][br]
## Defining this method is [b]optional[/b]. If not defined, the name will be [code]_get_enum_options(enum_idx).find_key(option_value).capitalize()[/code].
func _get_enum_option_display_name(enum_idx: int, option_value: int) -> String:
	var options := _get_enum_options(enum_idx)
	var key = options.find_key(option_value)
	if typeof(key) != TYPE_STRING or key == null:
		return ""
	return key.capitalize()


## Override this method if you want to add icons to the options in the added enums.[br][br]
## Defining this method is [b]optional[/b].
func _get_enum_option_icon(enum_idx: int, option_value: int) -> Texture:
	return null


## Override this method to define the default value of the added enums.[br][br]
## Defining this method is [b]optional[/b].
func _get_enum_default_value(enum_idx: int) -> int:
	return _get_enum_options(enum_idx).values().front()


## Override this method to define the arguments and inputs that will be available in the node.
## Should be a list of (preferably) [code]snake_case[/code] names.[br][br]
## Defining this method is [b]required[/b].
@abstract func _get_arguments_list() -> Array[StringName]


## Override this method to define the type of the arguments defined in [method _get_arguments_list].[br][br]
## Defining this method is [b]required[/b].
@abstract
func _get_argument_type(arg_name: StringName) -> GaeaValue.Type


## Override this method if you want to change the display name for any arguments in [method _get_arguments_list].[br][br]
## Defining this method is [b]optional[/b]. If not defined, the name will be [code]arg_name.capitalize()[/code].
func _get_argument_display_name(arg_name: StringName) -> String:
	return arg_name.trim_prefix(&"CATEGORY_").capitalize()


## Override this method to define the default value of the arguments defined in [method _get_arguments_list].[br][br]
## Defining this method is [b]optional[/b], but recommended. If not defined, the used default value will be the one in [method GaeaValue.get_default_value]
## corresponding to the argument's type.
func _get_argument_default_value(arg_name: StringName) -> Variant:
	return GaeaValue.get_default_value(_get_argument_type(arg_name))


## Override this method to change the way the editors for the arguments behave. For example,
## if the returned [Dictionary] has a [code]"min"[/code] key, [GaeaNumberArgumentEditor] will not be able to go below that number.[br][br]
## Defining this method is [b]optional[/b].
func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	return {}


## Override this method to determine whether or not arguments can be connected to.[br]
## [b]Note[/b]: Some argument types can't have input slots. See [method GaeaValue.is_wireable].[br][br]
## Defining this method is [b]optional[/b]. If not defined, it'll always be true.
func _has_input_slot(arg_name: StringName) -> bool:
	return true


## Override this method to define the outputs this node will have.[br][br]
## Defining this method is [b]required[/b].
@abstract func _get_output_ports_list() -> Array[StringName]


## Override this method to define the display name for any outputs in [method _get_output_ports_list].[br][br]
## Defining this method is [b]optional[/b]. If not defined, the name will be [code]output_name.capitalize()[/code].
func _get_output_port_display_name(output_name: StringName) -> String:
	return output_name.capitalize()


## Override this method to define the type of the outputs defined in [method _get_output_ports_list].[br][br]
## Defining this method is [b]required[/b].
@abstract func _get_output_port_type(output_name: StringName) -> GaeaValue.Type


## If this returns a value higher than 0, the output slot for [param output_name] will be
## added in that index instead of below the arguments.[br][br]
## Overriding this method is [b]dangerous[/b]. Outputs should still follow the same order as in
## [method _get_output_list]; and the slot won't have a display name nor a preview.
func _get_overridden_output_port_idx(output_name: StringName) -> int:
	return -1


## If this returns [code]false[/code], this node won't show up in the 'Create Node' dialog.
## By default, it hides nodes with the [annotation @GDScript.@abstract] annotation.
func _is_available() -> bool:
	return not get_script().is_abstract()


## Override to append custom data to the saved data in [GaeaGraph._node_data].
func _get_custom_saved_data() -> Dictionary[StringName, Variant]:
	return {}


func set_enum_value(enum_idx: int, option_value: int) -> void:
	if enum_idx >= enum_selections.size():
		for idx in _get_enums_count():
			enum_selections.append(get_enum_default_value(idx))

	enum_selections.set(enum_idx, option_value)
	enum_value_changed.emit(enum_idx, option_value)
	_on_enum_value_changed(enum_idx, option_value)


## Called when an enum is changed in the editor. When overridden,
## [method super] should [b]always[/b] be called at the head of the function.
func _on_enum_value_changed(enum_idx: int, option_value: int) -> void:
	return


func set_argument_value(arg_name: StringName, new_value: Variant) -> void:
	arguments.set(arg_name, new_value)
	argument_value_changed.emit(arg_name, new_value)
	_on_argument_value_changed(arg_name, new_value)


## Called when an enum is changed in the editor. Does nothing by default, but can be used to call
## [method notify_arguments_list_changed] to rebuild the node.
func _on_argument_value_changed(arg_name: StringName, new_value: Variant) -> void:
	return







#region Args
## Returns the value of the argument of [param name]. Pass in [param graph] to allow overriding with input slots.[br]
## [param area] is used for values of the type Data or Map. (See [enum GaeaValue.Type]).
func _get_arg(arg_name: StringName, area: AABB, graph: GaeaGraph) -> Variant:
	_log_arg(arg_name, graph)

	var connection := _get_argument_connection(arg_name)
	if not connection.is_empty():
		var connected_id = connection.from_node
		var connected_node = graph.get_node(connected_id)
		var connected_output = connected_node.connection_idx_to_output(connection.from_port)
		var connected_data = connected_node.traverse(
			connected_output,
			area,
			graph
		)
		if connected_data.has("value"):
			var connected_value = connected_data.get("value")
			var connected_type: GaeaValue.Type = connected_node.get_output_port_type(connected_output)
			if connected_data.has("type"):
				connected_type = connected_data.get("type")
			if connected_type == _get_argument_type(arg_name):
				return connected_value
			else:
				return GaeaValueCast.cast_value(connected_type, _get_argument_type(arg_name), connected_value)
		else:
			_log_error("Could not get data from previous node, using default value instead.", graph, connected_id)
			return get_argument_default_value(arg_name)

	return arguments.get(arg_name, get_argument_default_value(arg_name))
#endregion


#region Execution
## Traverses the graph using this node's connections, and returns the result for [param output_port].
func traverse(output_port: StringName, area: AABB, graph: GaeaGraph) -> Variant:
	_log_traverse(graph)

	# Caching
	var use_caching = _use_caching(output_port, graph)
	if use_caching and _has_cached_data(output_port, graph):
		return _get_cached_data(output_port, graph)

	# Validation
	if not _has_inputs_connected(_get_required_arguments(), graph):
		return {}

	# Get Data

	_log_data(output_port, graph)
	var results: Dictionary = {
		&"value": _get_data(output_port, area, graph),
		&"type": _get_output_port_type(output_port)
	}

	if use_caching:
		_set_cached_data(output_port, graph, results)
	return results


## Returns the data corresponding to [param output_port]. Should be overridden to create custom
## behavior for each node.
@abstract
func _get_data(_output_port: StringName, _area: AABB, _graph: GaeaGraph) -> Variant
#endregion


#region Caching
## Checks if this node should use caching or not. Can be overridden to disable it.
func _use_caching(_output_port: StringName, _graph: GaeaGraph) -> bool:
	return true


## Adds or sets data to the cache at GaeaNodeResource, then output_port index.
## This is called during [method traverse] if [method _use_caching] returns [code]true[/code],
## but can also be called in special cases where you want to manually add cached values.
func _set_cached_data(output_port: StringName, graph: GaeaGraph, new_data:Dictionary) -> void:
	var node_cache:Dictionary = graph.cache.get_or_add(self, {})
	node_cache[output_port] = new_data


# Checks if the cache has data corresponding to this node, then if it has it for output_port.
func _has_cached_data(output_port: StringName, graph: GaeaGraph) -> bool:
	return graph.cache.has(self) and graph.cache[self].has(output_port)


# Gets cached data by GaeaNodeResource, then output_port index.
# Assumes that data exists, will error out if it doesn't.
func _get_cached_data(output_port: StringName, graph: GaeaGraph) -> Dictionary:
	return graph.cache[self][output_port]
#endregion


#region Inputs
## Returns an array of the name of the arguments that are expected to be connected for the Node Resource to
## execute properly. Can be overridden in nodes that extend [GaeaNodeResource].
func _get_required_arguments() -> Array[StringName]:
	return []


# Returns [code]true[/code] if all [param required] inputs are connected.
func _has_inputs_connected(required: Array[StringName], graph: GaeaGraph) -> bool:
	for idx in required:
		if _get_input_resource(idx, graph) == null:
			return false
	return true


# Gets the [GaeaNodeResource] connected to the input of name [param arg_name].
func _get_input_resource(arg_name: StringName, graph: GaeaGraph) -> GaeaNodeResource:
	var connection = _get_argument_connection(arg_name)
	if connection.is_empty() or connection.from_node == -1:
		return null

	var data_input_resource: GaeaNodeResource = graph.get_node(connection.from_node)
	if not is_instance_valid(data_input_resource):
		return null

	return data_input_resource
#endregion


#region Argument Connections
## Returns the [StringName] corresponding to [param argument_idx].
func connection_idx_to_argument(argument_idx: int) -> StringName:
	var filtered_argument_list := _get_arguments_list().filter(_filter_has_input)
	if filtered_argument_list.size() <= argument_idx:
		return &""
	return filtered_argument_list[argument_idx]


func _get_argument_connection(arg_name: StringName) -> Dictionary:
	var idx = _get_arguments_list().filter(_filter_has_input).find(arg_name)
	if idx == -1:
		return {}
	for connection in connections:
		if connection.to_port == idx:
			return connection
	return {}


func _filter_has_input(arg_name: StringName) -> bool:
	return GaeaValue.is_wireable(_get_argument_type(arg_name)) and _has_input_slot(arg_name)
#endregion

#region Output connections
## Returns the connection idx of [param output].
func output_to_connection_idx(output: StringName) -> int:
	return _get_output_ports_list().find(output)


## Returns the [StringName] corresponding to [param output_idx].
func connection_idx_to_output(output_idx: int) -> StringName:
	if _get_output_ports_list().size() <= output_idx:
		return &""
	return _get_output_ports_list().get(output_idx)
#endregion


#region Logging
# If enabled in [member GaeaGraph.logging], log the execution information. (See [enum GaeaGraph.Log]).
func _log_execute(message:String, area:AABB, graph: GaeaGraph):
	if is_instance_valid(graph) and graph.logging & GaeaGraph.Log.EXECUTE > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sArea %s on %s" % [message, area, _get_title()])


# If enabled in [member GaeaGraph.logging], log the layer information. (See [enum GaeaGraph.Log]).
func _log_layer(message:String, layer:int, graph: GaeaGraph):
	if is_instance_valid(graph) and graph.logging & GaeaGraph.Log.EXECUTE > 0:
		message = message.strip_edges()
		message = message if message == "" else message + " "
		print("Execute   |   %sLayer %d on %s" % [message, layer, _get_title()])


# If enabled in [member GaeaGraph.logging], log the traverse information. (See [enum GaeaGraph.Log]).
func _log_traverse(graph: GaeaGraph):
	if is_instance_valid(graph) and graph.logging & GaeaGraph.Log.TRAVERSE > 0:
		print("Traverse  |   %s" % [_get_title()])


## If enabled in [member GaeaGraph.logging], log the data information. (See [enum GaeaGraph.Log]).
func _log_data(output_port: StringName, graph: GaeaGraph):
	if is_instance_valid(graph) and graph.logging & GaeaGraph.Log.DATA > 0:
		print("Data      |   %s from port &\"%s\"" % [_get_title(), output_port])


# If enabled in [member GaeaGraph.logging], log the argument information. (See [enum GaeaGraph.Log]).
func _log_arg(arg:String, graph: GaeaGraph):
	if is_instance_valid(graph) and graph.logging & GaeaGraph.Log.ARGS > 0:
		print("Arg       |   %s on %s" % [arg, _get_title()])


## Display a error message in the Output log panel.
## If a [param node_idx] is provided, it will display the path and position of the node.
## Otherwise, it will display the path of the resource.
## The [param node_idx] is the index of the node in the graph.resources array.
func _log_error(message:String, graph: GaeaGraph, node_idx: int = -1):
	if node_idx >= 0:
		printerr("%s:%s in node '%s' - %s" % [
			graph.get_node(node_idx).resource_path,
			graph.get_node_data(node_idx).position,
			graph.get_node(node_idx).get_title(),
			message,
		])
	else:
		printerr("%s - %s" % [
			graph.resource_path,
			message,
		])
#endregion


#region Miscelaneous
## Public version of [method _get_scene].
func get_scene() -> PackedScene:
	return _get_scene()


## Virtual method. Should be overridden if the node should use a different scene in the Gaea editor from the base one.
func _get_scene() -> PackedScene:
	return load("uid://b7e2d15kxt2im")


func get_scene_script() -> GDScript:
	return _get_scene_script()


func _get_scene_script() -> GDScript:
	return null


## Returns an array of points in the [param axis] of [param area].
func _get_axis_range(axis: Vector3i.Axis, area: AABB) -> Array:
	match axis:
		Vector3i.AXIS_X: return range(area.position.x, area.end.x)
		Vector3i.AXIS_Y: return range(area.position.y, area.end.y)
		Vector3i.AXIS_Z: return range(area.position.z, area.end.z)
	return []


## Used by the 'Create Node' tree to display [member description] in an organized manner.
static func get_formatted_text(unformatted_text: String) -> String:
	var param_regex = RegEx.new()
	param_regex.compile("\\[param ([^\\]]+)\\]")

	return param_regex.sub(unformatted_text, "[bgcolor=%s][color=%s]$1[/color][/bgcolor]" % [PARAM_BG_COLOR.to_html(true), PARAM_TEXT_COLOR.to_html(true)], true) \
		.replace("GaeaMaterial ", "[hint=%s]GaeaMaterial[/hint] " % GAEA_MATERIAL_HINT) \
		.replace("GradientGaeaMaterial ", "[hint=%s]GradientGaeaMaterial[/hint] " % GAEA_MATERIAL_GRADIENT_HINT) \
		.replace("[code]", "[bgcolor=%s][color=%s][code]" % [CODE_BG_COLOR.to_html(true), CODE_TEXT_COLOR.to_html(true)]) \
		.replace("[/code]", "[/code][/color][/bgcolor]")


## Returns the corresponding type icon.
func get_icon() -> Texture2D:
	return GaeaValue.get_display_icon(get_type())


## Returns the corresponding type color.
func get_title_color() -> Color:
	return GaeaValue.get_color(get_type())


func _is_point_outside_area(area: AABB, point: Vector3) -> bool:
	area.end -= Vector3.ONE
	return (point.x < area.position.x or point.y < area.position.y or point.z < area.position.z or
			point.x > area.end.x or point.y > area.end.y or point.z > area.end.z)

func define_rng(graph: GaeaGraph) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.set_seed(graph.generator.seed + salt)
	seed(graph.generator.seed + salt)
	return rng
#endregion


func load_save_data(saved_data: Dictionary) -> void:
	_load_save_data(saved_data)


func _load_save_data(saved_data: Dictionary) -> void:
	salt = saved_data.get(&"salt", 0)
	arguments = saved_data.get(&"arguments", {})
	enum_selections = saved_data.get(&"enums", [])
