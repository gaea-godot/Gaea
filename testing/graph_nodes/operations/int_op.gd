extends "res://testing/graph_nodes/operations/num_op.gd"



func before():
	node = GaeaNodeIntOp.new()


func _get_failure_message() -> String:
	return "[b]GaeaNodeIntOp[/b] returned an unexpected value with operation [b]%s[/b]." % GaeaNodeIntOp.Operation.keys()[node.get_enum_selection(0)]


func test_add() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.ADD)
	_assert_operation_result([2, 1], 3)
	_assert_operation_result([1, -1], 0)


func test_subtract() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.SUBTRACT)
	_assert_operation_result([2, 1], 1)
	_assert_operation_result([1, -1], 2)


func test_multiply() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.MULTIPLY)
	_assert_operation_result([4, 2], 8)
	_assert_operation_result([4, -2], -8)


func test_divide() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.DIVIDE)
	_assert_operation_result([2, 1], 2)
	_assert_operation_result([4, -2], -2)


func test_power() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.POWER)
	_assert_operation_result([2, 2], 4)
	_assert_operation_result([1, 0], 1)


func test_min_and_max() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.MAX)
	_assert_operation_result([1, 2], 2)

	node.set_enum_value(0, GaeaNodeIntOp.Operation.MIN)
	_assert_operation_result([1, 2], 1)


func test_abs() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.ABS)
	_assert_operation_result([-2], 2)



func test_clamp() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.CLAMP)
	_assert_operation_result([-999, 0, 1], 0)
	_assert_operation_result([999, 0, 1], 1)


func test_sign() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.SIGN)
	_assert_operation_result([1], 1)
	_assert_operation_result([-1], -1)
	_assert_operation_result([0], 0)


func test_step() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.STEP)
	_assert_operation_result([2, 1], 1)
	_assert_operation_result([0, 1], 0)
	_assert_operation_result([1, 1], 1)


func test_wrap() -> void:
	node.set_enum_value(0, GaeaNodeIntOp.Operation.WRAP)
	_assert_operation_result([3, 0, 2], 1)
	_assert_operation_result([1, 0, 2], 1)
