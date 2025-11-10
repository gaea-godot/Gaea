@tool
class_name GaeaPopupCreateNode
extends Window

@export var main_editor: GaeaMainEditor
@export var _reload_node_tree_button: Button
@export var _create_node_panel: Panel

@onready var cancel_button: Button = %CancelButton
@onready var tool_button: Button = %ToolButton
@onready var tool_popup: PopupMenu = %ToolPopup
@onready var create_node_tree: Tree = %CreateNodeTree
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var search_bar: LineEdit = %SearchBar

#TODO fix the color of the background of this popup

func _ready() -> void:
	if is_part_of_edited_scene():
		return

	_reload_node_tree_button.icon = preload("uid://crs5x6wghxmmb")
	close_requested.connect(hide)
	cancel_button.pressed.connect(close_requested.emit)
	tool_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Tools", &"EditorIcons")
	description_label.set_text("")

	_create_node_panel.add_theme_stylebox_override(
		&"panel", EditorInterface.get_base_control().get_theme_stylebox(&"panel", &"PopupPanel")
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_requested.emit()


func _on_tool_button_pressed() -> void:
	tool_popup.position = Vector2(position) + tool_button.get_global_rect().end
	tool_popup.position.x -= roundi(tool_button.size.x)
	tool_popup.popup()


func _on_tool_popup_id_pressed(id: int) -> void:
	var root := create_node_tree.get_root()
	match id:
		0:
			root.set_collapsed_recursive(false)
		1:
			root.set_collapsed_recursive(true)
			root.set_collapsed(false)


func filter_to_connect_type(type: GaeaValue.Type, is_left: bool) -> void:
	search_bar.clear()
	if is_left:
		create_node_tree.filter_to_output_type(type)
	else:
		create_node_tree.filter_to_input_type(type)


func _on_popup_create_node_request() -> void:
	main_editor.move_popup_at_mouse(self)
	create_node_tree.remove_filter(&"type")
	create_node_tree.apply_filters(false)
	popup()
	search_bar.grab_focus()
	search_bar.select_all()


func _on_popup_create_node_and_connect_node_request(node: GaeaGraphNode, type: GaeaValue.Type) -> void:
	_on_popup_create_node_request()
	filter_to_connect_type(type, main_editor.dragged_from_left)
	main_editor.created_node_connect_to = node
	close_requested.connect(
		func() -> void:
			main_editor.created_node_connect_to = null, CONNECT_ONE_SHOT
	)


func _on_special_node_selected_for_creation(_id: StringName) -> void:
	hide()
