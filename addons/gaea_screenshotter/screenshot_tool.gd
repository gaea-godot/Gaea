@tool
extends Control


@onready var tree: Tree = %Tree
@onready var sub_viewport: SubViewport = %SubViewport
@onready var open_folder_button: Button = %OpenFolderButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog



func _ready() -> void:
	if not is_part_of_edited_scene():
		open_folder_button.icon = (
			EditorInterface.get_base_control().get_theme_icon(&"Folder", &"EditorIcons")
		)

		var dir: DirAccess = DirAccess.open("user://")
		if not dir.dir_exists("node_images"):
			dir.make_dir("node_images")


func _capture_resource(node: GaeaNodeResource) -> void:
	var instantiated: GaeaGraphNode = node.get_scene().instantiate()
	if node.get_scene_script() != null:
		instantiated.set_script(node.get_scene_script())
	instantiated.resource = node
	instantiated.generator = $GaeaGenerator

	var file_name: String = node.get_title()
	if node.get_tree_name() != file_name:
		file_name += node.get_tree_name()

	var parenthesis_start := file_name.find("(")
	if parenthesis_start != -1:
		file_name = file_name.erase(parenthesis_start, 99)

	await _take_image(instantiated, file_name.to_pascal_case())


func _capture_frame() -> void:
	var frame: GaeaGraphFrame = GaeaGraphFrame.new()
	await _take_image(frame, "Frame")



func _take_image(node: GraphElement, file_name: String) -> void:
	sub_viewport.add_child(node)

	await get_tree().create_timer(0.01).timeout

	var path: String = "user://node_images/%s.png" % file_name

	sub_viewport.size = node.size + Vector2(32, 32)
	node.position = Vector2(16, 16)

	await get_tree().create_timer(0.01).timeout

	var image := sub_viewport.get_viewport().get_texture().get_image()
	image.save_png(path)

	await get_tree().process_frame

	node.queue_free()
	sub_viewport.size = Vector2.ONE


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_capture_resource(resource)


func _on_capture_all_button_pressed() -> void:
	confirmation_dialog.popup_centered()



func _capture_all_children(tree_item: TreeItem) -> void:
	for item in tree_item.get_children():
		if item.get_metadata(0) is GaeaNodeResource:
			await _capture_resource(item.get_metadata(0))
		elif item.get_metadata(0) is StringName:
			await _capture_frame()
		elif item.get_metadata(0) == null:
			await _capture_all_children(item)


func _on_open_folder_button_pressed() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://node_images/"))


func _on_confirmation_dialog_confirmed() -> void:
	_capture_all_children(tree.get_root())
	_capture_resource(GaeaNodeOutput.new())


func _on_tree_special_node_selected_for_creation(id: StringName) -> void:
	if id == &"frame":
		_capture_frame()
