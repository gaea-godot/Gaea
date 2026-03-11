@tool
@icon("../../assets/layer.svg")
class_name GaeaLayer
extends Resource


@export var enabled: bool = true:
	set(new_value):
		if enabled != new_value:
			enabled = new_value
			emit_changed()
