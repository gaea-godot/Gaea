@tool
extends GaeaNodeOperation
class_name GaeaNodeDataOperation
## Applies [member operation] to a value of [enum GaeaValue.Type] Data and a value of type [code]float[/code].


func _get_required_params() -> Array[StringName]:
	return [&"data"]

func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data: Dictionary = _get_arg(&"data", area, generator_data)
	var value: float = _get_arg(&"value", area, generator_data)
	var new_grid: Dictionary[Vector3i, float]
	for cell in data:
		new_grid.set(cell, _get_new_value(data.get(cell), value))

	return output_port.return_value(new_grid)
