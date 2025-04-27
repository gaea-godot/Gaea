extends Node2D

@onready var gaea_generator: GaeaGenerator = $GaeaGenerator


func _on_generate_pressed() -> void:
	gaea_generator.generate()
