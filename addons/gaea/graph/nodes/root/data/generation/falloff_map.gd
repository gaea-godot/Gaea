@tool
extends GaeaNodeResource
class_name GaeaNodeFalloffMap
## Returns a grid that goes from higher values in the center to lower in the borders.
## Rate can be adjusted with [param start] and [param end].
##
## For lower [param start] values, the transition will be smoother.[br]
## For lower [param end] values, the generated 'square' will be smaller.[br]
## Multiplying this with a [GaeaNodeSimplexSmooth]'s generation can create island-looking terrains.


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	var start: float = _get_arg(&"start", area, generator_data)
	var end: float = _get_arg(&"end", area, generator_data)
	var new_grid: Dictionary[Vector3i, float]

	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			var i: float = x / float(area.size.x) * 2 - 1
			var j: float = y / float(area.size.y) * 2 - 1

			# Get closest to 1.
			var value: float = maxf(absf(i), absf(j))
			var falloff_value: float

			if value < start:
				falloff_value = 1.0
			elif value > end:
				falloff_value = 0.0
			else:
				falloff_value = smoothstep(1.0, 0.0, inverse_lerp(start, end, value))

			new_grid[Vector3i(x, y, 0)] = falloff_value

	return output_port.return_value(new_grid)
