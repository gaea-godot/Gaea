extends GdUnitTestSuite


var first_grid: GaeaGrid
var seed:int

const test_scene = "uid://dh5c2eomfri6n"

func test_has_generated() -> void:
	var scene = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	await scene.test_generation()
	first_grid = scene.last_grid
	seed = scene.gaea_generator.seed
	assert_dict(first_grid._grid).is_not_empty()


func test_generations_match() -> void:
	var scene = load("uid://dh5c2eomfri6n").instantiate()
	var _runner := scene_runner(scene)
	await scene.test_generation()
	var second_grid: GaeaGrid = scene.last_grid
	assert_that(seed).is_equal(scene.gaea_generator.seed)
	assert_bool(first_grid._grid.recursive_equal(second_grid._grid, 1)).is_true()


func test_generations_dont_match() -> void:
	var scene = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	await scene.test_generation(5)
	var second_grid: GaeaGrid = scene.last_grid
	assert_that(seed).is_not_equal(scene.gaea_generator.seed)
	assert_bool(first_grid._grid.recursive_equal(second_grid._grid, 1)).is_false()
