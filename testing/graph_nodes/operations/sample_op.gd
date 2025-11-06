extends "res://testing/graph_nodes/operations/float_op.gd"


func before():
	node = GaeaNodeSampleOp.new()


func _assert_operation_result(args: Array[Variant], expected: float) -> void:
	for i in node.get_arguments_list().size():
		if node.get_argument_type(node.get_arguments_list()[i]) == GaeaValue.Type.SAMPLE:
			var sample := GaeaValue.Sample.new()
			sample.set_cell(Vector3i.ZERO, args[i])
			sample.set_cell(Vector3i(1, 1, 0), args[i])
			sample.set_cell(Vector3i(1, 0, 0), args[i])
			sample.set_cell(Vector3i(0, 1, 0), args[i])
			args[i] = sample
		node.set_argument_value(node.get_arguments_list()[i], args[i])
	var grid: GaeaValue.Sample = node._get_data(&"result", AABB(), null)
	assert_bool(grid.is_empty())\
		.override_failure_message("[b]GaeaNodeSampleOp[/b] returned an empty grid with operation [b]%s[/b]."
			% GaeaNodeSampleOp.Operation.keys()[node.get_enum_selection(0)])\
		.is_false()

	for cell in grid.get_cells():
		var result: float = grid.get_cell(cell)
		assert_float(result)\
			.override_failure_message(_get_failure_message())\
			.append_failure_message(
				"Arguments: %s\n Expected result: %s\n Returned result: %s\n At cell: %s"
				 % [args, expected, result, cell])\
			.is_equal(expected)


func _get_failure_message() -> String:
	return "[b]GaeaNodeSampleOp[/b] returned an unexpected value with operation [b]%s[/b]." % GaeaNodeSampleOp.Operation.keys()[node.get_enum_selection(0)]
