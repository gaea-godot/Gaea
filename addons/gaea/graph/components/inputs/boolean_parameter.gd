@tool
extends GaeaGraphNodeParameter


@onready var check_box: CheckBox = $CheckBox


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	check_box.toggled.connect(param_value_changed.emit)


func get_param_value() -> bool:
	if super() != null:
		return super()
	return check_box.button_pressed


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_BOOL:
		return
	check_box.set_pressed_no_signal(new_value)
