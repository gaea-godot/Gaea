@tool
class_name GridMapGaeaRenderer
extends GaeaRenderer
## Renders [GridMapGaeaMaterial]s to a [GridMap].


## The [GridMap] this will try to render on.
## @deprecated: Use [member grid_maps] instead
var gridmap: GridMap

## Should match the size of the [member generator]'s [member GaeaGraph.layers] array. Will
## try to match any generated layers and render it using the corresponding [GridMap].
@export var grid_maps: Array[GridMap] = []

## Used to migrate gridmap reference
func _enter_tree() -> void:
	if is_instance_valid(gridmap):
		grid_maps.push_front(gridmap)


func _render(grid: GaeaGrid) -> void:
	_reset()

	for layer_idx in grid.get_layers_count():
		if grid_maps.size() <= layer_idx or not is_instance_valid(grid_maps.get(layer_idx)):
			continue

		for cell in grid.get_layer(layer_idx):
			var value = grid.get_layer(layer_idx)[cell]
			if value is GridMapGaeaMaterial:
				grid_maps[layer_idx].set_cell_item(cell, value.item_idx)


func _on_area_erased(area: AABB) -> void:
	for x in range(area.position.x, area.end.x):
		for y in range(area.position.y, area.end.y):
			for z in range(area.position.z, area.end.z):
				for layer_idx in grid_maps:
					grid_maps[layer_idx].set_cell_item(Vector3(x, y, z), GridMap.INVALID_CELL_ITEM)


func _reset() -> void:
	for grid in grid_maps:
		if is_instance_valid(grid):
			grid.clear()
