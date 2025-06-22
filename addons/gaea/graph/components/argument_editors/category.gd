@tool
class_name GaeaArgumentCategory
extends GaeaGraphNodeArgumentEditor

@onready var _collapse_button: TextureButton = %CollapseButton

var arguments: Array[GaeaGraphNodeArgumentEditor]


func _configure() -> void:
	if is_part_of_edited_scene():
		return

	var editor_interface = Engine.get_singleton("EditorInterface")
	_collapse_button.texture_normal = editor_interface.get_base_control().get_theme_icon(&"GuiTreeArrowDown", &"EditorIcons")
	_collapse_button.texture_pressed = editor_interface.get_base_control().get_theme_icon(&"GuiTreeArrowRight", &"EditorIcons")
	_collapse_button.visible = hint.get("collapsable", true)
	

func set_label_text(new_text: String) -> void:
	super ("[b]%s[/b]" % new_text)
	
	
func get_arg_value() -> bool:
	if super () != null:
		return super ()
	return _collapse_button.button_pressed
	

func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_BOOL:
		return
		
	if not hint.get("collapsable", true):
		new_value = false

	_collapse_button.set_pressed(new_value)


func _on_label_gui_input(event: InputEvent) -> void:
	if not hint.get("collapsable", true):
		return
		
	if event is InputEventMouseButton:
		if not event.is_pressed():
			return
		
		if not event.button_index == MOUSE_BUTTON_LEFT:
			return
			
		_collapse_button.set_pressed(not _collapse_button.button_pressed)


func _on_collapse_button_toggled(toggled_on: bool) -> void:
	for argument_editor in arguments:
		if toggled_on:
			for child in argument_editor.get_children():
				child.hide()
			argument_editor.custom_minimum_size.y = 0.0
			argument_editor.size.y = 0.0
		else:
			for child in argument_editor.get_children():
				child.show()
			argument_editor.custom_minimum_size.y = 32.0
			argument_editor.size.y = argument_editor.get_combined_minimum_size().y
			graph_node._update_arguments_visibility()
		graph_node.auto_shrink()
