extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(16, 16, 16))
const MIN: float = 0.5
const MAX: float = 1.0


func test_threshold_mapper() -> void:
	node = GaeaNodeThresholdMapper.new()

	var reference := GaeaValue.Sample.new()
	reference.fill(AREA, randf_range(MIN, MAX))
	reference.set_cell(Vector3.ONE, 0.0)
	reference.set_cell(Vector3.LEFT, 1.5)
	var material := TileMapGaeaMaterial.new()

	var expected_hash: int = reference._grid.keys().filter(
		func(cell: Vector3i) -> bool:
			return reference.get_cell(cell) >= MIN and reference.get_cell(cell) <= MAX
	).hash()

	var grid := _assert_output_grid_matches(
		AREA, expected_hash, false,
		{ &"range": {"min": MIN, "max": MAX}, &"reference": reference, &"material": material  }, &"map"
	)

	for cell in grid.get_cells():
		assert_float(reference.get_cell(cell))\
			.override_failure_message("Threshold check failed in [b]%s[/b]" % node.get_tree_name())\
			.is_between(MIN, MAX)

		if is_failure():
			return

		assert_object(material)\
			.override_failure_message("Wrong material mapped in [b]%s[/b]" % node.get_tree_name())\
			.is_same(grid.get_cell(cell))

		if is_failure():
			return
