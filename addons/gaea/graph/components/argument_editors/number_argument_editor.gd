@tool
extends GaeaGraphNodeArgumentEditor
class_name GaeaNumberArgumentEditor


@onready var spin_box: SpinBox = $SpinBox


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	spin_box.value_changed.connect(argument_value_changed.emit)

	if type == GaeaValue.Type.INT:
		spin_box.step = 1

	spin_box.min_value = hint.get("min", 0.0)
	spin_box.allow_lesser = not hint.has("min")

	spin_box.max_value = hint.get("max", 1.0)
	spin_box.allow_greater = not hint.has("max")

	spin_box.suffix = hint.get("suffix", "")
	spin_box.prefix = hint.get("prefix", "")


func get_arg_value() -> Variant:
	if super() != null:
		return super()
	if type == GaeaValue.Type.FLOAT:
		return float(spin_box.value)
	return int(spin_box.value)


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) not in [TYPE_FLOAT, TYPE_INT]:
		return
	spin_box.value = new_value
