@tool
class_name GaeaParameterNameArgumentEditor
extends GaeaGraphNodeArgumentEditor


enum Mode {
	PARAMETER,
	SUBGRAPH_INPUT,
	SUBGRAPH_OUTPUT
}

var mode: Mode = Mode.PARAMETER

@onready var _name_label: Label = $NameLabel
@onready var _edit_button: Button = $EditButton


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	mode = hint.get("mode", Mode.PARAMETER)

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
	if not _is_valid(new_text) and new_text != _name_label.text:
		line_edit.add_theme_color_override(&"font_color", editor_interface.get_base_control().get_theme_color(&"error_color", &"Editor"))
	else:
		line_edit.remove_theme_color_override(&"font_color")


func _is_valid(text: String) -> bool:
	if not text.is_valid_ascii_identifier():
		push_error("Parameter name '%s' is not a valid identifier." % text)
		return false

	match mode:
		Mode.PARAMETER:
			if graph_node.graph_edit.graph.has_parameter(text):
				push_error("Parameter name '%s' matches an already existing parameter." % text)
				return false
		Mode.SUBGRAPH_INPUT:
			if graph_node.graph_edit.graph.get_input_nodes().values().has(text):
				return false
		Mode.SUBGRAPH_OUTPUT:
			if graph_node.graph_edit.graph.get_output_nodes().values().has(text):
				return false
	return true


func _on_line_edit_text_submitted(new_text: String, line_edit: LineEdit) -> void:
	if new_text == _name_label.text:
		line_edit.queue_free()
		return

	if not _is_valid(new_text):
		return

	_name_label.text = new_text
	graph_node.auto_shrink.call_deferred()
	argument_value_changed.emit(new_text)
	line_edit.queue_free()
