@tool
class_name GaeaEditorPlugin
extends EditorPlugin


const InspectorPlugin = preload("uid://bpg2cpobusnnl")

var _container: MarginContainer
var _panel: GaeaPanel
var _panel_button: Button
var _editor_selection: EditorSelection
var _inspector_plugin: EditorInspectorPlugin
var _custom_project_settings: GaeaProjectSettings


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_editor_selection = EditorInterface.get_selection()
		_editor_selection.selection_changed.connect(_on_selection_changed)

		_container = MarginContainer.new()
		_panel = GaeaPanel.instantiate()
		_panel.plugin = self
		_container.add_child(_panel)
		_panel_button = add_control_to_bottom_panel(_container, "Gaea")
		_panel_button.show()

		_inspector_plugin = InspectorPlugin.new()
		add_inspector_plugin(_inspector_plugin)

		GaeaEditorSettings.new().add_settings()
		_custom_project_settings = GaeaProjectSettings.new()
		_custom_project_settings.add_settings()

		resource_saved.connect(_on_resource_saved)

		EditorInterface.get_file_system_dock().resource_removed.connect(_on_resource_removed)
		EditorInterface.get_file_system_dock().file_removed.connect(_on_file_removed)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		_panel.graph_edit.unpopulate()
		remove_inspector_plugin(_inspector_plugin)
		remove_control_from_bottom_panel(_container)
		_container.queue_free()


func _disable_plugin() -> void:
	if Engine.is_editor_hint():
		_custom_project_settings.remove_settings()


func _get_unsaved_status(_for_scene: String) -> String:
	if not _for_scene.is_empty():
		return ""

	var string: String = "Save changes to the following GaeaGraphs before continuing?"
	var found_unsaved: bool = false
	for edited_graph: GaeaFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.is_unsaved():
			found_unsaved = true
			string += "\n%s" % edited_graph.get_graph().resource_path.get_file()

	if found_unsaved:
		return string
	return ""


func _save_external_data() -> void:
	for edited_graph: GaeaFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.is_unsaved():
			ResourceSaver.save(edited_graph.get_graph())
			edited_graph.set_dirty(false)


func _on_selection_changed() -> void:
	if Engine.is_editor_hint():
		var selected: Array[Node] = _editor_selection.get_selected_nodes()
		if selected.size() == 1 and selected.front() is GaeaGenerator:
			_edit(selected.front().graph)


func _handles(object: Object) -> bool:
	return object is GaeaGraph


func _edit(object: Object) -> void:
	if is_instance_valid(object) and object is GaeaGraph:
		if object.resource_path.is_empty():
			return

		make_bottom_panel_item_visible(_container)
		if _panel.graph_edit.graph == object:
			return

		_panel.file_list.open_file(object)


func _on_resource_saved(resource: Resource) -> void:
	if resource is not GaeaGraph:
		return

	for edited_graph: GaeaFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.get_graph() == resource:
			edited_graph.set_dirty(false)


func _on_file_removed(file: String) -> void:
	if file.get_extension() not in ["tscn", "scn"]:
		return

	for edited_graph: GaeaFileList.EditedGraph in _panel.file_list.edited_graphs:
		if not edited_graph.get_graph().is_built_in():
			continue

		if edited_graph.get_graph().resource_path.get_slice("::", 0) == file:
			_panel.file_list.close_file(edited_graph.get_graph())


func _on_resource_removed(resource: Resource) -> void:
	if resource is GaeaGraph:
		_panel.file_list.close_file(resource)
