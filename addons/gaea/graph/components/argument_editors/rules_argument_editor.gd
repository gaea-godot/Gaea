@tool
class_name GaeaRulesArgumentEditor
extends GaeaGraphNodeArgumentEditor

#Supported hints
# "radius": 2
# "show_origin": true
# "check_mode": GaeaCheckableCell.CheckMode.BOOLEAN
# "coordinate_format": GaeaCheckableCell.CoordinateFormat.PERSPECTIVE_3D

@export var cells: GaeaCheckableCell
var _reconfiguring: bool = false

func _configure() -> void:
	if is_part_of_edited_scene():
		return
	_apply_hint()
	await super()


func _apply_hint() -> void:
	for property in [&"radius", &"show_origin", &"check_mode", &"coordinate_format"]:
		if hint.has(property):
			cells.set(property, hint.get(property))
	graph_node.auto_shrink()


func _on_hint_changed() -> void:
	if _reconfiguring:
		return

	# Wait for mouse button to be released because if we update the node now
	# the slider will move and cause a new change.
	_reconfiguring = true
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		await get_tree().process_frame
	_apply_hint()
	_reconfiguring = false


func get_arg_value() -> Dictionary:
	return cells.get_states()


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA

	cells.set_states(new_value)
	return OK


func _on_cells_cell_pressed() -> void:
	argument_value_changed.emit(get_arg_value())
