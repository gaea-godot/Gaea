extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))


func test_basic_mapper() -> void:
	node = GaeaNodeBasicMapper.new()

	var reference := GaeaValue.Sample.new()
	reference.fill(AREA, 1.0)

	var expected_hash: int = reference._grid.keys().hash()
	var material := TileMapGaeaMaterial.new()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"reference": reference, &"material": material  }, &"map"
	)

	for cell in grid.get_cells():
		assert_object(material)\
			.override_failure_message("Wrong material mapped in [b]%s[/b]" % node.get_tree_name())\
			.is_same(grid.get_cell(cell))

		if is_failure():
			return
