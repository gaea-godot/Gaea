class_name GaeaNodesCopy
extends RefCounted
## An object that holds data to be pasted into a GaeaGraph.


var _nodes: Dictionary[int, Dictionary] : get = get_nodes_info
var _connections: Array[Dictionary] : get = get_connections
var _origin: Vector2 = Vector2(INF, INF) : get = get_origin


func _init(origin = Vector2(INF, INF)) -> void:
	_origin = origin


func get_nodes_info() -> Dictionary[int, Dictionary]:
	return _nodes


func get_connections() -> Array[Dictionary]:
	return _connections


func get_origin() -> Vector2:
	return _origin


func add_node(current_id: int, resource: GaeaNodeResource, position: Vector2, data: Dictionary) -> void:
	_origin = _origin.min(position)
	_nodes.set(current_id,
		{
			&"type": GaeaGraph.NodeType.NODE,
			&"resource": resource,
			&"position": position,
			&"data": data
		}
	)


func add_frame(current_id: int, position: Vector2, data: Dictionary) -> void:
	_origin = _origin.min(position)
	_nodes.set(current_id,
		{
			&"type": GaeaGraph.NodeType.FRAME,
			&"position": position,
			&"data": data
		}
	)


func add_connections(connections: Array[Dictionary]) -> void:
	for connection in connections:
		add_connection(connection)


func add_connection(connection: Dictionary) -> void:
	if not _connections.has(connection):
		_connections.append(connection)


func get_node_type(id: int) -> GaeaGraph.NodeType:
	return _nodes.get(id, {}).get(&"type", GaeaGraph.NodeType.NONE)


func get_node_resource(id: int) -> GaeaNodeResource:
	return _nodes.get(id, {}).get(&"resource")


func get_node_data(id: int) -> Dictionary:
	return _nodes.get(id, {}).get(&"data", {})


func get_node_position(id: int) -> Vector2:
	return _nodes.get(id, {}).get(&"position", get_origin())


func serialize() -> String:
	var nodes_data: Dictionary[int, Dictionary] = {}
	var connections: Array[Array] = []

	for node_id: int in _nodes.keys():
		var node_properties: Dictionary = _nodes.get(node_id, {})
		nodes_data.set(node_id, {
			"type": node_properties.get(&"type"),
			"data": node_properties.get(&"data"),
		})

	for connection in _connections:
		if nodes_data.has(connection.get("from_node")) and nodes_data.has(connection.get("to_node")):
			connections.append([
				connection.get("from_node"),
				connection.get("from_port"),
				connection.get("to_node"),
				connection.get("to_port"),
			])

	var data: Dictionary = { "origin": _origin, "nodes": nodes_data }
	if connections.size() > 0:
		data.set("connections", connections)

	return var_to_str(data)


## Deserialize a previously serialized GaeaNodesCopy,
## return a GaeaNodesCopy object or a string as error message.
static func deserialize(serialized: String) -> Variant:
	if serialized.contains("Object("):
		return "Paste failed. The clipboard data includes a disallowed serialized object."

	var deserialized_data = str_to_var(serialized)
	if (
		not deserialized_data is Dictionary
		or not deserialized_data.get("origin") is Vector2
		or not deserialized_data.get("nodes") is Dictionary
		or not deserialized_data.get("connections", []) is Array
	):
		return "Invalid data provided: the data could not be parsed."

	var origin: Vector2 = deserialized_data.get("origin")
	var deserialized: GaeaNodesCopy = GaeaNodesCopy.new(origin)

	var nodes_data: Dictionary = deserialized_data.get("nodes")
	for node_id in nodes_data.keys():
		var node_data = nodes_data.get(node_id)
		if not node_data.get("data") is Dictionary:
			return "Invalid data provided: the data of node %d could not be parsed." % node_id
		var data: Dictionary = node_data.get("data")
		match node_data.get("type"):
			GaeaGraph.NodeType.NODE:
				var uid: String = data.get(&"uid")
				var resource: GaeaNodeResource
				if GaeaNodeResource.is_valid_node_resource(uid).is_empty():
					resource = load(uid).new()
				else:
					resource = GaeaNodeInvalidScript.new()
				resource.load_save_data(data)
				deserialized.add_node(node_id, resource, data.get(&"position", origin), data)
			GaeaGraph.NodeType.FRAME:
				deserialized.add_frame(node_id, data.get(&"position", origin), data)
			_:
				return "Invalid data provided: the data could not be parsed"

	for connection: Array in deserialized_data.get("connections", []):
		deserialized.add_connection({
			"from_node": connection[0],
			"from_port": connection[1],
			"to_node": connection[2],
			"to_port": connection[3],
		})
	return deserialized
