extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))


func test_value_mapper() -> void:
	node = GaeaNodeValueMapper.new()

	var reference := GaeaValue.Sample.new()
	reference.fill(AREA, 1.0)
	reference.fill(AREA.grow(-2), 0.5)

	var expected_hash: int = reference._grid.keys().filter(
		func(cell: Vector3i) -> bool: return reference.get_cell(cell) == 0.5
	).hash()
	var material := TileMapGaeaMaterial.new()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"reference": reference, &"material": material, &"value": 0.5  }, &"map"
	)

	for cell in grid.get_cells():
		assert_float(reference.get_cell(cell))\
			.override_failure_message("Value check failed in [b]%s[/b]" % node.get_tree_name())\
			.is_equal(0.5)

		if is_failure():
			return

		assert_object(material)\
			.override_failure_message("Wrong material mapped in [b]%s[/b]" % node.get_tree_name())\
			.is_same(grid.get_cell(cell))

		if is_failure():
			return
