extends GdUnitTestSuite


const NODES_PATH := "res://addons/gaea/graph/graph_nodes/root/"

var nodes_in_root: Array[GaeaNodeResource]




func _get_nodes_in_folder(folder_path: String) -> Array[GaeaNodeResource]:
	var dir := DirAccess.open(folder_path)
	var array: Array[GaeaNodeResource] = []

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".gd"):
			file_name = dir.get_next()
			continue

		var file_path = folder_path + file_name
		if dir.current_is_dir():
			array.append_array(_get_nodes_in_folder(file_path + "/"))

		if file_name.ends_with(".gd"):
			var script := load(file_path)
			assert_bool(script.can_instantiate())\
				.override_failure_message("Script at [b]%s[/b] couldn't compile." % _get_node_path(script))\
				.is_true()

			assert_bool(script.is_tool())\
				.override_failure_message("Script at [b]%s[/b] isn't a tool script." % _get_node_path(script))\
				.is_true()

			if script is GDScript and script.is_tool():
				var is_valid_node_resource := false
				var base_script: GDScript = script
				while is_instance_valid(base_script):
					base_script = base_script.get_base_script()
					if base_script == GaeaNodeResource:
						is_valid_node_resource = true
						break
				if is_valid_node_resource:
					var resource: GaeaNodeResource = script.new()
					if resource.is_available():
						for item in resource.get_tree_items():
							array.append(item)
		file_name = dir.get_next()

	return array


func _get_node_path(object: Object) -> String:
	if object is Script:
		return object.resource_path.trim_prefix(NODES_PATH)
	return object.get_script().resource_path.trim_prefix(NODES_PATH)


## Tests that all nodes' scripts can be instantiated and are tool.
## Also populates the [member nodes_in_root] array.
func test_script_compilation() -> void:
	nodes_in_root = _get_nodes_in_folder(NODES_PATH)


## Tests that no `GaeaNodeResource`s in the root push the `_get_arguments_list` warning.
func test_is_arguments_list_overriden() -> void:
	for node in nodes_in_root:
		await assert_failure_await(func(): assert_error(node.get_arguments_list)\
			.is_push_warning(("_get_arguments_list wasn't overridden in %s, node will have no arguments." % node.get_script().resource_path))
			)

## Tests that no `GaeaNodeResource`s in the root are unnamed.
func test_for_untitled() -> void:
	for node in nodes_in_root:
		await assert_str(node.get_title())\
			.override_failure_message("Node at [b]%s[/b] is unnamed" % _get_node_path(node))\
			.is_not_equal("Unnamed").is_not_equal("")

## Tests that all nodes have outputs.
func test_has_outputs() -> void:
	for node in nodes_in_root:
		assert_array(node.get_output_ports_list())\
			.override_failure_message("Node at [b]%s[/b] has no outputs." % _get_node_path(node))\
			.is_not_empty()


## Tests that no `GaeaNodeResource`s in the root have an invalid or null type.
func test_null_type() -> void:
	for node in nodes_in_root:
		await assert_int(node.get_type())\
			.override_failure_message("Type of node at [b]%s[/b] is not a valid type." % _get_node_path(node))\
			.is_in(GaeaValue.Type.values())\
			.override_failure_message("Type of node at [b]%s[/b] is null." % _get_node_path(node))\
			.is_not_equal(GaeaValue.Type.NULL)
		for argument in node.get_arguments_list():
			await assert_int(node.get_argument_type(argument))\
				.override_failure_message("Type of argument [b]%s[/b] is invalid." % argument)\
				.append_failure_message("Node at [b]%s[/b]." % _get_node_path(node))\
				.is_in(GaeaValue.Type.values())\
				.override_failure_message("Type of argument [b]%s[/b] is null." % argument)\
				.append_failure_message("Node at [b]%s[/b]." % _get_node_path(node))\
				.is_not_equal(GaeaValue.Type.NULL)
		for output in node.get_output_ports_list():
			await assert_int(node.get_output_port_type(output))\
				.override_failure_message("Type of output [b]%s[/b] is invalid." % output)\
				.append_failure_message("Node at [b]%s[/b]." % _get_node_path(node))\
				.is_in(GaeaValue.Type.values())\
				.override_failure_message("Type of output [b]%s[/b] is null." % output)\
				.append_failure_message("Node at [b]%s[/b]." % _get_node_path(node))\
				.is_not_equal(GaeaValue.Type.NULL)


## Check that all nodes have descriptions.
func test_has_description() -> void:
	for node in nodes_in_root:
		await assert_str(node.get_description())\
			.override_failure_message("Description of node at [b]%s[/b] is empty." % _get_node_path(node))\
			.is_not_empty()


## Check that all nodes have a valid scene.
func test_node_scene() -> void:
	for node in nodes_in_root:
		await assert_object(node.get_scene())\
			.override_failure_message("_get_scene at [b]%s[/b] returns null." % _get_node_path(node))\
			.is_not_null()\
			.override_failure_message("_get_scene at [b]%s[/b] isn't a PackedScene." % _get_node_path(node))\
			.is_instanceof(PackedScene)
