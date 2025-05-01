@tool
class_name GridMapGaeaRenderer
extends GaeaRenderer
## Renders [GridMapMaterial]s to a [GridMap].


## The [GridMap] this will try to render on.
@export var gridmap: GridMap


func _render(grid: GaeaGrid) -> void:
	gridmap.clear()

	for layer_idx in grid.get_layers_count():
		for cell in grid.get_layer(layer_idx):
			var value = grid.get_layer(layer_idx)[cell]
			if value is GaeaGridMapMaterial:
				gridmap.set_cell_item(cell, value.item_idx)
