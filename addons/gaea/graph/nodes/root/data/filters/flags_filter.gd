@tool
extends GaeaNodeFilter
class_name GaeaNodeFlagsFilter
## Filters [param data] to only the cells that match the flag conditions.
##
## Flags are [code]int[/code]s, so the filtering is done with the rounded value
## of each cell of [param data], using a bitwise [code]AND[/code].[br]
## If [param match_all] is [code]false[/code], the value has to pass the filter for only
## one of the flags in [param match_flags].[br]
## If a value matches [b]any[/b] of the [param exclude_flags], it doesn't pass the filter.


func _passes_filter(input_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	var flags: Array = _get_arg(&"match_flags", area, generator_data)
	var exclude_flags: Array = _get_arg(&"exclude_flags", area, generator_data)
	var match_all: bool = _get_arg(&"match_all", area, generator_data)

	var value: float = input_data[cell]
	if match_all:
		return flags.all(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))
	else:
		return flags.any(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))


func _matches_flag(value: float, flag: int) -> bool:
	return roundi(value) & flag
