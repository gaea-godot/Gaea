@tool
extends GaeaNodeResource
class_name GaeaNodeDifference
## Returns the difference between [param A] - [param B].
##
## Generic class for both the [enum GaeaValue.Type] [b]Map[/b] and [b]Data[/b] versions of this node.[br]
## Returns all the points from [param A] without all the points from [param B].


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grids: Array[Dictionary] = []
	for param in params:
		grids.append(_get_arg(param.name, area, generator_data))

	var grid: Dictionary = {}
	if grids.is_empty():
		return grid

	var grid_a: Dictionary = grids.pop_front()
	for cell: Vector3i in grid_a:
		for subgrid: Dictionary in grids:
			if subgrid.get(cell) != null:
				break
			grid.set(cell, grid_a.get(cell))

	return output_port.return_value(grid)
