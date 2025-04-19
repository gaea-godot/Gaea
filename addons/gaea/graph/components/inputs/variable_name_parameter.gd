@tool
extends GaeaGraphNodeParameter


@onready var line_edit: LineEdit = $LineEdit


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	line_edit.text_changed.connect(param_value_changed.emit)

func get_param_value() -> String:
	if super() != null:
		return super()
	return line_edit.text


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) not in [TYPE_STRING, TYPE_STRING_NAME]:
		return
	line_edit.text = new_value
