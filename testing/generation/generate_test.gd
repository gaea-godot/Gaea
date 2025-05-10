class_name GenerateTest
extends GdUnitTestSuite


var first_grid: GaeaGrid



func test_has_generated() -> void:
	var scene = load("uid://di7u4f3idjdd").instantiate()
	var runner := scene_runner(scene)
	await scene.test_generation()
	first_grid = scene.last_grid
	assert_dict(first_grid._grid).is_not_empty()


func test_generations_match() -> void:
	var scene = load("uid://di7u4f3idjdd").instantiate()
	var runner := scene_runner(scene)
	await scene.test_generation()
	var second_grid: GaeaGrid = scene.last_grid
	assert_bool(first_grid._grid.recursive_equal(second_grid._grid, 1)).is_true()


func test_generations_dont_match() -> void:
	var scene = load("uid://di7u4f3idjdd").instantiate()
	var runner := scene_runner(scene)
	await scene.test_generation(1)
	var second_grid: GaeaGrid = scene.last_grid
	assert_bool(first_grid._grid.recursive_equal(second_grid._grid, 1)).is_false()
