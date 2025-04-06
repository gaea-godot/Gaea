@tool
@icon("../../assets/types/material.svg")
class_name GaeaMaterial
extends Resource


@export_group("Preview", "preview_")
@export var preview_color: Color = Color.TRANSPARENT


func _init() -> void:
	if preview_color == Color.TRANSPARENT:
		preview_color = Color(randf(), randf(), randf())


# Override for RandomMaterials, for example
func get_resource() -> GaeaMaterial:
	return self
