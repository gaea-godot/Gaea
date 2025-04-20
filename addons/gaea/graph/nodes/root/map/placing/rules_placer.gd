@tool
extends GaeaNodeResource
class_name GaeaNodeRulesPlacer
## Places [param material] on every world cell that follows [param rules] based on [param reference_data].
## [img]res://addons/gaea/assets/cross.svg[/img] means data DOESN'T have a cell there,
## [img]res://addons/gaea/assets/check.svg[/img] means the opposite.
##
## For every cell in the generation area, it checks that it follows [param rules]. If it does,
## it places [param material] in that cell.[br]
## The outlined cell is the origin. Every other cell around it is in an offset from said cell.
## You can also think about it as the outlined cell having an offset of [code](0,0)[/code].[br]
## For every offset:[br]
## - If the editor has no icon, that offset has no rule. It is ignored.[br]
##     - If the offset is marked as [img]res://addons/gaea/assets/check.svg[/img], that offset has to have a corresponding cell in [param reference_data] to qualify as "following the rules".[br]
##     - If the offset is marked as [img]res://addons/gaea/assets/cross.svg[/img], it's the opposite.[br]
## If a cell doesn't follow all the rules for each offset, it won't qualify. Otherwise, the outputted [param map]
## will have [param material] there.


func _get_required_params() -> Array[StringName]:
	return [&"data", &"material"]


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data: Dictionary = _get_arg(&"data", area, generator_data)
	var material: GaeaMaterial = _get_arg(&"material", area, generator_data)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	var rules: Dictionary = _get_arg(&"rules", area, generator_data)

	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			for z in _get_axis_range(Axis.Z, area):
				var place: bool = true
				var cell: Vector3i = Vector3i(x, y, z)
				for offset: Vector2i in rules:
					var offset_3d: Vector3i = Vector3i(offset.x, offset.y, 0)
					if _is_point_outside_area(area, cell + offset_3d):
						place = false
						break

					if (grid_data.get(cell + offset_3d) != null) != rules.get(offset):
						place = false
						break
				if place:
					grid.set(cell, null if not is_instance_valid(material) else material.get_resource())

	return output_port.return_value(grid)
