@tool
class_name GaeaBooleanArgumentEditor
extends GaeaGraphNodeArgumentEditor

@onready var check_box: CheckBox = $CheckBox


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	check_box.toggled.connect(argument_value_changed.emit)


func get_arg_value() -> bool:
	return check_box.button_pressed


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_BOOL:
		return ERR_INVALID_DATA

	check_box.set_pressed_no_signal(new_value)
	return OK
