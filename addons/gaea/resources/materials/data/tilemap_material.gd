@tool
class_name TileMapGaeaMaterial
extends GaeaMaterial
## Resource used to tell the [TileMapGaeaRenderer] which tile from a [TileMapLayer] to place.

enum Type {
	SINGLE_CELL, ## Tile is just a single cell in the TileMap. Requires a [param source_id] and a [param atlas_coord]. Can optionally be an [param alternative_tile].
	TERRAIN  ## Tile is a terrain from a terrain set. Allows for autotiling. Requires a [param terrain_set] and a [param terrain]
}

## Determines how the [TileMapGaeaRenderer] uses this material.
@export var type: Type = Type.SINGLE_CELL:
	set(value):
		type = value
		notify_property_list_changed()
## A [TileSetSource] identifier. See [method TileSet.set_source_id].[br]
## If set to [code]-1[/code], the cell will be erased.
@export var source_id: int = 0
## Identifies a tile's coordinates in the atlas (if the source is a [TileSetAtlasSource]).
## For [TileSetScenesCollectionSource] it should always be [code]Vector2i(0, 0)[/code]).[br]
## If set to [code]Vector2i(-1, -1)[/code], the cell will be erased.
@export var atlas_coord: Vector2i = Vector2i.ZERO
## Identifies a tile alternative in the atlas (if the source is a [TileSetAtlasSource]),
## and the scene for a [TileSetScenesCollectionSource].[br]
## If set to [code]-1[/code], the cell will be erased.
@export var alternative_tile: int = 0
## The tile's terrain set in the [TileSet].
@export var terrain_set: int = 0
## Terrain in the terrain set determined previously.
@export var terrain: int = 0


func _validate_property(property: Dictionary) -> void:
	match type:
		Type.SINGLE_CELL:
			if property.name.begins_with("terrain"):
				property.usage = PROPERTY_USAGE_NONE
		Type.TERRAIN:
			if property.name in ["source_id", "atlas_coord", "alternative_tile"]:
				property.usage = PROPERTY_USAGE_NONE


func _is_data() -> bool:
	return true
