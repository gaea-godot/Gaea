@tool
class_name GaeaNeighborArgumentEditor
extends GaeaGraphNodeArgumentEditor

@onready var cells: Control = %Cells


func _configure() -> void:
	if is_part_of_edited_scene():
		return

	await super()


func _on_value_changed() -> void:
	argument_value_changed.emit(get_arg_value())


func get_arg_value() -> Array[Vector3i]:
	return cells.get_pressed_cells()


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_ARRAY:
		return ERR_INVALID_DATA

	cells.set_pressed(new_value)
	return OK


func _on_cell_pressed() -> void:
	argument_value_changed.emit(get_arg_value())
