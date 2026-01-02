@tool
class_name GaeaRulesArgumentEditor
extends GaeaGraphNodeArgumentEditor

#Supported hints
# "radius": 2
# "show_origin": true
# "check_mode": GaeaCheckableCell.CheckMode.BOOLEAN
# "coordinate_format": GaeaCheckableCell.CoordinateFormat.PERSPECTIVE_3D

const cells_hint_properties: Array[StringName] = [&"radius", &"show_origin", &"check_mode", &"coordinate_format"]


@export var cells: GaeaCheckableCell


func _configure() -> void:
	if is_part_of_edited_scene():
		return

	for property in cells_hint_properties:
		if hint.has(property):
			cells.set(property, hint.get(property))

	await super()


func get_arg_value() -> Dictionary:
	return cells.get_states()


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA

	cells.set_states(new_value)
	return OK


func _on_cells_cell_pressed() -> void:
	argument_value_changed.emit(get_arg_value())
