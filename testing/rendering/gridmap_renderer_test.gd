extends GdUnitTestSuite


const ITEM_1_TILES_HASH := 836889996
const ITEM_2_TILES_HASH := 286036777
const ITEM_1_TILES_HASH_SMALL := 1666742523
const ITEM_2_TILES_HASH_SMALL := 3765593323


var scene: GaeaRendererTester
var runner: GdUnitSceneRunner
var renderer: GridMapGaeaRenderer:
	get: return scene.renderer


func before() -> void:
	scene = load("uid://bamaii0ujxbp2").instantiate()
	runner = scene_runner(scene)


func test_full_area() -> void:
	scene.generator.generate()
	await renderer.render_finished
	
	var item_1_cells_used: Array[Vector3i] = renderer.grid_maps[0].get_used_cells_by_item(0)
	assert_array(item_1_cells_used).is_not_empty()
	var item_1_hash: int = item_1_cells_used.hash()
	assert_int(item_1_hash)\
		.override_failure_message("Layer 0 rendering of [b]GridMapGaeaRenderer[/b] not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [item_1_hash, ITEM_1_TILES_HASH])\
		.is_equal(ITEM_1_TILES_HASH)

	var item_2_cells_used: Array[Vector3i] = renderer.grid_maps[1].get_used_cells_by_item(1)
	assert_array(item_2_cells_used).is_not_empty()
	var item_2_hash: int = item_2_cells_used.hash()
	assert_int(item_2_hash)\
		.override_failure_message("Layer 1 rendering of [b]GridMapGaeaRenderer[/b] not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [item_2_hash, ITEM_2_TILES_HASH])\
		.is_equal(ITEM_2_TILES_HASH)


func test_reset() -> void:
	scene.generator.request_reset()
	assert_array(renderer.grid_maps[0].get_used_cells())\
		.override_failure_message("[b]GridMapGaeaRenderer[/b] wasn't cleared properly.")\
		.is_empty()
	assert_array(renderer.grid_maps[1].get_used_cells())\
		.override_failure_message("[b]GridMapGaeaRenderer[/b] wasn't cleared properly.")\
		.is_empty()


func test_small_area() -> void:
	var area: AABB = AABB(Vector3.ZERO, Vector3.ONE * 16)
	scene.generator.generate_area(area)
	await scene.generator.generation_finished

	var item_1_cells_used: Array[Vector3i] = renderer.grid_maps[0].get_used_cells_by_item(0)
	assert_array(item_1_cells_used).is_not_empty()
	var item_1_hash: int = item_1_cells_used.hash()
	assert_int(item_1_hash)\
		.override_failure_message("Layer 0 rendering of [b]TileMapGaeaRenderer[/b] area not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [item_1_hash, ITEM_1_TILES_HASH])\
		.is_equal(ITEM_1_TILES_HASH_SMALL)

	var item_2_cells_used: Array[Vector3i] = renderer.grid_maps[1].get_used_cells_by_item(1)
	assert_array(item_2_cells_used).is_not_empty()
	var item_2_hash: int = item_2_cells_used.hash()
	assert_int(item_2_hash)\
		.override_failure_message("Layer 1 rendering of [b]TileMapGaeaRenderer[/b] area not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [item_2_hash, ITEM_2_TILES_HASH])\
		.is_equal(ITEM_2_TILES_HASH_SMALL)

func test_null_layer() -> void:
	renderer.grid_maps[1] = null
	assert_error(scene.generator.generate)\
		.is_success()
