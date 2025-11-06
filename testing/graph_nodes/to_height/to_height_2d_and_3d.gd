extends GdUnitTestSuite


const AREA: AABB = AABB(Vector3.ZERO, Vector3(1, 4, 1) * 16)
const EXPECTED_HASH_2D: int = 3725516071
const EXPECTED_HASH_3D: int = 2178371583

var reference: GaeaValue.Sample = GaeaValue.Sample.new()
var node: GaeaNodeToHeight


func before() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	for x in range(AREA.position.x, AREA.end.x):
		for z in range(AREA.position.z, AREA.end.z):
			reference.set_xyz(x, 1, z, noise.get_noise_3d(x, 0, z))
	node = GaeaNodeToHeight.new()
	node.set_argument_value(&"reference", reference)
	node.set_argument_value(&"reference_y", 1)


func test_2d() -> void:
	node.set_enum_value(0, GaeaNodeToHeight.Type.TYPE_2D)
	node.set_argument_value(&"height_offset", -4)
	var generated_data: GaeaValue.Sample = node._get_data(&"sample", AREA, null)
	assert_bool(generated_data.is_empty())\
		.override_failure_message("Empty result from [b]GaeaNodeToHeight2D[/b].")\
		.is_false()
	assert_int(generated_data._grid.hash())\
		.override_failure_message("Unexpected result from [b]GaeaNodeToHeight2D[/b].")\
		.append_failure_message("Generated: %s\nExpected: %s" % [generated_data._grid.hash(), EXPECTED_HASH_2D])\
		.is_equal(EXPECTED_HASH_2D)


func test_3d() -> void:
	node.set_enum_value(0, GaeaNodeToHeight.Type.TYPE_3D)
	node.set_argument_value(&"height_offset", 4)
	var generated_data: GaeaValue.Sample = node._get_data(&"sample", AREA, null)
	assert_bool(generated_data.is_empty())\
		.override_failure_message("Empty result from [b]GaeaNodeToHeight3D[/b].")\
		.is_false()
	assert_int(generated_data._grid.hash())\
		.override_failure_message("Unexpected result from [b]GaeaNodeToHeight3D[/b].")\
		.append_failure_message("Generated: %s\nExpected: %s" % [generated_data._grid.hash(), EXPECTED_HASH_3D])\
		.is_equal(EXPECTED_HASH_3D)
