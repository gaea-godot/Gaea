extends Node2D


@onready var gaea_generator: GaeaGenerator = $GaeaGenerator

var last_grid: GaeaGrid

## Used for integration testing.
func test_generation(fixed_seed: int = 0) -> void:
	gaea_generator.world_size = Vector3i(45, 45, 1)
	gaea_generator.random_seed_on_generate = false
	gaea_generator.seed = fixed_seed
	gaea_generator.generate()
	gaea_generator.generation_finished.connect(func(grid): last_grid = grid)
	await gaea_generator.generation_finished


func _on_generate_pressed() -> void:
	gaea_generator.generate()
