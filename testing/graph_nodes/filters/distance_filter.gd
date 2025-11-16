extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const MIN_DISTANCE: float = 2.0
const MAX_DISTANCE: float = 4.0


func test_distance_filter() -> void:
	node = GaeaNodeDistanceFilter.new()

	var input := GaeaValue.Sample.new()
	input.fill(AREA, 1.0)
	var expected_grid: Dictionary
	for cell in input.get_cells():
		var distance := Vector3(cell).distance_squared_to(Vector3.ZERO)
		if distance <= MAX_DISTANCE ** 2 and distance >= MIN_DISTANCE ** 2:
			expected_grid.set(cell, input.get_cell(cell))
	var expected_hash: int = expected_grid.hash()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"distance_range": {"min": MIN_DISTANCE, "max": MAX_DISTANCE}, &"input_grid": input  }, &"filtered_grid"
	)


	for cell in grid.get_cells():
		var distance := Vector3(cell).distance_squared_to(Vector3.ZERO)
		assert_float(distance)\
			.override_failure_message("Distance check failed in [b]%s[/b]" % node.get_tree_name())\
			.is_between(MIN_DISTANCE ** 2, MAX_DISTANCE ** 2)

		if is_failure():
			return
