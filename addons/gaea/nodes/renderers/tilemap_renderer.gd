@tool
class_name TileMapGaeaRenderer
extends GaeaRenderer
## Renders [TileMapMaterial]s to [TileMapLayer]s.

## Should match the size of the [member generator]'s [member GaeaGraph.layers] array. Will
## try to match any generated layers and render it using the corresponding [TileMapLayer].
@export var tile_map_layers: Array[TileMapLayer] = []


func _render(grid: GaeaGrid) -> void:
	if tile_map_layers.size() == 0:
		push_warning("No tile map layers set in the renderer")

	for layer_idx in grid.get_layers_count():
		if not is_instance_valid(grid.get_layer(layer_idx)):
			continue

		var terrains: Dictionary[TileMapGaeaMaterial, Array] = {}
		var patterns: Dictionary[TileMapGaeaMaterial, Array] = {}
		if tile_map_layers.size() <= layer_idx or not is_instance_valid(tile_map_layers.get(layer_idx)):
			continue

		var position_conversion: Callable = _get_position_conversion_method(tile_map_layers[layer_idx].tile_set)
		for cell in grid.get_layer(layer_idx).get_cells():
			var value = grid.get_layer(layer_idx).get_cell(cell)
			if value is TileMapGaeaMaterial:
				if value.type == TileMapGaeaMaterial.Type.SINGLE_CELL:
					tile_map_layers[layer_idx].set_cell(position_conversion.call(cell), value.source_id, value.atlas_coord, value.alternative_tile)
				elif value.type == TileMapGaeaMaterial.Type.TERRAIN:
					terrains.get_or_add(value, []).append(position_conversion.call(cell))
				elif value.type == TileMapGaeaMaterial.Type.PATTERN:
					patterns.get_or_add(value, []).append(position_conversion.call(cell))

		for terrain_material: TileMapGaeaMaterial in terrains:
			tile_map_layers[layer_idx].set_cells_terrain_connect(
				terrains.get(terrain_material).map(position_conversion), terrain_material.terrain_set, terrain_material.terrain, false
			)

		for pattern_material: TileMapGaeaMaterial in patterns:
			var pattern := tile_map_layers[layer_idx].tile_set.get_pattern(pattern_material.pattern_index)
			for cell in patterns.get(pattern_material):
				tile_map_layers[layer_idx].set_pattern(
					position_conversion.call(cell + pattern_material.pattern_offset),
					pattern
				)


func _erase_area(area: AABB) -> void:
	for tile_map_layer in tile_map_layers:
		if not is_instance_valid(tile_map_layer):
			continue
		for x in range(area.position.x, area.end.x):
			for y in range(area.position.y, area.end.y):
				tile_map_layer.erase_cell(Vector2i(x, y))


func _reset() -> void:
	for tile_map_layer in tile_map_layers:
		if not is_instance_valid(tile_map_layer):
			continue
		tile_map_layer.clear()


# Conversion methods adapted from https://github.com/Zehir/godot-hexagon-tile-map-layer
## This method return a [Callable] to convert the Vector3i position from the Map object to the TileMapLayer map position.
static func _get_position_conversion_method(tile_set: TileSet) -> Callable:
	match tile_set.tile_shape:
		TileSet.TileShape.TILE_SHAPE_SQUARE, \
		TileSet.TileShape.TILE_SHAPE_HEXAGON, \
		TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE:

			match tile_set.tile_offset_axis:
				TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL:
					match tile_set.tile_layout:
						TileSet.TileLayout.TILE_LAYOUT_STACKED: return (func(pos: Vector3i) -> Vector2i:
							return Vector2i(pos.x, pos.y)
						)
						TileSet.TileLayout.TILE_LAYOUT_STACKED_OFFSET: return (func(pos: Vector3i) -> Vector2i:
							return Vector2i(pos.x + (pos.y & 1), pos.y)
						)
						TileSet.TileLayout.TILE_LAYOUT_STAIRS_RIGHT: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x - ((pos.y & ~1) >> 1)
							return Vector2i(part, pos.y)
						)
						TileSet.TileLayout.TILE_LAYOUT_STAIRS_DOWN: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x - ((pos.y & ~1) >> 1)
							return Vector2i(part + part + pos.y, -part)
						)
						TileSet.TileLayout.TILE_LAYOUT_DIAMOND_RIGHT: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x - ((pos.y & ~1) >> 1)
							return Vector2i(part, part + pos.y)
						)
						TileSet.TileLayout.TILE_LAYOUT_DIAMOND_DOWN: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x - ((pos.y & ~1) >> 1)
							return Vector2i(part + pos.y, -part)
						)

				TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_VERTICAL:
					match tile_set.tile_layout:
						TileSet.TileLayout.TILE_LAYOUT_STACKED: return (func(pos: Vector3i) -> Vector2i:
							return Vector2i(pos.x, pos.y)
						)
						TileSet.TileLayout.TILE_LAYOUT_STACKED_OFFSET: return (func(pos: Vector3i) -> Vector2i:
							return Vector2i(pos.x, pos.y + (pos.x & 1))
						)
						TileSet.TileLayout.TILE_LAYOUT_STAIRS_RIGHT: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - ((pos.x - (pos.x & 1)) >> 1)
							return Vector2i(-part, pos.x + part + part)
						)
						TileSet.TileLayout.TILE_LAYOUT_STAIRS_DOWN: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - ((pos.x - (pos.x & 1)) >> 1)
							return Vector2i(pos.x, part)
						)
						TileSet.TileLayout.TILE_LAYOUT_DIAMOND_RIGHT: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - ((pos.x - (pos.x & 1)) >> 1)
							return Vector2i(-part, pos.x + part)
						)
						TileSet.TileLayout.TILE_LAYOUT_DIAMOND_DOWN: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - ((pos.x - (pos.x & 1)) >> 1)
							return Vector2i(pos.x + part, part)
						)

		TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
			# Only the 2 stacked layout need axis dependant methods
			match tile_set.tile_layout:
				TileSet.TileLayout.TILE_LAYOUT_STACKED:
					match tile_set.tile_offset_axis:
						TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - pos.x
							return Vector2i(pos.x + (part >> 1), part)
						)
						TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_VERTICAL: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x + pos.y
							return Vector2i(part, -pos.x + (part >> 1))
						)
				TileSet.TileLayout.TILE_LAYOUT_STACKED_OFFSET:
					match tile_set.tile_offset_axis:
						TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.y - pos.x
							return Vector2i(pos.x + (part + 1 >> 1), part)
						)
						TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_VERTICAL: return (func(pos: Vector3i) -> Vector2i:
							var part = pos.x + pos.y
							return Vector2i(part, -pos.x + (part + 1 >> 1))
						)
				TileSet.TileLayout.TILE_LAYOUT_STAIRS_RIGHT: return (func(pos: Vector3i) -> Vector2i:
					return Vector2i(pos.x, pos.y - pos.x)
				)
				TileSet.TileLayout.TILE_LAYOUT_STAIRS_DOWN: return (func(pos: Vector3i) -> Vector2i:
					return Vector2i(pos.y + pos.x, -pos.x)
				)
				TileSet.TileLayout.TILE_LAYOUT_DIAMOND_RIGHT: return (func(pos: Vector3i) -> Vector2i:
					return Vector2i(pos.x, pos.y)
				)
				TileSet.TileLayout.TILE_LAYOUT_DIAMOND_DOWN: return (func(pos: Vector3i) -> Vector2i:
					return Vector2i(pos.y, -pos.x)
				)

	push_error("No conversion method for this tile_set")
	return Callable()
