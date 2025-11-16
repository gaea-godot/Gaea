extends GdUnitTestSuite


var node: GaeaNodeResource
var generation_settings: GaeaGenerationSettings


func _assert_output_grid_matches(
	area: AABB, expected_hash: int, empty: bool,
	args: Dictionary[StringName, Variant], output: StringName
) -> GaeaValue.GridType:
	for arg_name in args:
		node.set_argument_value(arg_name, args[arg_name])

	generation_settings = GaeaGenerationSettings.new()
	var pouch := GaeaGenerationPouch.new(generation_settings, area)
	node._define_rng(0)

	var generated_data: GaeaValue.GridType = node._get_data(output, null, pouch)
	assert_bool(is_instance_valid(generated_data))\
		.override_failure_message(
			"Invalid result from [b]%s[b]" % node.get_tree_name()
		)\
		.is_true()
	if is_failure():
		return generated_data

	assert_bool(generated_data.is_empty())\
		.override_failure_message(
			"%s result from [b]%s[b]" % ["Empty" if not empty else "Non-empty", node.get_tree_name()]
		)\
		.is_equal(empty)
	if is_failure():
		return generated_data

	var generated_hash: int = generated_data._grid.hash()
	# For maps we compare only keys because resources change and affect the hash, even if
	# they're preloaded from a file.
	if generated_data is GaeaValue.Map:
		generated_hash = generated_data._grid.keys().hash()

	assert_int(generated_hash)\
		.override_failure_message("Unexpected result from [b]%s[/b]." % node.get_tree_name())\
		.append_failure_message(
			"Generated: %s\nExpected: %s" % [generated_hash, expected_hash]
		)\
		.is_equal(expected_hash)

	return generated_data


func after() -> void:
	node = null
	generation_settings = null
