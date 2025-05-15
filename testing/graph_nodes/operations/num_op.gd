extends GdUnitTestSuite


var node: GaeaNodeNumOp


func before():
	pass


func _assert_operation_result(args: Array[Variant], expected: float) -> void:
	for i in node.get_arguments_list().size():
		node.set_argument_value(node.get_arguments_list()[i], args[i])
	var result: float = node._get_data(&"result", AABB(), null)
	assert_that(result)\
		.override_failure_message(
			"[b]GaeaNodeFloatOp[/b] returned an unexpected value with operation [b]%s[/b]."
			% GaeaNodeFloatOp.Operation.keys()[node.get_enum_selection(0)]
			)\
		.append_failure_message("Arguments: %s\n Expected result: %s\n Returned result: %s" % [args, expected, result])\
		.is_equal(expected)
