extends GdUnitTestSuite


var nodes_in_root: Array[GaeaNodeResource]


func before() -> void:
	nodes_in_root = _get_nodes_in_folder("res://addons/gaea/graph/graph_nodes/root/")


func _get_nodes_in_folder(folder_path: String) -> Array[GaeaNodeResource]:
	var dir := DirAccess.open(folder_path)
	var array: Array[GaeaNodeResource]

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
			if script is GDScript:
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


## Tests that no `GaeaNodeResource`s in the root push the `_get_arguments_list` warning.
func test_node_warnings() -> void:
	for node in nodes_in_root:
		await assert_failure_await(func(): assert_error(node.get_arguments_list)\
			.is_push_warning(("_get_arguments_list wasn't overridden in %s, node will have no arguments." % node.get_script().resource_path))
			)

## Tests that no `GaeaNodeResource`s in the root are unnamed.
func test_are_untitled() -> void:
	for node in nodes_in_root:
		await assert_str(node.get_title()).is_not_equal("Unnamed")\
			.override_failure_message("Node at %s is unnamed" % node.get_script().resource_path)
