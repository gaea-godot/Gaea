extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const EXPECTED_HASH: int = 1940479643
const MIN: float = 0.5
const MAX: float = 1.0


func test_threshold_filter() -> void:
	node = GaeaNodeThresholdFilter.new()

	var input := GaeaValue.Sample.new()
	input.fill(AREA, 0.75)
	input.set_cell(Vector3.ONE, 0.0)
	input.set_cell(Vector3.LEFT, 1.5)
	var grid := _assert_output_grid_matches(
		AREA, EXPECTED_HASH, false,
		{ &"range": {"min": MIN, "max": MAX}, &"input_grid": input  }, &"filtered_grid"
	)

	for cell in grid.get_cells():
		assert_float(grid.get_cell(cell))\
			.override_failure_message("Threshold check failed in [b]%s[/b]" % node.get_tree_name())\
			.is_between(MIN, MAX)

		if is_failure():
			return
