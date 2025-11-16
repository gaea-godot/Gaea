extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const FLAG_1 := 1
const FLAG_2 := 2
const FLAG_3 := 4


func test_flags_filter() -> void:
	node = GaeaNodeFlagsFilter.new()

	var input := GaeaValue.Sample.new()
	input.fill(AREA, FLAG_1 | FLAG_3)
	input.set_cell(Vector3i.ONE, FLAG_1 | FLAG_2)
	input.set_cell(Vector3i(1, 0, 0), FLAG_1)
	input.set_cell(Vector3i(0, 1, 0), FLAG_3)

	var expected_grid: Dictionary
	for cell in input.get_cells():
		var value: int = roundi(input.get_cell(cell))
		if (value & FLAG_1) and (value & FLAG_3) and not (value & FLAG_2):
			expected_grid.set(cell, input.get_cell(cell))
	var expected_hash: int = expected_grid.hash()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"match_all": true, &"match_flags": [FLAG_1, FLAG_3], &"exclude_flags": [FLAG_2], &"input_grid": input  },
		&"filtered_grid"
	)

	assert_bool(grid.has(Vector3i.ONE))\
		.override_failure_message("Cell that should've been filtered wasn't in [b]%s[/b]" % node.get_tree_name())\
		.is_false()

	assert_int(grid._grid.size())\
	.override_failure_message("Cell that should've been filtered wasn't in [b]%s[/b]" % node.get_tree_name())\
		.is_equal(input._grid.size() - 3)

	for cell in grid.get_cells():
		var value := roundi(grid.get_cell(cell))
		assert_bool(
			(value & FLAG_1) and (value & FLAG_3) and not (value & FLAG_2)
		)\
			.override_failure_message("Flag check failed in [b]%s[/b]" % node.get_tree_name())\
			.append_failure_message("[b]Cell:[/b] %s" % cell)\
			.is_true()

		if is_failure():
			return
