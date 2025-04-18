@tool
extends GaeaNodeResource


func get_data(passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(_output_port, generator_data)
	
	var grids: Array[Dictionary] = []
	
	for grid_data in passed_data:
		grids.append(grid_data)

	var grid: Dictionary = {}
	if grids.is_empty():
		return grid

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				for subgrid: Dictionary in grids:
					if subgrid.get(cell) != null:
						grid.set(cell, subgrid.get(cell))

	return grid
