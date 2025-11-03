@tool
class_name GaeaRangeArgumentEditor
extends GaeaGraphNodeArgumentEditor



@onready var _min_spin_box: SpinBox = %MinSpinBox
@onready var _max_spin_box: SpinBox = %MaxSpinBox
@onready var _range_slider: Control = %RangeSlider



func _configure() -> void:
	if is_part_of_edited_scene():
		return

	var range_min: float = hint.get("min", 0.0)
	var range_max: float = hint.get("max", 1.0)
	var allow_lesser: bool = hint.get("allow_lesser", true)
	var allow_greater: bool = hint.get("allow_greater", true)
	var step: float = hint.get("step", _min_spin_box.step)


	_range_slider.min_value = range_min
	_range_slider.max_value = range_max
	_range_slider.step = step

	_range_slider.allow_lesser = false
	_range_slider.allow_greater = false

	_min_spin_box.suffix = hint.get("suffix", "")
	_max_spin_box.suffix = _min_spin_box.suffix

	_min_spin_box.prefix = hint.get("prefix", "")
	_max_spin_box.prefix = _min_spin_box.prefix

	_min_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	_max_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))

	_configure_min_max_spin_box(allow_lesser, allow_greater)

	await super()


func _configure_min_max_spin_box(allow_lesser: int, allow_greater: int) -> void:
	_min_spin_box.min_value = _range_slider.min_value
	_max_spin_box.min_value = _range_slider.min_value
	_max_spin_box.max_value = _range_slider.max_value
	_min_spin_box.max_value = _range_slider.max_value

	_min_spin_box.step = _range_slider.step
	_max_spin_box.step = _range_slider.step

	_min_spin_box.allow_lesser = allow_lesser
	_min_spin_box.allow_greater = allow_greater
	_max_spin_box.allow_lesser = allow_lesser
	_max_spin_box.allow_greater = allow_greater



func _on_spin_box_changed_value() -> void:
	if _min_spin_box.value > _max_spin_box.value:
		_max_spin_box.set_value_no_signal(_min_spin_box.value)
	elif _max_spin_box.value < _min_spin_box.value:
		_min_spin_box.set_value_no_signal(_max_spin_box.value)

	if _max_spin_box.value > _range_slider.max_value:
		_range_slider.max_value = _max_spin_box.value
	if _min_spin_box.value < _range_slider.min_value:
		_range_slider.min_value = _min_spin_box.value
	_range_slider.set_range(_min_spin_box.value, _max_spin_box.value)


func get_arg_value() -> Dictionary:
	return {
		"min": _range_slider.start_value,
		"max": _range_slider.end_value
	}


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA

	_min_spin_box.value = new_value.get("min", 0.0)
	_max_spin_box.value = new_value.get("max", 1.0)
	return OK


func _on_range_slider_value_changed(start_value: float, end_value: float) -> void:
	_min_spin_box.set_value_no_signal(start_value)
	_max_spin_box.set_value_no_signal(end_value)

	argument_value_changed.emit(get_arg_value())
