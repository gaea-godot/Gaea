class_name GaeaChunkLoaderTilemapActor
extends GaeaChunkLoaderActor

@export_node_path("TileMapLayer") var tilemap: NodePath
@export_node_path("Node2D") var player: NodePath

func is_actor_valid(chunk_loader: GaeaChunkLoader) -> bool:
	for path: NodePath in [tilemap, player]:
		var node: Node = chunk_loader.get_node_or_null(tilemap)
		if node == null or not is_instance_valid(node):
			push_error("[GaeaChunkLoaderTilemapActor] Could not find node at ''" % path)
			return false
	return true


func get_actor_chunk_position(chunk_loader: GaeaChunkLoader, chunk_size: Vector3i) -> Vector3i:
	var tilemap_node: TileMapLayer = chunk_loader.get_node(tilemap)
	var player_node: Node2D = chunk_loader.get_node(player)
	var local_position: Vector2 = tilemap_node.to_local(player_node.global_position)
	var map_position: Vector2i = tilemap_node.local_to_map(local_position)
	var conversion: Callable = TileMapGaeaRenderer.get_position_conversion_tilemap_to_gaea(tilemap_node.tile_set)
	var chunk_position: Vector3i = _get_chunk_position(conversion.call(map_position), chunk_size)
	return chunk_position
