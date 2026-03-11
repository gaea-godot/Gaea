@tool
class_name GaeaEditorPlugin
extends EditorPlugin

const InspectorPlugin = preload("uid://bpg2cpobusnnl")

var _panel: GaeaEditorPanel
var _dock: EditorDock
var _editor_selection: EditorSelection
var _inspector_plugin: EditorInspectorPlugin
var _export_plugin: GaeaEditorExportPlugin


func _enter_tree() -> void:
	assert(Engine.is_editor_hint(), "The GaeaEditorPlugin should be used only in editor.")
	_editor_selection = EditorInterface.get_selection()
	_editor_selection.selection_changed.connect(_on_selection_changed)

	_panel = GaeaEditorPanel.instantiate()
	_panel.plugin = self

	_dock = EditorDock.new()
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_FLOATING | EditorDock.DOCK_LAYOUT_HORIZONTAL
	_dock.title = "Gaea"
	_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	_dock.add_child(_panel)
	add_dock(_dock)

	_inspector_plugin = InspectorPlugin.new(_panel)
	add_inspector_plugin(_inspector_plugin)

	_export_plugin = GaeaEditorExportPlugin.new()
	add_export_plugin(_export_plugin)

	GaeaEditorSettings.new().add_settings()

	resource_saved.connect(_on_resource_saved)

	EditorInterface.get_file_system_dock().resource_removed.connect(_on_resource_removed)
	EditorInterface.get_file_system_dock().file_removed.connect(_on_file_removed)


func _exit_tree() -> void:
	_panel.graph_edit.unpopulate()
	remove_inspector_plugin(_inspector_plugin)
	remove_export_plugin(_export_plugin)
	remove_dock(_dock)
	_dock.queue_free()
	_dock = null


func _get_unsaved_status(_for_scene: String) -> String:
	if not _for_scene.is_empty():
		return ""

	var string: String = "Save changes to the following GaeaGraphs before continuing?"
	var found_unsaved: bool = false
	for edited_graph: GaeaEditorFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.is_unsaved():
			found_unsaved = true
			string += "\n%s" % edited_graph.get_graph().resource_path.get_file()

	if found_unsaved:
		return string
	return ""


func _save_external_data() -> void:
	for edited_graph: GaeaEditorFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.is_unsaved():
			ResourceSaver.save(edited_graph.get_graph())
			edited_graph.set_dirty(false)


func _on_selection_changed() -> void:
	var selected: Array[Node] = _editor_selection.get_selected_nodes()
	if selected.size() == 1 and selected.front() is GaeaGenerator:
		_edit(selected.front().graph)


func _handles(object: Object) -> bool:
	return object is GaeaGraph


func _edit(object: Object) -> void:
	if is_instance_valid(object) and object is GaeaGraph:
		if object.resource_path.is_empty():
			return

		_dock.make_visible()
		if _panel.graph_edit.graph == object:
			return

		_panel.file_list.open_file(object)


func _on_resource_saved(resource: Resource) -> void:
	if resource is not GaeaGraph:
		return

	for edited_graph: GaeaEditorFileList.EditedGraph in _panel.file_list.edited_graphs:
		if edited_graph.get_graph() == resource:
			edited_graph.set_dirty(false)


func _on_file_removed(file: String) -> void:
	if file.get_extension() not in ["tscn", "scn"]:
		return

	for edited_graph: GaeaEditorFileList.EditedGraph in _panel.file_list.edited_graphs:
		if not edited_graph.get_graph().is_built_in():
			continue

		if edited_graph.get_graph().resource_path.get_slice("::", 0) == file:
			_panel.file_list.close_file(edited_graph.get_graph())


func _on_resource_removed(resource: Resource) -> void:
	if resource is GaeaGraph:
		_panel.file_list.close_file(resource)
