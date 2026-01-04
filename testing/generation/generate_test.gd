extends GdUnitTestSuite


var first_grid: GaeaGrid
var generator_seed:int

const test_scene = "uid://dh5c2eomfri6n"

func test_has_generated() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = false
	await scene.test_generation(200)

	var finished := scene.last_finished
	assert_that(finished).is_not_null()
	assert_bool(finished.cancelled).is_false()
	assert_int(finished.finish_time).is_greater_equal(0)

	var task_pool := scene.gaea_generator.task_pool
	assert_int(task_pool._tasks.size()).is_equal(0)

	first_grid = scene.last_grid
	generator_seed = scene.gaea_generator.settings.seed
	assert_that(first_grid).is_not_null()
	assert_dict(first_grid._grid).is_not_empty()


func test_generations_match() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = false
	await scene.test_generation(generator_seed)

	var second_grid: GaeaGrid = scene.last_grid
	assert_that(generator_seed).is_equal(scene.gaea_generator.settings.seed)
	assert_that(first_grid).is_not_null()
	assert_that(second_grid).is_not_null()
	assert_bool(compare_grids(first_grid, second_grid)).is_true()


func test_multithreaded_match() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = true
	scene.gaea_generator.task_pool.task_limit = 0
	await scene.test_generation(generator_seed)

	var second_grid: GaeaGrid = scene.last_grid
	assert_that(scene.gaea_generator.settings.seed).is_equal(generator_seed)
	assert_that(first_grid).is_not_null()
	assert_that(second_grid).is_not_null()
	assert_bool(compare_grids(first_grid, second_grid)).is_true()


func test_multithreaded_discard_new() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = true
	scene.gaea_generator.task_pool.task_limit = 0
	scene.gaea_generator.task_pool.duplication_strategy = GaeaTaskPool.DeDuplicationStrategy.DROP_NEW
	await scene.test_generation(generator_seed, 2)

	var cancellation = scene.last_cancelled
	assert_that(cancellation).is_null()

	var discard = scene.last_discarded
	assert_that(discard).is_not_null()
	assert_bool(discard.cancelled).is_false()

	var second_grid: GaeaGrid = scene.last_grid
	assert_that(scene.gaea_generator.settings.seed).is_equal(generator_seed)
	assert_that(first_grid).is_not_null()
	assert_that(second_grid).is_not_null()
	assert_bool(compare_grids(first_grid, second_grid)).is_true()


func test_multithreaded_discard_existing() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = true
	scene.gaea_generator.task_pool.task_limit = 0
	scene.gaea_generator.task_pool.duplication_strategy = GaeaTaskPool.DeDuplicationStrategy.DROP_EXISTING
	await scene.test_generation(generator_seed, 2)

	var cancellation = scene.last_cancelled
	assert_that(cancellation).is_not_null()
	assert_bool(cancellation.cancelled).is_true()

	var discard = scene.last_discarded
	assert_that(discard).is_null()

	var second_grid: GaeaGrid = scene.last_grid
	assert_that(scene.gaea_generator.settings.seed).is_equal(generator_seed)
	assert_that(first_grid).is_not_null()
	assert_that(second_grid).is_not_null()
	print(compare_string(first_grid, second_grid))
	assert_bool(compare_grids(first_grid, second_grid)).is_true()


func test_generations_dont_match() -> void:
	var scene : GaeaGenerationTester = load(test_scene).instantiate()
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = false
	await scene.test_generation(5)

	var second_grid: GaeaGrid = scene.last_grid
	assert_that(generator_seed).is_not_equal(scene.gaea_generator.settings.seed)
	assert_that(first_grid).is_not_null()
	assert_that(second_grid).is_not_null()
	assert_bool(compare_grids(first_grid, second_grid)).is_false()


func compare_grids(grid_a, grid_b) -> bool:
	for layer_idx in first_grid.get_layers_count():
		if grid_a.get_layer(layer_idx)._grid != grid_b.get_layer(layer_idx)._grid:
			return false
	return true


func compare_string(grid_1: GaeaGrid, grid_2: GaeaGrid) -> String:
	return "\n%s\n%s\n" % [grid_string(grid_1), grid_string(grid_2)]


func grid_string(grid: GaeaGrid) -> String:
	var string := ""
	for layer in grid._grid.keys():
		string += "%s: " % layer
		var map := grid._grid[layer]
		var cells = map.get_cells()
		string += "cell count %d" % cells.size()
		string += ", "
	return string
