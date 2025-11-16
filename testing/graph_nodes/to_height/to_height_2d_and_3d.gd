extends "res://testing/test_grid_output_base.gd"


const AREA: AABB = AABB(Vector3.ZERO, Vector3(1, 4, 1) * 16)
const EXPECTED_HASH_2D: int = 3725516071
const EXPECTED_HASH_3D: int = 2178371583

var reference: GaeaValue.Sample = GaeaValue.Sample.new()

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
	_assert_output_grid_matches(
		AREA, EXPECTED_HASH_2D, false, { &"height_offset": -4 }, &"sample"
	)


func test_3d() -> void:
	node.set_enum_value(0, GaeaNodeToHeight.Type.TYPE_3D)
	_assert_output_grid_matches(
		AREA, EXPECTED_HASH_3D, false, { &"height_offset": 4 }, &"sample"
	)
