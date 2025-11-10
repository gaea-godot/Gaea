@tool
class_name GaeaParameterNameArgumentEditor
extends GaeaGraphNodeArgumentEditor

@onready var _name_label: Label = $NameLabel
@onready var _edit_button: Button = $EditButton


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	var editor_interface = Engine.get_singleton("EditorInterface")
	_edit_button.icon = editor_interface.get_base_control().get_theme_icon(&"Edit", &"EditorIcons")


func get_arg_value() -> String:
	return _name_label.text


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) not in [TYPE_STRING, TYPE_STRING_NAME]:
		return ERR_INVALID_DATA

	_name_label.text = new_value
	return OK


func _on_edit_button_pressed() -> void:
	var line_edit: LineEdit = LineEdit.new()
	line_edit.select_all_on_focus = true
	line_edit.text = _name_label.text
	line_edit.expand_to_text_length = true
	line_edit.text_changed.connect(_on_line_edit_text_changed.bind(line_edit))
	line_edit.text_submitted.connect(_on_line_edit_text_submitted.bind(line_edit))
	line_edit.focus_exited.connect(line_edit.queue_free)
	line_edit.position = graph_node.get_parent().get_local_mouse_position()
	graph_node.get_parent().add_child(line_edit)
	line_edit.grab_focus()


func _on_line_edit_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var editor_interface = Engine.get_singleton("EditorInterface")
	if (graph_node.graph_edit.graph.has_parameter(new_text) and new_text != _name_label.text) or not new_text.is_valid_identifier():
		line_edit.add_theme_color_override(&"font_color", editor_interface.get_base_control().get_theme_color(&"error_color", &"Editor"))
	else:
		line_edit.remove_theme_color_override(&"font_color")


func _on_line_edit_text_submitted(new_text: String, line_edit: LineEdit) -> void:
	if new_text == _name_label.text:
		line_edit.queue_free()
		return

	if not new_text.is_valid_ascii_identifier():
		push_error("Parameter name '%s' is not a valid identifier." % new_text)
		return

	if graph_node.graph_edit.graph.has_parameter(new_text):
		push_error("Parameter name '%s' matches an already existing parameter." % new_text)
		return

	_name_label.text = new_text
	graph_node.auto_shrink.call_deferred()
	argument_value_changed.emit(new_text)
	line_edit.queue_free()
