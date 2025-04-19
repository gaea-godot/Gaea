@tool
extends GaeaGraphNodeParameter


@onready var min_slider: HSlider = $MinSlider
@onready var max_slider: HSlider = $MinSlider/MaxSlider
@onready var area_panel: Panel = $MinSlider/AreaPanel
@onready var min_spin_box: SpinBox = $HBoxContainer/MinSpinBox
@onready var max_spin_box: SpinBox = $HBoxContainer/MaxSpinBox


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	min_slider.min_value = resource.hint.get("min", 0.0)
	min_slider.max_value = maxf(min_slider.min_value, resource.hint.get("max", 1.0))
	max_slider.min_value = min_slider.min_value
	max_slider.max_value = min_slider.max_value

	min_spin_box.min_value = min_slider.min_value
	max_spin_box.max_value = max_slider.max_value

	min_slider.allow_lesser = resource.hint.get("allow_lesser", true)
	min_spin_box.allow_lesser = min_slider.allow_lesser
	min_slider.allow_greater = resource.hint.get("allow_greater", true)
	max_spin_box.allow_greater = max_slider.allow_greater

	min_slider.step = resource.hint.get("step", min_slider.step)
	max_slider.step = min_slider.step
	min_spin_box.step = min_slider.step
	max_spin_box.step = min_slider.step

	min_spin_box.suffix = resource.hint.get("suffix", "")
	max_spin_box.suffix = min_spin_box.suffix

	min_spin_box.prefix = resource.hint.get("prefix", "")
	max_spin_box.prefix = min_spin_box.prefix

	min_slider.value_changed.connect(_on_slider_changed_value.unbind(1))
	max_slider.value_changed.connect(_on_slider_changed_value.unbind(1))
	min_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	max_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	await super()

	_on_slider_changed_value.call_deferred()


func _on_slider_changed_value() -> void:
	min_slider.set_value_no_signal(minf(min_slider.value, max_slider.value))
	max_slider.set_value_no_signal(maxf(max_slider.value, min_slider.value))
	area_panel.set_size.call_deferred(
		Vector2(
			min_slider.size.x * clampf(
				minf(1.0, _get_relative(max_slider.value)) - maxf(0.0, _get_relative(min_slider.value)),
				0.0,
				1.0
			),
			area_panel.size.y
		)
	)
	area_panel.position.x = min_slider.size.x * _get_relative(min_slider.value)
	min_spin_box.set_value_no_signal(min_slider.value)
	max_spin_box.set_value_no_signal(max_slider.value)
	param_value_changed.emit(get_param_value())


func _on_spin_box_changed_value() -> void:
	min_spin_box.set_value_no_signal(minf(min_spin_box.value, max_spin_box.value))
	max_spin_box.set_value_no_signal(maxf(max_spin_box.value, min_spin_box.value))
	min_slider.set_value(min_spin_box.value)
	max_slider.set_value(max_spin_box.value)


func _get_relative(value: float) -> float:
	return remap(clampf(value, min_slider.min_value, min_slider.max_value), min_slider.min_value, min_slider.max_value, 0.0, 1.0)


func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		min_slider.editable = false
		max_slider.editable = false
		min_slider.release_focus()
		max_slider.release_focus()


func _on_min_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative_position: float = clampf(event.position.x / min_slider.size.x, 0.0, 1.0)

		if max_slider.has_focus():
			max_slider.value = remap(relative_position, 0.0, 1.0, min_slider.min_value, min_slider.max_value)

	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed():
		var relative_position: float = clampf(event.position.x / min_slider.size.x, 0.0, 1.0)

		if abs(_get_relative(min_slider.value) - relative_position) < 0.05:
			min_slider.grab_focus()
			min_slider.editable = true
		elif abs(_get_relative(max_slider.value) - relative_position) < 0.05:
			max_slider.grab_focus()
			max_slider.editable = true

	elif event.is_released():
		min_slider.editable = false
		max_slider.editable = false
		min_slider.release_focus()
		max_slider.release_focus()


func get_param_value() -> Dictionary:
	if super() != null:
		return super()
	return {
		"max": max_slider.value,
		"min": min_slider.value
	}


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) != TYPE_DICTIONARY:
		return
	max_slider.value = new_value.get("max", 1.0)
	min_slider.value = new_value.get("min", 0.0)
