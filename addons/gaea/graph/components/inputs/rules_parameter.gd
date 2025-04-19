@tool
extends GaeaGraphNodeParameter

@onready var grid_container: GridContainer = $GridContainer


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	for button: CheckBox in grid_container.get_children():
		button.toggled.connect(_on_value_changed.unbind(1))


func _on_value_changed() -> void:
	param_value_changed.emit(get_param_value())


func get_param_value() -> Dictionary:
	if super() != null:
		return super()
	var dict: Dictionary
	for button: CheckBox in grid_container.get_children():
		if button.button_pressed:
			dict.set(_get_button_pos(button.get_index()), button.current_state)
	return dict


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_DICTIONARY:
		return

	for button: CheckBox in grid_container.get_children():
		var pos: Vector2i = _get_button_pos(button.get_index())
		if new_value.has(pos):
			button.set_state(true, new_value.get(pos))
		else:
			button.set_state(false, true)


func _get_button_pos(idx: int) -> Vector2i:
	var row: int = ceili((float(idx) + 1.0) / 5.0)
	var column: int = roundi((idx + 1.0) - ((floori(float(idx + 1.0) / 5.0)) * 5.0))
	return Vector2i(column, row) - Vector2i(3, 3)
