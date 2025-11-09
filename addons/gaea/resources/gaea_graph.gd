@tool
@icon("../assets/graph.svg")
class_name GaeaGraph
extends Resource
## Resource that holds the saved data for a Gaea graph.


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
	NODE, ## A [GaeaNodeResource].
	FRAME, ## A [GaeaGraphFrame]
	NONE = -1 ## Returned by [method get_node_type] if no type is found.
}

## Current save version used for [GaeaGraphMigration].
const CURRENT_SAVE_VERSION := 5

## [GaeaLayer]s as seen in the Output node in the graph. Can be used
## to allow more than one [GaeaMaterial] in a single tile.
@export var layers: Array[GaeaLayer] = [GaeaLayer.new()] :
	set(value):
		layers = value
		layer_count_modified.emit()
		emit_changed()

@export_group("Debug")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "feature") var debug_enabled: bool = false
## Selection of what to print in the Output console during generation. See [enum Log].
@export_flags("Execute", "Traverse", "Data", "Args") var logging: int = Log.NONE

## The current save version, used for migrating checks.
@export_storage var save_version: int = -1
## List of all connections between nodes. They're saved with the format
## "from_node-from_port-to_node-to_port" (ex.: 1-0-2-1). That format
## can be converted into a connections dictionary using various methods in this class.[br]
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var _connections: Array[StringName] :
	get = get_raw_connections
## Saved data for each [GaeaNodeResource] such as position in the graph and changed arguments.
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
@export_storage var _node_data: Dictionary[int, Dictionary] :
	get = get_all_node_data
## List of parameters created with [GaeaNodeParameter].
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly can break your saved graph.
## Use [method set_parameter] instead.
@export_storage var _parameters: Dictionary[StringName, Variant] :
	get = get_parameter_list

#region Deprecated
## @deprecated: Kept for migration of old save data.
var connections: Array[Dictionary]
## @deprecated: Kept for migration of old save data.
var resource_uids: Array[String]
## @deprecated: Kept for migration of old save data.
var resources: Array[GaeaNodeResource]
## @deprecated: Kept for migration of old save data.
var node_data: Array[Dictionary]
## @deprecated: Kept for migration of old save data.
var parameters: Dictionary[StringName, Variant]
## @deprecated: Kept for migration of old save data.
var other: Dictionary
#endregion

## The graph's [member GraphEdit.scroll_offset]. Only saved
## in the current session.
var scroll_offset: Vector2 = Vector2(NAN, NAN)
## The graph's [member GraphEdit.zoom]. Only saved
## in the current session.
var zoom: float = 1.0
## Flag to know if the graph is correctly initialized.
var _initialized: bool = false
## Used during generation to keep track of node resources. GraphFrames are not in this list.
var _resources: Dictionary[int, GaeaNodeResource]
## Used during generation to keep track of the output node resource. Please use method [method get_output_node] to get this value.
# Dev note, you can't use a getter here because you will get an infinite loop with the add_node call.
var _output_resource: GaeaNodeOutput


# Kept for migration
func _init() -> void:
	resource_local_to_scene = false

	# For newly created resources set the latest save version
	if resource_path.is_empty():
		save_version = CURRENT_SAVE_VERSION
		add_node(GaeaNodeOutput.new(), Vector2.ZERO)


## This method need to be called after loading to make sure the graph is correctly loaded
func ensure_initialized() -> void:
	if _initialized:
		return
	_initialize()


func _initialize() -> void:
	#Data migration from previous version.
	save_version = other.get(&"save_version", save_version)
	if save_version != CURRENT_SAVE_VERSION:
		GaeaGraphMigration.migrate(self)

	_resources.clear()
	_output_resource = null
	var uniques = _get_unique_resources()
	for id in uniques.keys():
		_resources.set(id, uniques[id])

	for resource in get_nodes():
		resource.connections.clear()
		if resource is GaeaNodeOutput:
			_output_resource = resource

	if not is_instance_valid(_output_resource):
		add_node(GaeaNodeOutput.new(), Vector2.ZERO)

	var all_connections: Array[Dictionary] = get_all_connections()
	for idx in all_connections.size():
		var connection: Dictionary = all_connections[idx]
		var resource: GaeaNodeResource = get_node(connection.to_node)
		resource.connections.append(connection)

	notify_property_list_changed()

	_initialized = true


## Adds a new [param node] to the graph at [param position], identifiable with [param id].
## If [param id] is not passed, [method get_next_available_id] will be used. Returns the node's id.[br]
## Its data is saved in [member _node_data] and loaded by the panel.
func add_node(node: GaeaNodeResource, position: Vector2, id: int = get_next_available_id()) -> int:
	if node is GaeaNodeOutput:
		if is_instance_valid(_output_resource):
			push_error("Can't add second output node to this graph (%s)" % resource_path)
			return _output_resource.id
		_output_resource = node
	node.id = id
	_resources.set(id, node)
	_node_data.set(id,
	{
		&"type": NodeType.NODE,
		&"position": position,
		&"salt": randi(),
		&"uid": ResourceUID.id_to_text(
					ResourceLoader.get_resource_uid(node.get_script().get_path())
				)
	}.merged(node.get_custom_saved_data()))
	node.on_added_to_graph.call_deferred(self)
	emit_changed.call_deferred()
	return id


## Adds the specified node as in [method add_node], then sets its saved data to [param data].
func add_node_with_data(node: GaeaNodeResource, data: Dictionary, id: int = get_next_available_id()) -> int:
	add_node(node, data.get(&"position", Vector2.ZERO), id)
	set_node_data(id, data)
	if is_instance_valid(get_node(id)):
		get_node(id).load_save_data(data)
	return id


## Adds a new frame at [param position], identifiable with [param id].
## If [param id] is not passed, [method get_next_available_id] will be used. Returns the frame's id.[br]
## Its data is saved in [member _node_data].
func add_frame(position: Vector2, id: int = get_next_available_id()) -> int:
	_node_data.set(id,
	{
		&"type": NodeType.FRAME,
		&"position": position,
	})
	emit_changed()
	return id


## Adds the specified frame as in [method add_frame], then sets its saved data to [param data].
func add_frame_with_data(data: Dictionary, id: int = get_next_available_id()) -> int:
	_node_data.set(id, data)
	emit_changed()
	return id


## Removes the specified node.
func remove_node(id: int) -> void:
	for connection in get_node_connections(id):
		disconnect_nodes(
			connection.get("from_node"),
			connection.get("from_port"),
			connection.get("to_node"),
			connection.get("to_port")
		)
	_node_data.erase(id)
	_resources.erase(id)
	emit_changed()


## Pastes the nodes specified in [param copy] to the frame, offset so that the top-left node is
## in [param at_position].
func paste_nodes(copy: GaeaNodesCopy, at_position: Vector2) -> Array[int]:
	var offset: Vector2 = at_position - copy.get_origin()
	var id_mapping: Dictionary[int, int]
	var frames: Array[int]

	# First add the nodes.
	for id in copy.get_nodes_info():
		var copy_id: int = -1
		match copy.get_node_type(id):
			NodeType.NODE:
				copy_id = add_node_with_data(copy.get_node_resource(id), copy.get_node_data(id))
				set_node_salt(copy_id, randi())
			NodeType.FRAME:
				copy_id = add_frame_with_data(copy.get_node_data(id))
				frames.append(copy_id)
		set_node_position(copy_id, copy.get_node_position(id) + offset)
		id_mapping.set(id, copy_id)

	# Then attach any new frames to their relevant frame (if a frame and a node attached to it are copied).
	for frame_id in frames:
		var attached: Array = get_nodes_attached_to_frame(frame_id).duplicate()
		detach_all_nodes_from_frame(frame_id)

		for attached_id in attached:
			if id_mapping.has(attached_id):
				attach_node_to_frame(
					id_mapping.get(attached_id),
					frame_id
				)

	# This is done last so the nodes are attached to the right frame and connected to the right nodes.
	for connection in copy.get_connections():
		var from_node: int = connection.get(&"from_node", -1)
		var to_node: int = connection.get(&"to_node", -1)
		if id_mapping.has(from_node) and id_mapping.has(to_node):
			connect_nodes(
				id_mapping.get(connection.get(&"from_node")),
				connection.get(&"from_port"),
				id_mapping.get(connection.get(&"to_node")),
				connection.get(&"to_port")
			)
	emit_changed()
	return id_mapping.values()


## Sets the specified node's position in the graph to [param position].
func set_node_position(id: int, position: Vector2) -> void:
	if not _node_data.has(id):
		return

	set_node_data_value(id, &"position", position)


## Returns the specified node's position.
func get_node_position(id: int) -> Vector2:
	if not has_node(id) or not get_node_data(id).has(&"position"):
		push_error("Failed to get position of node, returning Vector2().")
		return Vector2()
	return get_node_data(id).get(&"position")


## Sets the specified node's salt.
func set_node_salt(id: int, salt: int) -> void:
	set_node_data_value(id, &"salt", salt)


## Returns the specified node's salt. Defaults to 0.
func get_node_salt(id: int) -> int:
	return get_node_data_value(id, &"salt", 0)


## Sets the specified node's argument of [param arg_name] to [param value].
func set_node_argument(id: int, arg_name: StringName, value: Variant) -> void:
	get_node_data(id).get_or_add(&"arguments", {}).set(arg_name, value)
	emit_changed()


## Returns the specified node's argument of [param arg_name], defaulting to [param default_value]
## if it doesn't have one.
func get_node_argument(id: int, arg_name: StringName, default_value: Variant = null) -> Variant:
	return get_node_argument_list(id).get(arg_name, default_value)


## Returns the specified node's argument list, a [Dictionary] where the keys are the argument names.
func get_node_argument_list(id: int) -> Dictionary:
	return get_node_data_value(id, &"arguments", {})


## Removes the specified argument from the specified node, meaning it will use the default value.
func remove_node_argument(id: int, arg_name: StringName) -> void:
	get_node_argument_list(id).erase(arg_name)
	emit_changed()


## Sets the specified node's enum value at [param enum_idx] to [param value]
## (and resizes the enums array if necessary).
func set_node_enum(id: int, enum_idx: int, value: int) -> void:
	var node_enums: Array = get_node_data(id).get_or_add(&"enums", [])
	if node_enums.size() <= enum_idx:
		node_enums.resize(enum_idx + 1)
	node_enums.set(enum_idx, value)
	emit_changed()


## Sets the specified node's saved data to [param value].[br]
## It's found under [member _node_data][[param id]][[param key]].
func set_node_data_value(id: int, key: StringName, value: Variant) -> void:
	get_node_data(id).set(key, value)
	emit_changed()


## Gets the specified node's saved data of [param key].[br]
## It's found under [member _node_data][[param id]][[param key]].
func get_node_data_value(id: int, key: StringName, default: Variant = null) -> Variant:
	return get_node_data(id).get(key, default)


## Attaches the specified node to the specified frame.[br]
## Returns an error if the node can't be attached (for example, if it's already attached to another frame).
func attach_node_to_frame(node_id: int, frame_id: int) -> Error:
	if node_id == frame_id:
		return FAILED

	if get_parent_frame(node_id) != -1:
		return FAILED

	var attached_array: Array = get_node_data(frame_id).get_or_add(&"attached", [] as Array[int])
	if not attached_array.has(node_id):
		attached_array.append(node_id)
	emit_changed()
	return OK


## Detaches the specified node from its parent frame.
func detach_node_from_frame(node_id: int) -> void:
	var frame_id: int = get_parent_frame(node_id)
	get_nodes_attached_to_frame(frame_id).erase(node_id)
	emit_changed()


## Detaches all nodes attached to the specified frame.
func detach_all_nodes_from_frame(frame_id: int) -> void:
	set_node_data_value(frame_id, &"attached", [])
	emit_changed()


## Returns all node ids attached to the specified frame.
func get_nodes_attached_to_frame(frame_id: int) -> Array:
	return get_node_data_value(frame_id, &"attached", [])


## Returns the id of the frame the specified node is attached to. If there is none,
## returns [code]-1[/code].
func get_parent_frame(node_id: int) -> int:
	var idx := _node_data.values().find_custom(
		func(data: Dictionary) -> bool:
			return data.get(&"attached", [] as Array[int]).has(node_id)
	)
	if idx == -1:
		return -1
	return _node_data.keys().get(idx)


## Returns the output node resource.
func get_output_node() -> GaeaNodeOutput:
	if not is_instance_valid(_output_resource):
		for resource in get_nodes():
			if resource is GaeaNodeOutput:
				_output_resource = resource

	if not is_instance_valid(_output_resource):
		add_node(GaeaNodeOutput.new(), Vector2.ZERO)

	return _output_resource


## Returns the node with specified [param id]. Using this method with a frame ID will return null.
func get_node(id: int) -> GaeaNodeResource:
	return _resources.get(id)


## Returns [code]true[/code] if the node or frame exists (which means, [member _node_data] has that [param id]).
func has_node(id: int) -> bool:
	return _node_data.has(id)


## Returns a list of all nodes in the graph (excluding frames).
func get_nodes() -> Array[GaeaNodeResource]:
	return _resources.values()


## Returns the specified node's [enum NodeType].
func get_node_type(id: int) -> NodeType:
	return get_node_data(id).get(&"type", NodeType.NONE)


## Sets the saved data for the specified node to [param data].[br]
## [br][color=yellow][b]Warning:[/b][/color] Setting this directly could break your graph.
func set_node_data(id: int, data: Dictionary) -> void:
	_node_data.set(id, data)
	emit_changed()


## Returns the saved data for the specified node.
func get_node_data(id: int) -> Dictionary:
	return _node_data.get_or_add(id, {})


## Returns all node identifiers.
func get_ids() -> Array[int]:
	return _node_data.keys()


## Returns all node data.
func get_all_node_data() -> Dictionary[int, Dictionary]:
	return _node_data


## Returns an available id.
func get_next_available_id() -> int:
	var ids := get_ids()
	var next_id := ids.size()
	while next_id in ids:
		next_id += 1
	return next_id


## Attempts to connect the specified nodes and ports. If the connection already exists or is invalid,
## returns an error.[br]
func connect_nodes(from_id: int, from_port: int, to_id: int, to_port: int) -> Error:
	if has_connection(from_id, from_port, to_id, to_port):
		return ERR_ALREADY_EXISTS

	var from_node: GaeaNodeResource = get_node(from_id)
	var output: StringName = from_node.connection_idx_to_output(from_port)
	if output.is_empty():
		return ERR_CANT_CONNECT
	var from_type: GaeaValue.Type = from_node.get_output_port_type(output)

	var to_node: GaeaNodeResource = get_node(to_id)
	var argument: StringName = to_node.connection_idx_to_argument(to_port)
	if argument.is_empty():
		return ERR_CANT_CONNECT
	var to_type: GaeaValue.Type = to_node.get_argument_type(argument)

	if not GaeaValue.is_valid_connection(from_type, to_type):
		return ERR_CANT_CONNECT

	to_node.connections.append({
		"from_node": from_id,
		"from_port": from_port,
		"to_node": to_id,
		"to_port": to_port
	})
	_connections.append(&"%s-%s-%s-%s" % [from_id, from_port, to_id, to_port])
	emit_changed()
	return OK


## Forcefully connects the specified nodes and ports.
## [br][color=yellow][b]Warning:[/b][/color] This connection could be invalid, and it won't work correctly if so.
func force_connect_nodes(from_id: int, from_port: int, to_id: int, to_port: int) -> void:
	var to_node: GaeaNodeResource = get_node(to_id)
	if is_instance_valid(to_node):
		to_node.connections.append({
			"from_node": from_id,
			"from_port": from_port,
			"to_node": to_id,
			"to_port": to_port
		})
	_connections.append(&"%s-%s-%s-%s" % [from_id, from_port, to_id, to_port])
	emit_changed()


## Disconnects the specified nodes and ports, if the connection exists.
func disconnect_nodes(from_id: int, from_port: int, to_id: int, to_port: int) -> void:
	var to_node: GaeaNodeResource = get_node(to_id)
	if is_instance_valid(to_node):
		for idx in range(to_node.connections.size() - 1, -1, -1):
			var connection = to_node.connections[idx]
			if (
				connection.get("from_node") == from_id
				and connection.get("from_port") == from_port
				and connection.get("to_node") == to_id
				and connection.get("to_port") == to_port
			):
				to_node.connections.remove_at(idx)
	_connections.erase(&"%s-%s-%s-%s" % [from_id, from_port, to_id, to_port])
	emit_changed()


## Returns the saved connection (as a string) converted into a connection dictionary.
func get_connection_dictionary(connection_string: StringName) -> Dictionary[String, int]:
	var split_string := connection_string.split("-")
	return {
		"from_node": int(split_string[0]),
		"from_port": int(split_string[1]),
		"to_node": int(split_string[2]),
		"to_port": int(split_string[3])
	}


## Returns all connections in the graph as dictionaries.
func get_all_connections() -> Array[Dictionary]:
	var all_connections: Array[Dictionary]
	for connection_string in _connections:
		all_connections.append(get_connection_dictionary(connection_string))
	return all_connections


## Returns all connections in the graph in the form "from_node-from_port-to_node-to_port" (ex.: 1-0-2-1)
func get_raw_connections() -> Array[StringName]:
	return _connections


## Returns all connections to and from the specified node as dictionaries.
func get_node_connections(id: int) -> Array[Dictionary]:
	return get_connections_to(id) + get_connections_from(id)


## Returns all connections to the specified node as dictionaries.
## If [param port] is positive, it only returns connections to that port.
func get_connections_to(id: int, port: int = -1) -> Array[Dictionary]:
	return get_all_connections().filter(
		func(value: Dictionary):
			return (value.get("to_node", NAN) == id and (port < 0 or port == value.get("to_port", -1)))
	) as Array[Dictionary]


## Returns all connections from the specified node as dictionaries.
## If [param port] is positive, it only returns connections from that port.
func get_connections_from(id: int, port: int = -1) -> Array[Dictionary]:
	return get_all_connections().filter(
		func(value: Dictionary):
				return (value.get("from_node", NAN) == id and (port < 0 or port == value.get("from_port", -1)))
	) as Array[Dictionary]


## Returns [code]true[/code] if the specified connection exists.
func has_connection(from_id: int, from_port: int, to_id: int, to_port: int) -> bool:
	return _connections.has(&"%s-%s-%s-%s" % [from_id, from_port, to_id, to_port])


## Returns the specified parameter's value.
func get_parameter(name: StringName) -> Variant:
	return _get(name)


## Sets the specified parameter from [member _parameters] to [param value].
func set_parameter(name: StringName, value: Variant) -> void:
	_set(name, value)
	emit_changed()


## Returns [code]true[/code] if a parameter of that name exists.
func has_parameter(name: StringName) -> bool:
	return _parameters.has(name)


## Returns the specified parameter's info dictionary.
## Follows the format in [method Object.get_property_list].[br]
## If it doesn't exist, returns an empty dictionary.
func get_parameter_dictionary(name: StringName) -> Dictionary:
	return _parameters.get(name, {})


## Returns [member _parameters].
func get_parameter_list() -> Dictionary:
	return _parameters


## Adds [param parameter] to [member _parameters] with [param name]. Should match
## the format in [method Object.get_property_list].[br]
## Returns an error if a parameter with that name already exists.
func add_parameter(name: StringName, parameter: Dictionary) -> Error:
	if has_parameter(name):
		return ERR_ALREADY_EXISTS

	_parameters[name] = parameter
	notify_property_list_changed()
	emit_changed()
	return OK


## Renames the specified parameter from [param old_name] to [param new_name].[br]
## If a parameter of [param new_name] already exists, fails and returns an error.
func rename_parameter(old_name: StringName, new_name: StringName) -> Error:
	var dictionary := get_parameter_dictionary(old_name)
	dictionary.name = new_name
	var error := add_parameter(new_name, dictionary)
	if error != OK:
		return error

	remove_parameter(old_name)
	notify_property_list_changed()
	emit_changed()
	return OK


## Removes the parameter of [param name].
func remove_parameter(name: StringName) -> void:
	_parameters.erase(name)
	notify_property_list_changed()
	emit_changed()


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


func _get_unique_resources() -> Dictionary[Variant, GaeaNodeResource]:
	var uniques: Dictionary[Variant, GaeaNodeResource] = {}
	for id in _node_data.keys():
		var base_uid: String = get_node_data(id).get(&"uid", "")
		if base_uid.is_empty():
			continue
		var data: Dictionary = _node_data.get(id, {})
		var resource: GaeaNodeResource = load(base_uid).new()
		if not resource is GaeaNodeResource:
			push_error("Something went wrong, the resource at %s is not a GaeaNodeResource" % base_uid)
			return uniques
		resource._load_save_data(data)
		uniques.set(id, resource)
	return uniques
