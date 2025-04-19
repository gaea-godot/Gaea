@tool
extends GaeaNodeResource

func get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grids: Array[Dictionary] = []
	for param in params:
		grids.append(get_arg(param.name, area, generator_data))

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
