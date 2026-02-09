extends GdUnitTestSuite


var node: GaeaNodeNumOp


func before():
	pass


func _assert_operation_result(args: Array[Variant], expected: float) -> void:
	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(GaeaGenerationSettings.new(), AABB())
	pouch.settings.seed = 0
	var graph: GaeaGraph = GaeaGraph.new()
	graph.ensure_initialized()
	graph.add_node(node, Vector2i.ZERO)

	node._define_rng(pouch)

	for i in node.get_arguments_list().size():
		node.set_argument_value(node.get_arguments_list()[i], args[i])
	var result: float = node._get_data(&"result", pouch)
	assert_that(result)\
		.override_failure_message(_get_failure_message())\
		.append_failure_message("Arguments: %s\n Expected result: %s\n Returned result: %s" % [args, expected, result])\
		.is_equal(expected)


func _get_failure_message() -> String:
	return ""
