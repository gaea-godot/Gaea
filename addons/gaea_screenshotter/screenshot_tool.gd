@tool
extends Control


@onready var tree: Tree = %Tree
@onready var sub_viewport: SubViewport = %SubViewport


func _capture(node: GaeaNodeResource) -> void:
	var instantiated: GaeaGraphNode = node.get_scene().instantiate()
	if node.get_scene_script() != null:
		instantiated.set_script(node.get_scene_script())
	instantiated.resource = node
	instantiated.generator = $GaeaGenerator

	sub_viewport.add_child(instantiated)

	await get_tree().create_timer(0.01).timeout
	var file_name: String = node.get_title()
	if node.get_tree_name() != file_name:
		file_name += node.get_tree_name()

	var parenthesis_start := file_name.find("(")
	if parenthesis_start != -1:
		file_name = file_name.erase(parenthesis_start, 99)


	var path: String = "user://" + file_name.to_pascal_case()

	sub_viewport.size = instantiated.size + Vector2(32, 32)
	instantiated.position = Vector2(16, 16)

	await get_tree().create_timer(0.01).timeout

	var image := sub_viewport.get_viewport().get_texture().get_image()
	image.save_png(path)

	await get_tree().process_frame

	instantiated.queue_free()
	sub_viewport.size = Vector2.ONE
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(path))


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_capture(resource)


func _on_capture_all_button_pressed() -> void:
	_capture_all_children(tree.get_root())


func _capture_all_children(tree_item: TreeItem) -> void:
	for item in tree_item.get_children():
		if item.get_metadata(0) is GaeaNodeResource:
			await _capture(item.get_metadata(0))
		elif item.get_metadata(0) == null:
			await _capture_all_children(item)
