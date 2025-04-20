@tool
extends GaeaNodeResource
class_name GaeaNodeIntersection
## Returns the intersection between [param A]-[param D].[br]
## Later grids override any cells from the previous grids when valid. (B overrides A, C overrides B, etc.)
##
## Generic class for both the [enum GaeaValue.Type] [b]Map[/b] and [b]Data[/b] versions of this node.[br]
## Returns a grid with only the points that are in all inputted grids.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grids: Array[Dictionary] = []
	for param in params:
		grids.append(_get_arg(param.name, area, generator_data))

	var grid: Dictionary = {}
	if grids.is_empty():
		return grid

	for cell: Vector3i in grids.pop_front():
		for subgrid: Dictionary in grids:
			if subgrid.get(cell) == null:
				grid.erase(cell)
				break
			else:
				grid.set(cell, subgrid.get(cell))

	return output_port.return_value(grid)
