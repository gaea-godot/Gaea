@tool
extends GaeaNodeMapper
class_name GaeaNodeFlagsMapper
## Maps every cell of [param data] that matches the flag conditions to [param material].
##
## Flags are [code]int[/code]s, so the filtering is done with the rounded value
## of each cell of [param data], using a bitwise [code]AND[/code].[br]
## If [param match_all] is [code]false[/code], the value has to pass the filter for only
## one of the flags in [param match_flags] to be mapped.[br]
## If a value matches [b]any[/b] of the [param exclude_flags], the cell's excluded from the output.


func _get_title() -> String:
	return "FlagsMapper"


func _get_description() -> String:
	return "Maps every cell of [param reference_data] that matches the flag conditions to [param material]."


func _get_arguments_list() -> Array[StringName]:
	return super() + ([&"match_all", &"match_flags", &"exclude_flags"] as Array[StringName])


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"match_all": return GaeaValue.Type.BOOLEAN
		&"match_flags": return GaeaValue.Type.FLAGS
		&"exclude_flags": return GaeaValue.Type.FLAGS
	return super(arg_name)


func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, graph: GaeaGraph) -> bool:
	var match_all: bool = _get_arg(&"match_all", area, graph)
	var flags: Array = _get_arg(&"match_flags", area, graph)
	var exclude_flags: Array = _get_arg(&"exclude_flags", area, graph)

	var value: float = grid_data.get(cell)
	if match_all:
		return flags.all(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))
	else:
		return flags.any(_matches_flag.bind(value)) and not exclude_flags.any(_matches_flag.bind(value))


func _matches_flag(value: float, flag: int) -> bool:
	return roundi(value) & flag
