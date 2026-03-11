@tool
@icon("../../assets/grid.svg")
class_name GaeaGrid
extends Resource
## Result of a Gaea generation.


## Dictionary of the format [code]{int: Dictionary}[/code] where the key is the layer index
## and the value is a grid of [GaeaMaterial]s.
var _grid: Dictionary[int, GaeaValue.Map]:
	get = get_grid_data


func _init(dictionary: Dictionary[int, GaeaValue.Map] = {}) -> void:
	_grid = dictionary


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


## Get the enabled layers indexes.
func get_enabled_layers_indexes() -> Array[int]:
	var indexes: Array[int] = []
	for key in _grid.keys():
		if _grid.get(key) != null:
			indexes.append(key)
	return indexes


func get_grid_data() -> Dictionary[int, GaeaValue.Map]:
	return _grid
