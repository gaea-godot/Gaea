extends GdUnitTestSuite


const AREA: AABB = AABB(Vector3.ZERO, Vector3(1, 4, 1) * 16)
const EXPECTED_HASH_2D: int = 1125934261
const EXPECTED_HASH_3D: int = 112159610

var reference_data: Dictionary = {}
var node: GaeaNodeToHeight


func before() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	for x in range(AREA.position.x, AREA.end.x):
		for z in range(AREA.position.z, AREA.end.z):
			reference_data[Vector3i(x, 0, z)] = noise.get_noise_3d(x, 0, z)
	node = GaeaNodeToHeight.new()
	node.set_argument_value(&"reference_data", reference_data)




func test_2d() -> void:
	node.set_enum_value(0, GaeaNodeToHeight.Type.TYPE_2D)
	node.set_argument_value(&"height_offset", -4)
	assert_int(node._get_data(&"data", AREA, null).hash())\
		.override_failure_message("Unexpected result from [b]GaeaNodeToHeight2D[/b].")\
		.is_equal(EXPECTED_HASH_2D)


func test_3d() -> void:
	node.set_enum_value(0, GaeaNodeToHeight.Type.TYPE_3D)
	node.set_argument_value(&"height_offset", 4)
	assert_int(node._get_data(&"data", AREA, null).hash())\
		.override_failure_message("Unexpected result from [b]GaeaNodeToHeight3D[/b].")\
		.is_equal(EXPECTED_HASH_3D)
