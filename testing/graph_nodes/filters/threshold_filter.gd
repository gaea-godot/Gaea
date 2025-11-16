extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const MIN: float = 0.5
const MAX: float = 1.0


func test_threshold_filter() -> void:
	node = GaeaNodeThresholdFilter.new()

	var input := GaeaValue.Sample.new()
	input.fill(AREA, randf_range(MIN, MAX))
	input.set_cell(Vector3.ONE, 0.0)
	input.set_cell(Vector3.LEFT, 1.5)

	var expected_grid: Dictionary
	for cell in input.get_cells():
		if input.get_cell(cell) <= MAX and input.get_cell(cell) >= MIN:
			expected_grid.set(cell, input.get_cell(cell))
	var expected_hash: int = expected_grid.hash()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"range": {"min": MIN, "max": MAX}, &"input_grid": input  }, &"filtered_grid"
	)

	for cell in grid.get_cells():
		assert_float(grid.get_cell(cell))\
			.override_failure_message("Threshold check failed in [b]%s[/b]" % node.get_tree_name())\
			.is_between(MIN, MAX)

		if is_failure():
			return
