@tool
class_name GaeaNodeFlagsFilter
extends GaeaNodeFilter
## Filters [param sample] to only the cells that match the flag conditions.
##
## Flags are [code]int[/code]s, so the filtering is done with the rounded value
## of each cell of [param sample], using a bitwise [code]AND[/code].[br]
## If [param match_all] is [code]false[/code], the value has to pass the filter for only
## one of the flags in [param match_flags].[br]
## If a value matches [b]any[/b] of the [param exclude_flags], it doesn't pass the filter.


func _get_title() -> String:
	return "FlagsFilter"


func _get_description() -> String:
	return "Filters [param sample] to only the cells that match the flag conditions."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"match_all", &"match_flags", &"exclude_flags"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"match_all":
			return GaeaValue.Type.BOOLEAN
		&"match_flags":
			return GaeaValue.Type.FLAGS
		&"exclude_flags":
			return GaeaValue.Type.FLAGS
	return super(arg_name)


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE


func _passes_filter(
	input_sample: GaeaValue.GridType, cell: Vector3i, args: Dictionary[StringName, Variant]
) -> bool:
	var flags: Array = args.get(&"match_flags")
	var exclude_flags: Array = args.get(&"exclude_flags")
	var match_all: bool = args.get(&"match_all")

	var value: float = input_sample.get_cell(cell)
	var matches_excluded_flags := exclude_flags.any(_matches_flag.bind(value))
	if match_all:
		var matches_all_flags := flags.all(_matches_flag.bind(value))
		return matches_all_flags and not matches_excluded_flags

	var matches_any_flags := flags.any(_matches_flag.bind(value))
	return matches_any_flags and not matches_excluded_flags


func _matches_flag(value: float, flag: int) -> bool:
	return roundi(value) & flag
