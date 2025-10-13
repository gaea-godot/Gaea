@tool
extends GaeaGraphNodeArgumentEditor
class_name GaeaRangeArgumentEditor



@onready var min_spin_box: SpinBox = %MinSpinBox
@onready var max_spin_box: SpinBox = %MaxSpinBox
@onready var range_slider: Control = %RangeSlider



func _configure() -> void:
	if is_part_of_edited_scene():
		return

	var range_min: float = hint.get("min", 0.0)
	var range_max: float = hint.get("max", 1.0)
	var allow_lesser: bool = hint.get("allow_lesser", true)
	var allow_greater: bool = hint.get("allow_greater", true)
	var step: float = hint.get("step", min_spin_box.step)


	range_slider.min_value = range_min
	range_slider.max_value = range_max
	range_slider.step = step

	range_slider.allow_lesser = false
	range_slider.allow_greater = false

	min_spin_box.suffix = hint.get("suffix", "")
	max_spin_box.suffix = min_spin_box.suffix

	min_spin_box.prefix = hint.get("prefix", "")
	max_spin_box.prefix = min_spin_box.prefix

	min_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	max_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))

	_configure_min_max_spin_box(allow_lesser, allow_greater)

	await super()


func _configure_min_max_spin_box(allow_lesser: int, allow_greater: int) -> void:
	min_spin_box.min_value = range_slider.min_value
	max_spin_box.min_value = range_slider.min_value
	max_spin_box.max_value = range_slider.max_value
	min_spin_box.max_value = range_slider.max_value

	min_spin_box.step = range_slider.step
	max_spin_box.step = range_slider.step

	min_spin_box.allow_lesser = allow_lesser
	min_spin_box.allow_greater = allow_greater
	max_spin_box.allow_lesser = allow_lesser
	max_spin_box.allow_greater = allow_greater



func _on_spin_box_changed_value() -> void:
	if min_spin_box.value > max_spin_box.value:
		max_spin_box.set_value_no_signal(min_spin_box.value)
	elif max_spin_box.value < min_spin_box.value:
		min_spin_box.set_value_no_signal(max_spin_box.value)
	
	if max_spin_box.value > range_slider.max_value:
		range_slider.max_value = max_spin_box.value
	if min_spin_box.value < range_slider.min_value:
		range_slider.min_value = min_spin_box.value
	range_slider.set_range(min_spin_box.value, max_spin_box.value)


func get_arg_value() -> Dictionary:
	if super() != null:
		return super()
	return {
		"min": range_slider.start_value,
		"max": range_slider.end_value
	}


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_DICTIONARY:
		return
	min_spin_box.value = new_value.get("min", 0.0)
	max_spin_box.value = new_value.get("max", 1.0)


func _on_range_slider_value_changed(start_value: float, end_value: float) -> void:
	min_spin_box.set_value_no_signal(start_value)
	max_spin_box.set_value_no_signal(end_value)

	argument_value_changed.emit(get_arg_value())
