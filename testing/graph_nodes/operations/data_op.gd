extends "res://testing/graph_nodes/operations/float_op.gd"



func before():
	node = GaeaNodeDataOp.new()


func _assert_operation_result(args: Array[Variant], expected: float) -> void:
	for i in node.get_arguments_list().size():
		if node.get_argument_type(node.get_arguments_list()[i]) == GaeaValue.Type.DATA:
			args[i] = {Vector3i.ZERO: args[i], Vector3i(1, 1, 0): args[i], Vector3i(1, 0, 0): args[i], Vector3i(0, 1, 0): args[i]}
		node.set_argument_value(node.get_arguments_list()[i], args[i])
	var grid: Dictionary = node._get_data(&"result", AABB(), null)
	assert_dict(grid)\
		.override_failure_message("[b]GaeaNodeDataOp[/b] returned an empty grid with operation [b]%s[/b]."
			% GaeaNodeDataOp.Operation.keys()[node.get_enum_selection(0)])\
		.is_not_empty()

	for cell in grid:
		var result: float = grid.get(cell)
		assert_float(result)\
			.override_failure_message(_get_failure_message())\
			.append_failure_message(
				"Arguments: %s\n Expected result: %s\n Returned result: %s\n At cell: %s"
				 % [args, expected, result, cell])\
			.is_equal(expected)


func _get_failure_message() -> String:
	return "[b]GaeaNodeDataOp[/b] returned an unexpected value with operation [b]%s[/b]." % GaeaNodeDataOp.Operation.keys()[node.get_enum_selection(0)]
