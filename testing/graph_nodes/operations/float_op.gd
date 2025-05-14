extends GdUnitTestSuite


var node: GaeaNodeFloatOp

class Result:
	var inputs: Array[float]
	var expected: float
	func _init(inp, expc) -> void:
		inputs = inp
		expected = expc

# Of the form Operation: [tests]
static var EXPECTED: Dictionary[GaeaNodeFloatOp.Operation, Array] = {
	GaeaNodeFloatOp.Operation.ADD: 
		[Result.new([2.0, 1.0], 3.0), Result.new([1.0, -0.5], 0.5)],
	GaeaNodeFloatOp.Operation.SUBTRACT: 
		[Result.new([2.0, 1.0], 1.0), Result.new([1.0, -0.5], 1.5)],
}


func before() -> void:
	node = GaeaNodeFloatOp.new()


func test_add() -> void:
	node.set_enum_value(0, GaeaNodeFloatOp.Operation.ADD)
	node.set_argument_value(&"a", 2.0)
	node.set_argument_value(&"b", 1.0)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(3.0)
	node.set_argument_value(&"a", -0.5)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(0.5)


func test_subtract() -> void:
	node.set_enum_value(0, GaeaNodeFloatOp.Operation.SUBTRACT)
	node.set_argument_value(&"a", 2.0)
	node.set_argument_value(&"b", 1.0)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(1.0)
	node.set_argument_value(&"a", -0.5)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(-1.5)


func test_multiply() -> void:
	node.set_enum_value(0, GaeaNodeFloatOp.Operation.MULTIPLY)
	node.set_argument_value(&"a", 2.0)
	node.set_argument_value(&"b", 4.0)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(8.0)
	node.set_argument_value(&"a", -0.5)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(-2.0)


func test_divide() -> void:
	node.set_enum_value(0, GaeaNodeFloatOp.Operation.DIVIDE)
	node.set_argument_value(&"a", 4.0)
	node.set_argument_value(&"b", 2.0)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(2.0)
	node.set_argument_value(&"a", -5.0)
	await assert_float(node._get_data(&"result", AABB(), null)).is_equal(-2.5)
