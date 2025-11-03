@tool
class_name GaeaNumberArgumentEditor
extends GaeaGraphNodeArgumentEditor

@onready var spin_box: SpinBox = %SpinBox
@onready var h_slider: HSlider = %HSlider


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	h_slider.add_theme_icon_override(
		&"grabber", get_theme_icon(&"GuiScrollGrabberHl", &"EditorIcons")
	)


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	if type == GaeaValue.Type.INT:
		spin_box.step = 1

	h_slider.visible = hint.has("min") and hint.has("max")
	h_slider.step = spin_box.step

	if hint.has("min"):
		spin_box.min_value = hint.get("min")
		spin_box.allow_lesser = false
		h_slider.min_value = spin_box.min_value
		h_slider.allow_lesser = spin_box.allow_lesser

	if hint.has("max"):
		spin_box.max_value = hint.get("max")
		spin_box.allow_greater = false
		h_slider.max_value = spin_box.max_value
		h_slider.allow_greater = spin_box.allow_greater

	spin_box.suffix = hint.get("suffix", "")
	spin_box.prefix = hint.get("prefix", "")


func get_arg_value() -> Variant:
	if type == GaeaValue.Type.FLOAT:
		return float(spin_box.value)
	return int(spin_box.value)


func set_arg_value(new_value: Variant) -> Error:
	if typeof(new_value) not in [TYPE_FLOAT, TYPE_INT]:
		return ERR_INVALID_DATA

	spin_box.value = new_value
	h_slider.set_value_no_signal(new_value)
	return OK


func _on_h_slider_value_changed(value: float) -> void:
	spin_box.set_value(value)


func _on_spin_box_value_changed(value: float) -> void:
	argument_value_changed.emit(value)
	h_slider.set_value_no_signal(value)
