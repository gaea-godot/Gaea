@tool
class_name GaeaGrid
extends Resource
## Result of a Gaea generation.


## Dictionary of the format [code]{int: Dictionary}[/code] where the key is the layer index
## and the value is a grid of [GaeaMaterial]s.
var _grid: Dictionary[int, GaeaValue.Map]


## Set the layer at [param idx] to the generated [param grid].
## Sets it to an empty grid if [param resource] is disabled (see [member GaeaLayer.enabled]).
func add_layer(idx: int, grid: GaeaValue.Map, resource: GaeaLayer) -> void:
	if resource.enabled == false:
		_grid[idx] = null
		return

	_grid[idx] = grid

## Get the grid at layer [param idx],
func get_layer(idx: int) -> GaeaValue.Map:
	return _grid.get(idx)

## Get the amount of layers the grid has.
func get_layers_count() -> int:
	return _grid.size()
