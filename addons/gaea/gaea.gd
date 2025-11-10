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


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		_panel.graph_edit.unpopulate()
		remove_inspector_plugin(_inspector_plugin)
		remove_control_from_bottom_panel(_container)
		_container.queue_free()


func _disable_plugin() -> void:
	if Engine.is_editor_hint():
		_custom_project_settings.remove_settings()


# TMP Until a proper save system
#func _get_unsaved_status(_for_scene: String) -> String:
#	if is_instance_valid(_panel.graph_edit.graph):
#		return "Save changes in Gaea before closing?"
#	return ""


# TMP Until a proper save system
func _save_external_data() -> void:
	if is_instance_valid(_panel.graph_edit.graph):
		ResourceSaver.save(_panel.graph_edit.graph)


# TMP Until a proper save system
func _on_selection_changed() -> void:
	if Engine.is_editor_hint():
		var selected: Array[Node] = _editor_selection.get_selected_nodes()
		if selected.size() == 1 and selected.front() is GaeaGenerator:
			var graph = selected.front().graph
			_panel_button.show()
			make_bottom_panel_item_visible(_container)
			if _panel.graph_edit.graph == graph:
				return
			_panel.graph_edit.unpopulate()
			_panel.graph_edit.populate(selected.front().graph)


# TMP Until a proper save system
func _handles(object: Object) -> bool:
	return object is GaeaGraph


# TMP Until a proper save system
func _edit(object: Object) -> void:
	if is_instance_valid(object) and object is GaeaGraph:
		make_bottom_panel_item_visible(_container)
		if _panel.graph_edit.graph == object:
			return
		_panel.graph_edit.unpopulate()
		_panel.graph_edit.populate(object)
