@tool
extends GaeaGraphNodeParameter


@onready var _x_spin_box: SpinBox = $XSpinBox
@onready var _y_spin_box: SpinBox = $YSpinBox
@onready var _z_spin_box: SpinBox = $ZSpinBox


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	_x_spin_box.value_changed.connect(param_value_changed.emit)
	_y_spin_box.value_changed.connect(param_value_changed.emit)
	_z_spin_box.value_changed.connect(param_value_changed.emit)

	await super()



func get_param_value() -> Vector3:
	if super() != null:
		return super()
	return Vector3(_x_spin_box.value, _y_spin_box.value, _z_spin_box.value)


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_VECTOR3:
		return

	_x_spin_box.value = new_value.x
	_y_spin_box.value = new_value.y
	_z_spin_box.value = new_value.z
