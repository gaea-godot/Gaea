@tool
class_name GaeaNeighborArgumentEditor
extends GaeaGraphNodeArgumentEditor

const DIRECTIONS = [
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.ZERO,
	Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.DOWN + Vector2i.RIGHT
]

@onready var grid_container: GridContainer = $GridContainer


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()
	for button: CheckBox in grid_container.get_children():
		button.toggled.connect(_on_value_changed.unbind(1))


func _on_value_changed() -> void:
	argument_value_changed.emit(get_arg_value())


func get_arg_value() -> Array[Vector2i]:
	var value: Array[Vector2i]
	for button: CheckBox in grid_container.get_children():
		if button.button_pressed:
			value.append(DIRECTIONS.get(button.get_index()))

	return value


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_ARRAY:
		return

	for button: CheckBox in grid_container.get_children():
		button.set_pressed_no_signal(new_value.has(DIRECTIONS.get(button.get_index())))
