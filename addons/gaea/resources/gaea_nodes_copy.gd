class_name GaeaNodesCopy
extends RefCounted
## An object that holds data to be pasted into a GaeaGraph.


var _nodes: Dictionary[int, Dictionary] : get = get_nodes_info
var _connections: Array[Dictionary] : get = get_connections
var _origin: Vector2 = Vector2(INF, INF) : get = get_origin


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
	_connections.append_array(connections)


func get_node_type(id: int) -> GaeaGraph.NodeType:
	return _nodes.get(id, {}).get(&"type", GaeaGraph.NodeType.NONE)


func get_node_resource(id: int) -> GaeaNodeResource:
	return _nodes.get(id, {}).get(&"resource")


func get_node_data(id: int) -> Dictionary:
	return _nodes.get(id, {}).get(&"data", {})


func get_node_position(id: int) -> Vector2:
	return _nodes.get(id, {}).get(&"position", get_origin())
