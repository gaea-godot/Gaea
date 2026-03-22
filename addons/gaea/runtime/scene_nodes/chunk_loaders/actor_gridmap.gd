class_name GaeaChunkLoaderGridmapActor
extends GaeaChunkLoaderActor

@export_node_path("GridMap") var gridmap: NodePath
@export_node_path("Node3D") var player: NodePath

func is_actor_valid(chunk_loader: GaeaChunkLoader) -> bool:
	for path: NodePath in [gridmap, player]:
		var node: Node = chunk_loader.get_node_or_null(gridmap)
		if node == null or not is_instance_valid(node):
			push_error("[GaeaChunkLoaderGridmapActor] Could not find node at ''" % path)
			return false
	return true


func get_actor_chunk_position(chunk_loader: GaeaChunkLoader, chunk_size: Vector3i) -> Vector3i:
	var gridmap_node: GridMap = chunk_loader.get_node(gridmap)
	var player_node: Node3D = chunk_loader.get_node(player)
	var local_position: Vector3 = gridmap_node.to_local(player_node.global_position)
	var map_position: Vector3i = gridmap_node.local_to_map(local_position)
	var chunk_position: Vector3i = _get_chunk_position(map_position, chunk_size)
	return chunk_position
