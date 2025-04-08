@tool
extends GaeaNodeResource


func get_data(passed_data:Array[Dictionary], output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	log_data(output_port, generator_data)

	var grids: Array[Dictionary] = []
	
	for data in passed_data:
		grids.append(data)
	
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

	return grid
