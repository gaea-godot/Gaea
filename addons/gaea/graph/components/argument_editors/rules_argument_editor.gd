@tool
class_name GaeaRulesArgumentEditor
extends GaeaGraphNodeArgumentEditor


@onready var cells: Control = %Cells


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()


func get_arg_value() -> Dictionary:
	return cells.get_states()


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_DICTIONARY:
		return

	cells.set_states(new_value)


func _on_cells_cell_pressed() -> void:
	argument_value_changed.emit(get_arg_value())
