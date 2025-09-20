@tool
@abstract
class_name GaeaNodeNumOp
extends GaeaNodeResource
## Base class for operations between 2 numbers.


enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	#REMAINDER,
	POWER,
	MAX,
	MIN,
	#SNAPPED,
	ABS,
	CEIL,
	CLAMP,
	FLOOR,
	ROUND,
	#LERP,
	#LOG,
	REMAP,
	SIGN,
	SMOOTHSTEP,
	STEP,
	WRAP,
}

class Definition:
	var args: Array[StringName]
	var output: String
	var conversion: Callable
	func _init(_args: Array[StringName], _output: String, _conversion: Callable):
		args = _args
		output = _output
		conversion = _conversion


## All possible operations.
var OPERATION_DEFINITIONS: Dictionary[Operation, Definition] : get = _get_operation_definitions


func _get_description() -> String:
	match get_enum_selection(0):
		Operation.POWER:
			return "Returns the value of [param base] raised to the power of [param exp]."
		Operation.MAX:
			return "Returns the maximum between [param a] and [param b]."
		Operation.MIN:
			return "Returns the minimum between [param a] and [param b]."
		Operation.ABS:
			return "Returns the absolute value of [param a]."
		Operation.CLAMP:
			return "Constrains [param a] to lie between [param min] and [param max] (inclusive)."
		Operation.REMAP:
			return "Maps [param a] from range [code][istart, istop][/code] to [code][ostart, ostop][/code]."
		Operation.CEIL:
			return "Finds the nearest integer that is greater or equal to [param a]."
		Operation.FLOOR:
			return "Finds the nearest integer that is lower or equal to [param a]."
		Operation.ROUND:
			return "Finds the nearest integer to [param a]."
		Operation.SIGN:
			return "Returns [code]-1[/code] for negative numbers, [code]1[/code] for positive numbers and [code]0[/code] for zeroes."
		Operation.SMOOTHSTEP:
			return "Returns [code]0[/code] if [param a] < [param from], [code]1[/code] if [param a] > [param to], otherwise returns an interpolated value between [code]0[/code] and [code]1[/code]."
		Operation.STEP:
			return "Returns [code]0[/code] if [param a] < [param edge], otherwise [code]1[/code]."
		Operation.WRAP:
			return "Wraps [param a] between [param min] and [param max]."
	return super()


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	items.append_array(super())
	for operation in OPERATION_DEFINITIONS.keys():
		var item: GaeaNodeResource = get_script().new()
		item.set_tree_name_override("%s (%s)" % [Operation.find_key(operation).to_pascal_case(), OPERATION_DEFINITIONS[operation].output] )
		item.set_default_enum_value_override(0, operation)
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var options: Dictionary = {}

	for operation in OPERATION_DEFINITIONS.keys():
		options.set(Operation.find_key(operation), operation)

	return options


func _get_arguments_list() -> Array[StringName]:
	return OPERATION_DEFINITIONS.get(get_enum_selection(0)).args


func _get_argument_display_name(arg_name: StringName) -> String:
	return arg_name


func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return get_type()



func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"result"]


func _get_output_port_display_name(_output_name: StringName) -> String:
	return OPERATION_DEFINITIONS[get_enum_selection(0)].output



func _get_data(_output_port: StringName, _area: AABB, graph: GaeaGraph) -> Variant:
	var operation: Operation = get_enum_selection(0) as Operation
	var args: Array
	for arg_name: StringName in OPERATION_DEFINITIONS[operation].args:
		args.append(_get_arg(arg_name, _area, graph))
	return _get_new_value(operation, args)


func _get_new_value(operation: Operation, args: Array) -> Variant:
	return OPERATION_DEFINITIONS[operation].conversion.callv(args)


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	if not OPERATION_DEFINITIONS.is_empty():
		return OPERATION_DEFINITIONS

	OPERATION_DEFINITIONS = {
		Operation.ADD:
			Definition.new([&"a", &"b"], "a + b", func(a: Variant, b: Variant): return a + b),
		Operation.SUBTRACT:
			Definition.new([&"a", &"b"], "a - b", func(a: Variant, b: Variant): return a - b),
		Operation.MULTIPLY:
			Definition.new([&"a", &"b"], "a * b", func(a: Variant, b: Variant): return a * b),
		Operation.DIVIDE:
			Definition.new([&"a", &"b"], "a / b", func(a: Variant, b: Variant): return 0 if is_zero_approx(b) else a / b),
		#Operation.REMAINDER:
			#Definition.new([&"a", &"b"], "a % b", func(a: float, b: float): return 0.0 if is_zero_approx(b) else fmod(a, b)),
		Operation.POWER:
			Definition.new([&"base", &"exp"], "base ** exp", pow),
		Operation.MAX:
			Definition.new([&"a",&"b"], "max(a, b)", max),
		Operation.MIN:
			Definition.new([&"a",&"b"], "min(a, b)", min),
		#Operation.SNAPPED:
			#Definition.new([&"a", "Step"], "snapped(a, step)", snapped),
		Operation.ABS:
			Definition.new([&"a"], "abs(a)", abs),
		Operation.CEIL:
			Definition.new([&"a"], "ceil(a)", ceil),
		Operation.FLOOR:
			Definition.new([&"a"], "floor(a)", floor),
		Operation.ROUND:
			Definition.new([&"a"], "round(a)", round),
		Operation.CLAMP:
			Definition.new([&"a", &"min", &"max"], "clamp(a, min, max)", clamp),
		#Operation.LERP:
			#Definition.new([&"from", &"to", &"weight"], "lerpf(from, to, weight)", lerpf),
		#Operation.LOG:
			#Definition.new([&"a"], "log(a)", log),
		Operation.REMAP:
			Definition.new(
				[&"a", &"in_start", &"in_stop", &"out_start", &"out_stop"],
				"remap(a, ...)",
				remap
			),
		Operation.SIGN:
			Definition.new([&"a"], "sign(a)", sign),
		Operation.SMOOTHSTEP:
			Definition.new([&"from", &"to", &"a"], "smoothstep(from, to, a)", smoothstep),
		Operation.STEP:
			Definition.new([&"a", &"edge"], "step(a, edge)", func(a, edge): return 0 if a < edge else 1),
		Operation.WRAP:
			Definition.new([&"a", &"min", &"max"], "wrap(a, min, max)", wrap),
	}
	return OPERATION_DEFINITIONS
