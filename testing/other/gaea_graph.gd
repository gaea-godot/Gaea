extends GdUnitTestSuite


var graph: GaeaGraph


func test_graph_creation() -> void:
	graph = GaeaGraph.new()
	assert_object(graph)\
		.override_failure_message("New GaeaGraph is [code]null[/code].")\
		.is_not_null()\
		.override_failure_message("Attempt at creating new graph doesn't inherit GaeaGraph.")\
		.is_inheriting(GaeaGraph)


func test_add_node() -> void:
	graph.add_node(GaeaNodeSamplesOp.new(), Vector2.ZERO, 0)
	assert_array(graph.get_nodes())\
		.override_failure_message("Graph's node resources list is empty after adding node.")\
		.is_not_empty()

	assert_bool(graph.has_node(0))\
		.override_failure_message("Graph's [code]has_node[/code] returns [code]false[/code] on added node.")\
		.is_true()

	if is_failure():
		return

	var _node_data := graph.get_node_data(0)
	assert_dict(_node_data)\
		.override_failure_message("Added node's data is empty.")\
		.is_not_empty()\
		.override_failure_message("Added node's position is unexpected.")\
		.append_failure_message("Current Position: %s\nExpected: %s" % [_node_data[&"position"], Vector2.ZERO])\
		.contains_key_value(&"position", Vector2.ZERO)

	if is_failure():
		return

	graph.add_node(GaeaNodeTextureSampler.new(), Vector2(-50, 0), graph.get_next_available_id())
	var _nodes := graph.get_nodes()
	assert_array(_nodes)\
		.override_failure_message("Graph's node resources list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_nodes.size(), 2])\
		.has_size(2)


func test_connection() -> void:
	graph.connect_nodes(1, 0, 0, 0)
	graph.connect_nodes(1, 1, 0, 1)

	assert_bool(graph.has_connection(1, 0, 0, 0))\
		.override_failure_message("Graph's [code]has_connection()[/code] returned [code]false[/code] on connection that should exist.")\
		.is_true()

	var _connections := graph.get_all_connections()
	assert_array(_connections)\
		.override_failure_message("Graph's connections list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_connections.size(), 2])\
		.has_size(2)

	if is_failure():
		return

	var _connections_to := graph.get_connections_to(0)
	var _connections_from := graph.get_connections_from(1)

	assert_array(_connections_to)\
		.override_failure_message("List of connections to node of id 0 has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_connections_to.size(), 2])\
		.has_size(2)

	assert_array(_connections_from)\
		.override_failure_message("List of connections from node of id 1 has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_connections_from.size(), 2])\
		.has_size(2)

	if is_failure():
		return


func test_disconnection() -> void:
	graph.disconnect_nodes(1, 0, 0, 0)

	assert_bool(graph.has_connection(1, 0, 0, 0))\
		.override_failure_message("Graph's [code]has_connection()[/code] returned [code]true[/code] on connection that shouldn't exist.")\
		.is_false()

	var _connections := graph.get_all_connections()
	assert_array(_connections)\
		.override_failure_message("Graph's connections list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_connections.size(), 1])\
		.has_size(1)


func test_frame() -> void:
	graph.add_frame(Vector2.ZERO, 2)

	var _frame_data := graph.get_node_data(2)
	assert_dict(graph.get_node_data(2))\
		.override_failure_message("Added frame's data is empty.")\
		.is_not_empty()\
		.override_failure_message("Added frame's position is unexpected.")\
		.append_failure_message("Current Position: %s\nExpected: %s" % [_frame_data[&"position"], Vector2.ZERO])\
		.contains_key_value(&"position", Vector2.ZERO)

	if is_failure():
		return

	graph.attach_node_to_frame(0, 2)
	var _attached: Array[int] = graph.get_node_data_value(2, &"attached", [])
	assert_array(_attached)\
		.override_failure_message("Frame's attached list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_attached.size(), 1])\
		.has_size(1)\
		.override_failure_message("Frame's attached list doesn't contain the attached node.")\
		.append_failure_message("Attached: %s" % _attached)\
		.is_equal([0] as Array[int])

	if is_failure():
		return

	graph.detach_node_from_frame(0)
	_attached = graph.get_node_data_value(2, &"attached", [9])
	assert_array(_attached)\
		.override_failure_message("Frame's attached list is not empty after detaching node.")\
		.is_empty()


func test_remove_node() -> void:
	graph.remove_node(1)

	assert_bool(graph.has_node(1))\
		.override_failure_message("Graph's [code]has_node[/code] returns [code]true[/code] on removed node.")\
		.is_false()

	var _nodes := graph.get_nodes()
	assert_array(_nodes)\
		.override_failure_message("Graph's node resources list has unexpected size.")\
		.append_failure_message("Current: %s\nExpected: %s" % [_nodes.size(), 1])\
		.has_size(1)
