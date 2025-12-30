extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const EXPECTED_HASH_SAMPLE: int = 3535671914
const EXPECTED_HASH_MAP: int = 3275546833
const CHANCE: float = 50.0


func test_random_filter() -> void:
	node = GaeaNodeRandomFilter.new()

	var input := GaeaValue.Sample.new()
	input.fill(AREA, 1.0)

	var grid := _assert_output_grid_matches(
		AREA, EXPECTED_HASH_SAMPLE, false,
		{ &"chance": CHANCE, &"input_grid": input  }, &"filtered_grid"
	)

	var ratio_difference: float = abs(
		float(grid._grid.size()) / float(input._grid.size()) - (CHANCE / 100.0)
	)

	assert_float(ratio_difference)\
		.override_failure_message("Unexpected result from [b]%s[/b]." % node.get_tree_name())\
		.is_less(0.01)


func test_map_random_filter() -> void:
	node = GaeaNodeMapRandomFilter.new()

	var input := GaeaValue.Map.new()
	input.fill(AREA, TileMapGaeaMaterial.new())
	var grid := _assert_output_grid_matches(
		AREA, EXPECTED_HASH_MAP, false,
		{ &"chance": CHANCE, &"input_grid": input  }, &"filtered_grid"
	)

	var ratio_difference: float = abs(
		float(grid._grid.size()) / float(input._grid.size()) - (CHANCE / 100.0)
	)

	assert_float(ratio_difference)\
		.override_failure_message("Unexpected result from [b]%s[/b]." % node.get_tree_name())\
		.is_less(0.01)
