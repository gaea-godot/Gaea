@tool
extends Window


@onready var cancel_button: Button = %CancelButton
@onready var tool_button: Button = %ToolButton
@onready var tool_popup: PopupMenu = %ToolPopup
@onready var create_node_tree: Tree = %CreateNodeTree
@onready var description_label: RichTextLabel = %DescriptionLabel


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	close_requested.connect(hide)
	cancel_button.pressed.connect(hide)
	tool_button.icon = EditorInterface.get_base_control().get_theme_icon(&"Tools", &"EditorIcons")
	description_label.set_text("")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()


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
