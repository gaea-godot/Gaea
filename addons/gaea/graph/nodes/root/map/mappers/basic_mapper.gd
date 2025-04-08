@tool
extends GaeaNodeResource

func _get_required_input_ports() -> Array[int]: return [0, 1]

func get_data(passed_data:Array[Dictionary], _output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	log_data(_output_port, generator_data)

	var grid_data: Dictionary = passed_data[0]
	var material: GaeaMaterial = passed_data[1].get("value", null)

	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in grid_data:
		if _passes_mapping(grid_data, cell, generator_data) and is_instance_valid(material):
			grid[cell] = material.get_resource()

	return grid


func _passes_mapping(passed_data: Dictionary, cell: Vector3i, _generator_data: GaeaData) -> bool:
	return passed_data.get(cell) != null
