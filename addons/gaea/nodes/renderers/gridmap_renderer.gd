@tool
class_name GridMapGaeaRenderer
extends GaeaRenderer
## Renders [GridMapMaterial]s to a [GridMap].


## The [GridMap] this will try to render on.
@export var gridmap: GridMap


func _render(grid: GaeaGrid) -> void:
	_reset()

	for layer_idx in grid.get_layers_count():
		for cell in grid.get_layer(layer_idx):
			var value = grid.get_layer(layer_idx)[cell]
			if value is GridMapMaterial:
				gridmap.set_cell_item(cell, value.item_idx)


func _on_area_erased(area: AABB) -> void:
	for x in range(area.position.x, area.end.x):
		for y in range(area.position.y, area.end.y):
			for z in range(area.position.z, area.end.z):
				gridmap.set_cell_item(Vector3(x, y, z), GridMap.INVALID_CELL_ITEM)


func _reset() -> void:
	gridmap.clear()
