extends GdUnitTestSuite


const GRASS_TILES_HASH := 1593514366
const SAND_TILES_HASH := 1550241141
const GRASS_TILES_HASH_SMALL := 2384678874
const SAND_TILES_HASH_SMALL := 1850823263


var scene: Node2D
var runner: GdUnitSceneRunner


func before() -> void:
	scene = load("uid://xfcy8wwh3sd7").instantiate()
	runner = scene_runner(scene)


func test_full_area() -> void:
	scene.generator.generate()
	await scene.generator.generation_finished

	var grass_hash: int = scene.renderer.tile_map_layers[0].get_used_cells_by_id(0, Vector2i(0, 0)).hash()
	assert_int(grass_hash)\
		.override_failure_message("Layer 0 rendering of [b]TileMapGaeaRenderer[/b] not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [grass_hash, GRASS_TILES_HASH])\
		.is_equal(GRASS_TILES_HASH)

	var sand_hash: int = scene.renderer.tile_map_layers[1].get_used_cells_by_id(0, Vector2i(1, 0)).hash()
	assert_int(sand_hash)\
		.override_failure_message("Layer 1 rendering of [b]TileMapGaeaRenderer[/b] not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [sand_hash, SAND_TILES_HASH])\
		.is_equal(SAND_TILES_HASH)


func test_reset() -> void:
	scene.generator.request_reset()
	assert_array(scene.renderer.tile_map_layers[0].get_used_cells())\
		.override_failure_message("[b]TileMapGaeaRenderer[/b] wasn't cleared properly.")\
		.is_empty()
	assert_array(scene.renderer.tile_map_layers[1].get_used_cells())\
		.override_failure_message("[b]TileMapGaeaRenderer[/b] wasn't cleared properly.")\
		.is_empty()


func test_small_area() -> void:
	var area: AABB = AABB(Vector3.ZERO, Vector3.ONE * 16)
	scene.generator.generate_area(area)
	await scene.generator.generation_finished

	var grass_hash: int = scene.renderer.tile_map_layers[0].get_used_cells_by_id(0, Vector2i(0, 0)).hash()
	assert_int(grass_hash)\
		.override_failure_message("Layer 0 rendering of [b]TileMapGaeaRenderer[/b] area not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [grass_hash, GRASS_TILES_HASH_SMALL])\
		.is_equal(GRASS_TILES_HASH_SMALL)

	var sand_hash: int = scene.renderer.tile_map_layers[1].get_used_cells_by_id(0, Vector2i(1, 0)).hash()
	assert_int(sand_hash)\
		.override_failure_message("Layer 1 rendering of [b]TileMapGaeaRenderer[/b] area not working as expected.")\
		.append_failure_message("Produced hash:%s\n Expected hash:%s" % [sand_hash, SAND_TILES_HASH_SMALL])\
		.is_equal(SAND_TILES_HASH_SMALL)

	assert_vector(scene.renderer.tile_map_layers[0].get_used_rect().size)\
		.override_failure_message("Rendered [b]TileMapGaeaRenderer[/b] area was bigger than expected.")\
		.is_less_equal(Vector2i(area.size.x, area.size.y))
	assert_vector(scene.renderer.tile_map_layers[1].get_used_rect().size)\
		.override_failure_message("Rendered [b]TileMapGaeaRenderer[/b] area was bigger than expected.")\
		.is_less_equal(Vector2i(area.size.x, area.size.y))


func test_null_layer() -> void:
	scene.renderer.tile_map_layers[1] = null
	assert_error(scene.generator.generate)\
		.is_success()
