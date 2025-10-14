@tool
extends EditorPlugin


const BottomPanel = preload("uid://dpbmowgfmnxe5")
const InspectorPlugin = preload("res://addons/gaea/editor/inspector_plugin.gd")

var _container: MarginContainer
var _panel: BottomPanel
var _panel_button: Button
var _editor_selection: EditorSelection
var _inspector_plugin: EditorInspectorPlugin
var _custom_project_settings: GaeaProjectSettings


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_editor_selection = EditorInterface.get_selection()
		_editor_selection.selection_changed.connect(_on_selection_changed)

		_container = MarginContainer.new()
		_panel = BottomPanel.instantiate()
		_panel.plugin = self
		_container.add_child(_panel)
		_panel_button = add_control_to_bottom_panel(_container, "Gaea")
		_panel_button.hide()

		_inspector_plugin = InspectorPlugin.new()
		add_inspector_plugin(_inspector_plugin)

		GaeaEditorSettings.new().add_settings()
		_custom_project_settings = GaeaProjectSettings.new()
		_custom_project_settings.add_settings()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		_panel.unpopulate()
		remove_inspector_plugin(_inspector_plugin)
		remove_control_from_bottom_panel(_container)
		_container.queue_free()


func _get_unsaved_status(for_scene):
	if for_scene.is_empty():
		return "Save changes in Gaea before closing?"

	return "Scene %s has changes from Gaea. Save before closing?" % for_scene.get_file()


func _on_selection_changed() -> void:
	if Engine.is_editor_hint():
		var selected: Array[Node] = _editor_selection.get_selected_nodes()

		if selected.size() == 1 and selected.front() is GaeaGenerator:
			_panel_button.show()
			make_bottom_panel_item_visible(_container)
			_panel.populate(selected.front())
		else:
			if is_instance_valid(_panel.get_selected_generator()):
				_panel_button.hide()
				hide_bottom_panel()
				await _panel.unpopulate()


func _disable_plugin() -> void:
	if Engine.is_editor_hint():
		_custom_project_settings.remove_settings()


func show_bottom_panel() -> void:
	make_bottom_panel_item_visible(_container)
