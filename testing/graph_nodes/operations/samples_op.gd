extends GdUnitTestSuite


var node: GaeaNodeSamplesOp


func before():
	node = GaeaNodeSamplesOp.new()


func _assert_operation_result(args: Array[Variant], expected: float) -> void:
	for i in node.get_arguments_list().size():
		if node.get_argument_type(node.get_arguments_list()[i]) == GaeaValue.Type.SAMPLE:
			args[i] = {Vector3i.ZERO: args[i], Vector3i(1, 1, 0): args[i], Vector3i(1, 0, 0): args[i], Vector3i(0, 1, 0): args[i]}
		node.set_argument_value(node.get_arguments_list()[i], args[i])
	var grid: Dictionary = node._get_data(&"result", AABB(), null)
	assert_dict(grid)\
		.override_failure_message("[b]GaeaNodeDataOp[/b] returned an empty grid with operation [b]%s[/b]."
			% GaeaNodeSamplesOp.Operation.keys()[node.get_enum_selection(0)])\
		.is_not_empty()

	for cell in grid:
		var result: float = grid.get(cell)
		assert_float(result)\
			.override_failure_message(
				"[b]GaeaNodeSamplesOp[/b] returned an unexpected value with operation [b]%s[/b]."
				% GaeaNodeSamplesOp.Operation.keys()[node.get_enum_selection(0)]
				)\
			.append_failure_message(
				"Arguments: %s\n Expected result: %s\n Returned result: %s\n At cell: %s"
				 % [args, expected, result, cell])\
			.is_equal(expected)


func test_add() -> void:
	node.set_enum_value(0, GaeaNodeSamplesOp.Operation.ADD)
	_assert_operation_result([2.0, 1.0], 3.0)
	_assert_operation_result([1.0, -0.5], 0.5)


func test_subtract() -> void:
	node.set_enum_value(0, GaeaNodeSamplesOp.Operation.SUBTRACT)
	_assert_operation_result([2.0, 1.0], 1.0)
	_assert_operation_result([1.0, -0.5], 1.5)


func test_multiply() -> void:
	node.set_enum_value(0, GaeaNodeSamplesOp.Operation.MULTIPLY)
	_assert_operation_result([4.0, 2.0], 8.0)
	_assert_operation_result([4.0, -2.0], -8.0)


func test_divide() -> void:
	node.set_enum_value(0, GaeaNodeFloatOp.Operation.DIVIDE)
	_assert_operation_result([2.0, 1.0], 2.0)
	_assert_operation_result([1.0, -0.5], -2.0)


func test_lerp() -> void:
	node.set_enum_value(0, GaeaNodeSamplesOp.Operation.LERP)
	_assert_operation_result([1.0, 2.0, 0.5], 1.5)
	_assert_operation_result([1.0, -0.5, 0.5], 0.25)
