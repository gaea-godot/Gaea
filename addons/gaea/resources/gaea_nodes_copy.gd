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


func serialize() -> PackedByteArray:
	var nodes_data: Dictionary[int, Array] = {}
	var connections: PackedInt32Array = PackedInt32Array([])

	for node_id: int in _nodes.keys():
		var node_properties: Dictionary = _nodes.get(node_id, {})
		nodes_data.set(node_id, [
			node_properties.get(&"type"),
			node_properties.get(&"data"),
		])

	for connection in _connections:
		if nodes_data.has(connection.from_node) and nodes_data.has(connection.to_node):
			connections.append_array([
				connection.get("from_node"),
				connection.get("from_port"),
				connection.get("to_node"),
				connection.get("to_port"),
			])

	var uncompressed: PackedByteArray = var_to_bytes([_origin, nodes_data, connections])
	var compressed: PackedByteArray = PackedByteArray("GAEAvssc".to_utf8_buffer())
	compressed.encode_u8(4, 1) # Compressed version
	compressed.encode_u16(5, uncompressed.size())
	compressed.encode_u8(7, FileAccess.CompressionMode.COMPRESSION_DEFLATE)
	compressed.append_array(uncompressed.compress(FileAccess.CompressionMode.COMPRESSION_DEFLATE))

	return compressed


## Deserialize a previously serialized GaeaNodesCopy,
## return a GaeaNodesCopy object or a string as error message.
static func deserialize(serialized: PackedByteArray) -> Variant:
	if serialized.slice(0, 4).get_string_from_utf8() != "GAEA":
		return "Invalid data provided: the GAEA prefix is missing."

	var version = serialized.decode_u8(4)
	if version != 1:
		return "Invalid data provided: the version %d is unknown." % version

	var uncompressed_size: int = serialized.decode_u16(5)
	var compression_mode: int = serialized.decode_u8(7)
	var uncompressed: PackedByteArray = serialized.slice(8, serialized.size()).decompress(uncompressed_size, compression_mode)
	var data = bytes_to_var(uncompressed)

	if data.size() != 3 or not data[0] is Vector2 or not data[1] is Dictionary or not data[2] is PackedInt32Array:
		return "Invalid data provided: the data could not be parsed"

	var origin: Vector2 = data[0]
	var deserialized: GaeaNodesCopy = GaeaNodesCopy.new(origin)

	var nodes_data: Dictionary = data[1]
	for node_id in nodes_data.keys():
		var node_data = nodes_data.get(node_id)
		if typeof(node_id) != TYPE_INT or typeof(node_data) != TYPE_ARRAY or not node_data[1] is Dictionary:
			return "Invalid data provided: the data could not be parsed"
		match node_data[0]:
			GaeaGraph.NodeType.NODE:
				var uid: String = node_data[1].get(&"uid")
				var resource: GaeaNodeResource
				if GaeaNodeResource.is_valid_node_resource(uid).is_empty():
					resource = load(uid).new()
				else:
					resource = GaeaNodeInvalidScript.new()
				resource.load_save_data(node_data[1])
				deserialized.add_node(node_id, resource, node_data[1].get(&"position", origin), node_data[1])
			GaeaGraph.NodeType.FRAME:
				deserialized.add_frame(node_id, node_data[1].get(&"position", origin), node_data[1])
			_:
				return "Invalid data provided: the data could not be parsed"

	var connections: PackedInt32Array = data[2]
	@warning_ignore("integer_division")
	for connection_id in range(0, connections.size() / 4):
		deserialized.add_connection({
			"from_node": connections[connection_id * 4],
			"from_port": connections[connection_id * 4 + 1],
			"to_node": connections[connection_id * 4 + 2],
			"to_port": connections[connection_id * 4 + 3]
		})
	return deserialized
