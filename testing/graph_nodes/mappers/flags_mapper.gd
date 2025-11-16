extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const FLAG_1 := 1
const FLAG_2 := 2
const FLAG_3 := 4


func test_flags_mapper() -> void:
	node = GaeaNodeFlagsMapper.new()

	var reference := GaeaValue.Sample.new()
	reference.fill(AREA, FLAG_1 | FLAG_3)
	reference.set_cell(Vector3i.ONE, FLAG_1 | FLAG_2)
	reference.set_cell(Vector3i(1, 0, 0), FLAG_1)
	reference.set_cell(Vector3i(0, 1, 0), FLAG_3)
	var material := TileMapGaeaMaterial.new()

	var expected_hash: int = reference._grid.keys().filter(
		func(cell: Vector3i) -> bool:
			var value: int = roundi(reference.get_cell(cell))
			return (value & FLAG_1) and (value & FLAG_3) and not (value & FLAG_2)
	).hash()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"match_all": true, &"match_flags": [FLAG_1, FLAG_3], &"exclude_flags": [FLAG_2], &"reference": reference, &"material": material  },
		&"map"
	)

	assert_bool(grid.has(Vector3i.ONE))\
		.override_failure_message("Cell that should've been filtered wasn't in [b]%s[/b]" % node.get_tree_name())\
		.is_false()

	assert_int(grid._grid.size())\
	.override_failure_message("Cell that should've been filtered wasn't in [b]%s[/b]" % node.get_tree_name())\
		.is_equal(reference._grid.size() - 3)

	for cell in grid.get_cells():
		var value := roundi(reference.get_cell(cell))
		assert_bool(
			(value & FLAG_1) and (value & FLAG_3) and not (value & FLAG_2)
		)\
			.override_failure_message("Flag check failed in [b]%s[/b]" % node.get_tree_name())\
			.append_failure_message("[b]Cell:[/b] %s" % cell)\
			.is_true()

		if is_failure():
			return

		assert_object(material)\
			.override_failure_message("Wrong material mapped in [b]%s[/b]" % node.get_tree_name())\
			.is_same(grid.get_cell(cell))

		if is_failure():
			return
