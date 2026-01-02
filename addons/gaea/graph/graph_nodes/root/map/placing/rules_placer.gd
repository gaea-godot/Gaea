@tool
class_name GaeaNodeRulesPlacer
extends GaeaNodeResource
#gdlint:disable = max-line-length
## Places [param material] on every world cell that follows [param rules] based on [param reference].
## [img]res://addons/gaea/assets/cross.svg[/img] means sample DOESN'T have a cell there,
## [img]res://addons/gaea/assets/check.svg[/img] means the opposite.
##
## For every cell in the generation area, it checks that it follows [param rules]. If it does,
## it places [param material] in that cell.[br]
## The outlined cell is the origin. Every other cell around it is in an offset from said cell.
## You can also think about it as the outlined cell having an offset of [code](0,0)[/code].[br]
## For every offset:[br]
## - If the editor has no icon, that offset has no rule. It is ignored.[br]
##     - If the offset is marked as [img]res://addons/gaea/assets/check.svg[/img],
## that offset has to have a corresponding cell in [param reference] to qualify as "following the rules".[br]
##     - If the offset is marked as [img]res://addons/gaea/assets/cross.svg[/img], it's the opposite.[br]
## If a cell doesn't follow all the rules for each offset, it won't qualify. Otherwise, the outputted [param map]
## will have [param material] there.
#gdlint:enable = max-line-length


func _get_title() -> String:
	return "RulesPlacer"


func _get_description() -> String:
	return """Places [param material] on every world cell that follows [param rules] based on [param reference].
[img]res://addons/gaea/assets/cross.svg[/img] means sample DOESN'T have a cell there,\
[img]res://addons/gaea/assets/check.svg[/img] means the opposite."""


func _get_enums_count() -> int:
	return 2


func _get_enum_options(enum_idx: int) -> Dictionary:
	match enum_idx:
		0:
			return GaeaCheckableCell.CoordinateFormat
		1:
			var options = {}
			for i in range(1, 6, 1):
				options.set("Radius %d" % i, i)
			return options
	return {}


func _get_enum_option_display_name(enum_idx: int, option_value: int) -> String:
	match enum_idx:
		0:
			return super(enum_idx, option_value).trim_suffix("d") + "D"
	return super(enum_idx, option_value)


func _get_enum_default_value(enum_idx: int) -> int:
	match enum_idx:
		1:
			return 2
	return super(enum_idx)


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_arguments_list() -> Array[StringName]:
	return [&"reference", &"material", &"rules"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"reference": return GaeaValue.Type.SAMPLE
		&"material": return GaeaValue.Type.MATERIAL
		&"rules": return GaeaValue.Type.RULES
	return GaeaValue.Type.NULL


func _get_argument_hint(arg_name: StringName) -> Dictionary[String, Variant]:
	if arg_name == &"rules":
		return {
			&"check_mode": GaeaCheckableCell.CheckMode.TRISTATE,
			&"show_origin": true,
			&"coordinate_format": get_enum_selection(0),
			&"radius": get_enum_selection(1),
		}
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"map"]


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.MAP


func _get_required_arguments() -> Array[StringName]:
	return [&"reference", &"material"]


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> GaeaValue.Map:
	var reference_sample: GaeaValue.Sample = _get_arg(&"reference", graph, pouch)
	var material: GaeaMaterial = _get_arg(&"material", graph, pouch)
	var result: GaeaValue.Map = GaeaValue.Map.new()

	var rules: Dictionary = _get_arg(&"rules", graph, pouch)

	material = material.prepare_sample(rng)
	if not is_instance_valid(material):
		material = _get_arg(&"material", graph, pouch)
		_log_error(
			"Recursive limit reached (%d): Invalid material provided at %s" % [GaeaMaterial.RECURSIVE_LIMIT, material.resource_path],
			graph,
			id
		)
		return result

	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				var place: bool = true
				var cell: Vector3i = Vector3i(x, y, z)
				for offset: Vector3i in rules:
					if _is_point_outside_area(pouch.area, cell + offset):
						place = false
						break

					if reference_sample.has(cell + offset) != rules.get(offset):
						place = false
						break
				if place:
					result.set_cell(cell, material.execute_sample(rng, reference_sample.get_cell(cell, 0.0)))

	return result
