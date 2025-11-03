@tool
class_name GaeaVector3ArgumentEditor
extends GaeaGraphNodeArgumentEditor

const VALID_TYPES := [
	GaeaValue.Type.VECTOR2, GaeaValue.Type.VECTOR2I, GaeaValue.Type.VECTOR3, GaeaValue.Type.VECTOR3I
]

@onready var _x_spin_box: SpinBox = %XSpinBox
@onready var _y_spin_box: SpinBox = %YSpinBox
@onready var _z_spin_box: SpinBox = %ZSpinBox
@onready var _x_label: Label = %XLabel
@onready var _y_label: Label = %YLabel
@onready var _z_label: Label = %ZLabel
@onready var _z_container: HBoxContainer = $ZContainer


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super ()
	_x_spin_box.value_changed.connect(_on_slider_changed_value.unbind(1))
	_y_spin_box.value_changed.connect(_on_slider_changed_value.unbind(1))
	_z_spin_box.value_changed.connect(_on_slider_changed_value.unbind(1))
	var editor_interface = Engine.get_singleton("EditorInterface")
	_x_label.add_theme_color_override(
		&"font_color",
		editor_interface.get_base_control().get_theme_color("property_color_x", "Editor")
	)
	_y_label.add_theme_color_override(
		&"font_color",
		editor_interface.get_base_control().get_theme_color("property_color_y", "Editor")
	)
	_z_label.add_theme_color_override(
		&"font_color",
		editor_interface.get_base_control().get_theme_color("property_color_z", "Editor")
	)

	if type == GaeaValue.Type.VECTOR2I or type == GaeaValue.Type.VECTOR3I:
		_x_spin_box.step = 1
		_y_spin_box.step = 1
		_z_spin_box.step = 1

	if type == GaeaValue.Type.VECTOR2 or type == GaeaValue.Type.VECTOR2I:
		_z_container.set_visible.call_deferred(false)
		graph_node.auto_shrink.call_deferred()

	if hint.has("min"):
		_x_spin_box.min_value = hint.get("min").x
		_y_spin_box.min_value = hint.get("min").y
		if type == GaeaValue.Type.VECTOR3 or type == GaeaValue.Type.VECTOR3I:
			_z_spin_box.min_value = hint.get("min").z

	if hint.has("max"):
		_x_spin_box.min_value = hint.get("max").x
		_y_spin_box.min_value = hint.get("max").y
		if type == GaeaValue.Type.VECTOR3 or type == GaeaValue.Type.VECTOR3I:
			_z_spin_box.min_value = hint.get("max").z

	_x_spin_box.allow_lesser = not hint.has("min")
	_y_spin_box.allow_lesser = not hint.has("min")
	_z_spin_box.allow_lesser = not hint.has("min")
	_x_spin_box.allow_greater = not hint.has("max")
	_y_spin_box.allow_greater = not hint.has("max")
	_z_spin_box.allow_greater = not hint.has("max")


func _on_slider_changed_value() -> void:
	argument_value_changed.emit(get_arg_value());


func set_editor_visible(value: bool) -> void:
	for child in get_children():
		if child == _label:
			continue

		if child == _z_container and type in [GaeaValue.Type.VECTOR2, GaeaValue.Type.VECTOR2I]:
			continue

		child.set_visible(value)


func get_arg_value() -> Variant:
	match type:
		GaeaValue.Type.VECTOR2:
			return Vector2(_x_spin_box.value, _y_spin_box.value)
		GaeaValue.Type.VECTOR2I:
			return Vector2i(int(_x_spin_box.value), int(_y_spin_box.value))
		GaeaValue.Type.VECTOR3:
			return Vector3(_x_spin_box.value, _y_spin_box.value, _z_spin_box.value)
		GaeaValue.Type.VECTOR3I:
			return Vector3i(int(_x_spin_box.value), int(_y_spin_box.value), int(_z_spin_box.value))
	return null


func set_arg_value(new_value: Variant) -> Error:
	var new_value_type = typeof(new_value)
	if not (typeof(new_value) in VALID_TYPES):
		return ERR_INVALID_DATA

	_x_spin_box.value = float(new_value.x)
	_y_spin_box.value = float(new_value.y)
	if new_value_type == GaeaValue.Type.VECTOR3 or new_value_type == GaeaValue.Type.VECTOR3I:
		_z_spin_box.value = float(new_value.z)
	else:
		_z_spin_box.value = 0.0
	return OK
